import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../config/macro_service_config.dart';
import '../../models/models.dart';
import '../storage/secure_key_value_store.dart';

sealed class AuthResult {
  final bool isSuccess;
  final String? message;
  final UserProfile? user;
  final String? token;

  const AuthResult({
    required this.isSuccess,
    this.message,
    this.user,
    this.token,
  });
}

class AuthSuccess extends AuthResult {
  const AuthSuccess({required UserProfile user, required String token})
    : super(isSuccess: true, user: user, token: token);
}

class AuthInvalidCredentials extends AuthResult {
  const AuthInvalidCredentials({
    String message = 'Invalid credentials or expired session.',
  }) : super(isSuccess: false, message: message);
}

class AuthNetworkFailure extends AuthResult {
  const AuthNetworkFailure({
    String message = 'Network connection failed while authenticating.',
  }) : super(isSuccess: false, message: message);
}

class AuthServerFailure extends AuthResult {
  const AuthServerFailure({required String message})
    : super(isSuccess: false, message: message);
}

class AuthValidationFailure extends AuthResult {
  const AuthValidationFailure({required String message})
    : super(isSuccess: false, message: message);
}

class AuthUnknownFailure extends AuthResult {
  const AuthUnknownFailure({required String message})
    : super(isSuccess: false, message: message);
}

sealed class PasswordResetResult {
  final bool isSuccess;
  final String message;

  const PasswordResetResult({required this.isSuccess, required this.message});
}

class PasswordResetSuccess extends PasswordResetResult {
  const PasswordResetSuccess({required String message})
    : super(isSuccess: true, message: message);
}

class PasswordResetInvalidEmail extends PasswordResetResult {
  const PasswordResetInvalidEmail({
    String message = 'Please enter a valid work email address.',
  }) : super(isSuccess: false, message: message);
}

class PasswordResetFailure extends PasswordResetResult {
  const PasswordResetFailure({required String message})
    : super(isSuccess: false, message: message);
}

abstract interface class AuthRepository {
  UserProfile? get currentUser;
  bool get isAuthenticated;
  bool get hasCompletedOnboarding;
  String? get authToken;
  String? get refreshToken;

  Future<AuthResult> restoreSession();
  Future<void> completeOnboarding();

  /// Starts Macro's mobile Google SSO flow using the verified `google_gmail`
  /// identity provider. Completion happens through a `macro://login` deep link.
  Future<bool> startGoogleSignIn();

  /// Redeems the one-time session code returned by Macro mobile SSO.
  Future<AuthResult> completeMobileGoogleSignIn(Uri callbackUri);

  /// Explicit integration/developer token login. This is intentionally kept
  /// separate from the normal Google sign-in experience.
  Future<AuthResult> login(String email, String apiToken);
  Future<AuthResult> loginWithPassword(String email, String password);
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  });
  Future<PasswordResetResult> requestPasswordReset(String email);
  Future<AuthResult> refreshSession();
  Future<void> logout();
}

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  static const _accessTokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _onboardedKey = 'has_onboarded';
  static const _storedNameKey = 'user_name';
  static const _storedEmailKey = 'user_email';

  static const _googleLoginCallback = 'macro://login';
  static const _googleIdpName = 'google_gmail';

  final SecureKeyValueStore _storage;
  final MacroServiceConfig _config;

  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  String? _authToken;
  String? _refreshToken;
  UserProfile? _currentUser;
  Future<AuthResult>? _refreshFuture;

  AuthRepositoryImpl({SecureKeyValueStore? storage, MacroServiceConfig? config})
    : _storage = storage ?? PlatformSecureStorageService(),
      _config = config ?? MacroServiceConfig.production();

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  @override
  String? get authToken => _authToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<AuthResult> restoreSession() async {
    final storedToken = await _storage.read(_accessTokenKey);
    final storedRefreshToken = await _storage.read(_refreshTokenKey);
    final storedOnboarded = await _storage.read(_onboardedKey);

    _hasCompletedOnboarding = storedOnboarded == 'true';

    if (storedToken == null || storedToken.trim().isEmpty) {
      return _failClosed('No active session found.');
    }

    _authToken = storedToken.trim();
    _refreshToken = storedRefreshToken?.trim();

    final validation = await _validateTokenWithServer(_authToken!);
    if (validation is AuthSuccess) {
      _isAuthenticated = true;
      _currentUser = validation.user;
      notifyListeners();
      return validation;
    }

    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      final refreshed = await refreshSession();
      if (refreshed is AuthSuccess) return refreshed;
    }

    await _clearSessionStorage();
    return validation;
  }

  @override
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _storage.write(_onboardedKey, 'true');
    notifyListeners();
  }

  @override
  Future<bool> startGoogleSignIn() async {
    final base = Uri.parse('${_config.authHost}/login/sso');
    final uri = base.replace(
      queryParameters: const {
        'idp_name': _googleIdpName,
        'original_url': _googleLoginCallback,
        'is_mobile': 'true',
      },
    );

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthResult> completeMobileGoogleSignIn(Uri callbackUri) async {
    final isExpectedCallback =
        callbackUri.scheme == 'macro' &&
        (callbackUri.host == 'login' || callbackUri.path == '/login');
    if (!isExpectedCallback) {
      return const AuthValidationFailure(
        message: 'Unexpected Google sign-in callback.',
      );
    }

    final sessionCode = callbackUri.queryParameters['token'];
    if (sessionCode == null || sessionCode.trim().isEmpty) {
      return const AuthValidationFailure(
        message: 'Google sign-in returned no mobile session code.',
      );
    }

    try {
      final code = Uri.encodeComponent(sessionCode.trim());
      final response = await http
          .get(Uri.parse('${_config.authHost}/session/login/$code'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return AuthServerFailure(
          message: 'Google session exchange failed: HTTP ${response.statusCode}.',
        );
      }

      final data = _decodeMap(response.body);
      final accessToken = data['access_token']?.toString();
      final refreshToken = data['refresh_token']?.toString();
      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        return const AuthServerFailure(
          message: 'Google session exchange returned incomplete credentials.',
        );
      }

      await _saveTokens(accessToken, refreshToken);
      final result = await _validateTokenWithServer(accessToken);
      if (result is AuthSuccess) {
        _isAuthenticated = true;
        _currentUser = result.user;
        notifyListeners();
        return result;
      }

      await _clearSessionStorage();
      return result;
    } on TimeoutException {
      return const AuthNetworkFailure(
        message: 'Google sign-in session exchange timed out.',
      );
    } catch (e) {
      return AuthNetworkFailure(message: 'Google sign-in failed: $e');
    }
  }

  @override
  Future<AuthResult> login(String email, String apiToken) async {
    final tokenCandidate = apiToken.trim();
    if (tokenCandidate.isEmpty) {
      return const AuthValidationFailure(
        message: 'A Macro API token is required for integration login.',
      );
    }

    final result = await _validateTokenWithServer(tokenCandidate);
    if (result is! AuthSuccess) return result;

    await _saveTokens(tokenCandidate, null);
    _isAuthenticated = true;
    _currentUser = result.user;
    notifyListeners();
    return result;
  }

  @override
  Future<AuthResult> loginWithPassword(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const AuthValidationFailure(
        message: 'Email and password are required.',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('${_config.authHost}/login/password'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const AuthInvalidCredentials();
      }
      if (response.statusCode != 200) {
        return AuthServerFailure(
          message: 'Password login failed: HTTP ${response.statusCode}.',
        );
      }

      final data = _decodeMap(response.body);
      final accessToken = data['access_token']?.toString();
      final refreshToken = data['refresh_token']?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        return const AuthServerFailure(
          message: 'Password login returned no access token.',
        );
      }

      await _saveTokens(accessToken, refreshToken);
      final result = await _validateTokenWithServer(accessToken);
      if (result is AuthSuccess) {
        _isAuthenticated = true;
        _currentUser = result.user;
        notifyListeners();
      }
      return result;
    } on TimeoutException {
      return const AuthNetworkFailure(message: 'Password login timed out.');
    } catch (e) {
      return AuthNetworkFailure(message: 'Password login failed: $e');
    }
  }

  @override
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return const AuthValidationFailure(
        message: 'Name, email, and password are required.',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('${_config.authHost}/user'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': name.trim(),
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 201) {
        return AuthServerFailure(
          message: 'Account creation failed: HTTP ${response.statusCode}.',
        );
      }

      return loginWithPassword(email, password);
    } on TimeoutException {
      return const AuthNetworkFailure(message: 'Account creation timed out.');
    } catch (e) {
      return AuthNetworkFailure(message: 'Account creation failed: $e');
    }
  }

  @override
  Future<PasswordResetResult> requestPasswordReset(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty || !normalized.contains('@')) {
      return const PasswordResetInvalidEmail();
    }

    try {
      // Macro exposes a verified passwordless login route rather than a public
      // password-reset route. Use the truthful recovery mechanism: email a
      // one-time sign-in link that hands back to the mobile app.
      final response = await http
          .post(
            Uri.parse('${_config.authHost}/login/passwordless'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': normalized,
              'redirect_uri': _googleLoginCallback,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 202) {
        return PasswordResetSuccess(
          message: 'A secure sign-in link was sent to $normalized.',
        );
      }
      return PasswordResetFailure(
        message: 'Could not send sign-in link: HTTP ${response.statusCode}.',
      );
    } catch (e) {
      return PasswordResetFailure(message: 'Could not send sign-in link: $e');
    }
  }

  @override
  Future<AuthResult> refreshSession() {
    final existing = _refreshFuture;
    if (existing != null) return existing;

    final future = _refreshSessionInternal();
    _refreshFuture = future;
    return future.whenComplete(() => _refreshFuture = null);
  }

  Future<AuthResult> _refreshSessionInternal() async {
    final accessToken = _authToken;
    final refreshToken = _refreshToken;
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return const AuthInvalidCredentials(message: 'No refreshable session.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('${_config.authHost}/jwt/refresh'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'x-macro-refresh-token': refreshToken,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        if (response.statusCode == 400 || response.statusCode == 401) {
          await _clearSessionStorage();
          return const AuthInvalidCredentials(message: 'Session expired.');
        }
        return AuthServerFailure(
          message: 'Session refresh failed: HTTP ${response.statusCode}.',
        );
      }

      final data = _decodeMap(response.body);
      final newAccess = data['access_token']?.toString();
      final newRefresh = data['refresh_token']?.toString();
      if (newAccess == null ||
          newAccess.isEmpty ||
          newRefresh == null ||
          newRefresh.isEmpty) {
        return const AuthServerFailure(
          message: 'Session refresh returned incomplete credentials.',
        );
      }

      await _saveTokens(newAccess, newRefresh);
      final result = await _validateTokenWithServer(newAccess);
      if (result is AuthSuccess) {
        _isAuthenticated = true;
        _currentUser = result.user;
        notifyListeners();
      }
      return result;
    } catch (e) {
      return AuthNetworkFailure(message: 'Session refresh failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    final token = _authToken;
    if (token != null && token.isNotEmpty) {
      try {
        await http
            .post(
              Uri.parse('${_config.authHost}/logout'),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Local session clearing remains authoritative even when the network
        // logout cannot complete.
      }
    }
    await _clearSessionStorage();
  }

  Future<AuthResult> _validateTokenWithServer(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${_config.authHost}/user/me'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const AuthInvalidCredentials();
      }
      if (response.statusCode != 200) {
        return AuthServerFailure(
          message: 'Auth service error HTTP ${response.statusCode}.',
        );
      }

      // /user/me intentionally returns only identity/organization/permissions.
      // Fetch the currently available richer profile endpoint separately rather
      // than inventing name/email/avatar fields from /user/me.
      final me = _decodeMap(response.body);
      final userId = me['user_id']?.toString() ?? '';
      if (userId.isEmpty) {
        return const AuthServerFailure(
          message: 'Auth service returned no user identifier.',
        );
      }

      final profile = await _fetchProfile(token, userId);
      return AuthSuccess(user: profile, token: token);
    } on TimeoutException {
      return const AuthNetworkFailure(message: 'Auth server request timed out.');
    } catch (e) {
      return AuthNetworkFailure(message: 'Auth validation failed: $e');
    }
  }

  Future<UserProfile> _fetchProfile(String token, String userId) async {
    String? name;
    String? email;

    try {
      final response = await http
          .get(
            Uri.parse('${_config.authHost}/user/legacy_user_permissions'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = _decodeMap(response.body);
        name = data['name']?.toString();
        email = data['email']?.toString();
      }
    } catch (_) {
      // The legacy profile endpoint is supplementary. A validated /user/me
      // response is still sufficient to keep the authenticated session.
    }

    name ??= await _storage.read(_storedNameKey);
    email ??= await _storage.read(_storedEmailKey);

    final profile = UserProfile(
      id: userId,
      name: (name == null || name.trim().isEmpty) ? 'Workspace Member' : name,
      email: email ?? '',
      avatarUrl: '',
      role: 'Member',
    );

    await _storage.write(_storedNameKey, profile.name);
    if (profile.email.isNotEmpty) {
      await _storage.write(_storedEmailKey, profile.email);
    }
    return profile;
  }

  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    await _storage.write(_accessTokenKey, accessToken);
    _authToken = accessToken;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(_refreshTokenKey, refreshToken);
      _refreshToken = refreshToken;
    } else {
      await _storage.delete(_refreshTokenKey);
      _refreshToken = null;
    }
  }

  Future<void> _clearSessionStorage() async {
    await _storage.delete(_accessTokenKey);
    await _storage.delete(_refreshTokenKey);
    await _storage.delete(_storedNameKey);
    await _storage.delete(_storedEmailKey);
    _isAuthenticated = false;
    _authToken = null;
    _refreshToken = null;
    _currentUser = null;
    notifyListeners();
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object response.');
    }
    return decoded;
  }

  AuthResult _failClosed(String reason) {
    _isAuthenticated = false;
    _authToken = null;
    _refreshToken = null;
    _currentUser = null;
    notifyListeners();
    return AuthInvalidCredentials(message: reason);
  }
}
