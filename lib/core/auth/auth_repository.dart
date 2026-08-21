import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  const PasswordResetSuccess({required super.message}) : super(isSuccess: true);
}

class PasswordResetInvalidEmail extends PasswordResetResult {
  const PasswordResetInvalidEmail({
    super.message = 'Please enter a valid work email address.',
  }) : super(isSuccess: false);
}

class PasswordResetFailure extends PasswordResetResult {
  const PasswordResetFailure({required super.message})
    : super(isSuccess: false);
}

abstract class AuthRepository extends ChangeNotifier {
  factory AuthRepository({
    SecureKeyValueStore? storage,
    MacroServiceConfig? config,
  }) = AuthRepositoryImpl;

  UserProfile? get currentUser;
  bool get isAuthenticated;
  bool get hasCompletedOnboarding;
  String? get authToken;
  String? get refreshToken;

  Future<AuthResult> restoreSession();
  Future<void> completeOnboarding();
  Future<AuthResult> login(String email, String passwordOrToken);
  Future<AuthResult> loginWithPassword(String email, String password);
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  });
  Future<PasswordResetResult> requestPasswordReset(String email);
  Future<AuthResult> redeemMobileSessionUri(Uri uri);
  Future<AuthResult> redeemMobileSessionCode(String sessionCode);
  Future<AuthResult> refreshSession();
  Future<void> logout();
}

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  static const _localAuthHost = 'http://127.0.0.1:8080';
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  final SecureKeyValueStore _storage;
  final MacroServiceConfig _config;
  final http.Client _client;

  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  String? _authToken;
  String? _refreshToken;
  UserProfile? _currentUser;

  AuthRepositoryImpl({
    SecureKeyValueStore? storage,
    MacroServiceConfig? config,
    http.Client? client,
  }) : _storage = storage ?? PlatformSecureStorageService(),
       _config = config ?? MacroServiceConfig.production(),
       _client = client ?? http.Client();

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
    final storedToken = await _storage.read(_authTokenKey);
    final storedRefreshToken = await _storage.read(_refreshTokenKey);
    final storedOnboarded = await _storage.read('has_onboarded');

    _hasCompletedOnboarding = storedOnboarded == 'true';

    if (storedToken == null || storedToken.trim().isEmpty) {
      return _failClosed('No active session token found.');
    }

    final validationResult = await _validateTokenWithServer(storedToken.trim());
    if (validationResult is AuthSuccess) {
      _authToken = storedToken.trim();
      _refreshToken = storedRefreshToken?.trim();
      _isAuthenticated = true;
      _currentUser = validationResult.user;
      notifyListeners();
      return validationResult;
    }

    await logout();
    return validationResult;
  }

  @override
  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _storage.write('has_onboarded', 'true');
    notifyListeners();
  }

  @override
  Future<AuthResult> login(String email, String passwordOrToken) async {
    final tokenCandidate = passwordOrToken.trim().isNotEmpty
        ? passwordOrToken.trim()
        : email.trim();
    if (tokenCandidate.isEmpty) {
      return const AuthValidationFailure(
        message: 'Bearer API token or credentials required.',
      );
    }

    final validationResult = await _validateTokenWithServer(tokenCandidate);
    if (validationResult is! AuthSuccess) return validationResult;

    await _persistRemoteSession(
      accessToken: tokenCandidate,
      refreshToken: null,
      user: validationResult.user!,
    );
    return validationResult;
  }

  @override
  Future<AuthResult> loginWithPassword(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return const AuthValidationFailure(
        message: 'Email and password required.',
      );
    }

    if (_usesLocalAuth) return _loginWithLocalPassword(email, password);

    try {
      final response = await _client
          .post(
            Uri.parse('${_config.authHost}/login/password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken =
            data['access_token']?.toString() ?? data['token']?.toString();
        final refreshToken = data['refresh_token']?.toString();
        if (accessToken != null && accessToken.isNotEmpty) {
          return _acceptRemoteTokenPair(accessToken, refreshToken);
        }
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const AuthInvalidCredentials();
      }

      return AuthServerFailure(
        message: 'Server returned HTTP ${response.statusCode}',
      );
    } on TimeoutException {
      return const AuthNetworkFailure(
        message: 'Connection timed out calling auth-service.',
      );
    } catch (e) {
      return AuthNetworkFailure(message: 'Network error: $e');
    }
  }

  @override
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      return const AuthValidationFailure(
        message: 'Name, email, and password are required.',
      );
    }

    if (_usesLocalAuth) {
      return _signupLocally(name: name, email: email, password: password);
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${_config.authHost}/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken =
            data['access_token']?.toString() ?? data['token']?.toString();
        final refreshToken = data['refresh_token']?.toString();
        if (accessToken != null && accessToken.isNotEmpty) {
          return _acceptRemoteTokenPair(accessToken, refreshToken);
        }
      }

      return AuthServerFailure(
        message: 'Signup failed: HTTP ${response.statusCode}',
      );
    } on TimeoutException {
      return const AuthNetworkFailure(message: 'Signup request timed out.');
    } catch (e) {
      return AuthNetworkFailure(message: 'Network error: $e');
    }
  }

  @override
  Future<PasswordResetResult> requestPasswordReset(String email) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      return const PasswordResetInvalidEmail();
    }
    return PasswordResetSuccess(
      message: 'Password reset request dispatched to $email.',
    );
  }

  @override
  Future<AuthResult> redeemMobileSessionUri(Uri uri) async {
    if (uri.scheme != 'macro' || uri.host != 'login') {
      return const AuthValidationFailure(
        message: 'Unsupported authentication callback.',
      );
    }

    final sessionCode =
        uri.queryParameters['token'] ?? uri.queryParameters['session_code'];
    if (sessionCode == null || sessionCode.trim().isEmpty) {
      return const AuthValidationFailure(
        message: 'Missing mobile session code in authentication callback.',
      );
    }

    return redeemMobileSessionCode(sessionCode);
  }

  @override
  Future<AuthResult> redeemMobileSessionCode(String sessionCode) async {
    if (sessionCode.trim().isEmpty) {
      return const AuthValidationFailure(message: 'Session code is required.');
    }

    try {
      final response = await _client
          .get(
            Uri.parse(
              '${_config.authHost}/session/login/${Uri.encodeComponent(sessionCode.trim())}',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token']?.toString();
        final refreshToken = data['refresh_token']?.toString();
        if (accessToken == null ||
            accessToken.isEmpty ||
            refreshToken == null ||
            refreshToken.isEmpty) {
          return const AuthServerFailure(
            message: 'Session login response did not include both tokens.',
          );
        }
        return _acceptRemoteTokenPair(accessToken, refreshToken);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const AuthInvalidCredentials(
          message: 'Mobile session code is invalid or expired.',
        );
      }

      return AuthServerFailure(
        message: 'Session login failed with HTTP ${response.statusCode}.',
      );
    } on TimeoutException {
      return const AuthNetworkFailure(
        message: 'Session login request timed out.',
      );
    } catch (e) {
      return AuthNetworkFailure(message: 'Session login network error: $e');
    }
  }

  @override
  Future<AuthResult> refreshSession() async {
    final accessToken = _authToken ?? await _storage.read(_authTokenKey);
    final refreshToken = _refreshToken ?? await _storage.read(_refreshTokenKey);

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return const AuthInvalidCredentials(
        message: 'No refresh token available.',
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${_config.authHost}/jwt/refresh'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'x-macro-refresh-token': refreshToken,
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rotatedAccessToken = data['access_token']?.toString();
        final rotatedRefreshToken = data['refresh_token']?.toString();
        if (rotatedAccessToken == null ||
            rotatedAccessToken.isEmpty ||
            rotatedRefreshToken == null ||
            rotatedRefreshToken.isEmpty) {
          return const AuthServerFailure(
            message: 'Refresh response did not include rotated tokens.',
          );
        }
        return _acceptRemoteTokenPair(rotatedAccessToken, rotatedRefreshToken);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        await logout();
        return const AuthInvalidCredentials(message: 'Refresh token expired.');
      }

      return AuthServerFailure(
        message: 'Refresh failed with HTTP ${response.statusCode}.',
      );
    } on TimeoutException {
      return const AuthNetworkFailure(message: 'Refresh request timed out.');
    } catch (e) {
      return AuthNetworkFailure(message: 'Refresh network error: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(_authTokenKey);
    await _storage.delete(_refreshTokenKey);
    await _storage.delete('user_name');
    await _storage.delete('user_email');
    _isAuthenticated = false;
    _authToken = null;
    _refreshToken = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<AuthResult> _validateTokenWithServer(String token) async {
    if (_usesLocalAuth) return _validateLocalToken(token);

    try {
      final response = await _client
          .get(
            Uri.parse('${_config.authHost}/user/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = UserProfile(
          id: data['id']?.toString() ?? 'u_me',
          name: data['name']?.toString() ?? 'Workspace Member',
          email: data['email']?.toString() ?? 'user@macro.com',
          avatarUrl: data['avatar_url']?.toString() ?? '',
          role: data['role']?.toString() ?? 'Member',
        );
        return AuthSuccess(user: user, token: token);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return const AuthInvalidCredentials();
      }

      return AuthServerFailure(
        message: 'Auth service error HTTP ${response.statusCode}',
      );
    } on TimeoutException {
      return const AuthNetworkFailure(
        message: 'Auth server request timed out.',
      );
    } catch (e) {
      return AuthNetworkFailure(message: 'Network error: $e');
    }
  }

  AuthResult _failClosed(String reason) {
    _isAuthenticated = false;
    _authToken = null;
    _refreshToken = null;
    _currentUser = null;
    notifyListeners();
    return AuthInvalidCredentials(message: reason);
  }

  Future<AuthResult> _acceptRemoteTokenPair(
    String accessToken,
    String? refreshToken,
  ) async {
    final validationResult = await _validateTokenWithServer(accessToken);
    if (validationResult is! AuthSuccess) return validationResult;

    await _persistRemoteSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: validationResult.user!,
    );
    return validationResult;
  }

  Future<void> _persistRemoteSession({
    required String accessToken,
    required String? refreshToken,
    required UserProfile user,
  }) async {
    await _storage.write(_authTokenKey, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(_refreshTokenKey, refreshToken);
    }
    await _storage.write('user_name', user.name);
    await _storage.write('user_email', user.email);
    await _storage.write('has_onboarded', 'true');

    _authToken = accessToken;
    _refreshToken = refreshToken;
    _isAuthenticated = true;
    _hasCompletedOnboarding = true;
    _currentUser = user;
    notifyListeners();
  }

  bool get _usesLocalAuth => _config.authHost == _localAuthHost;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _localUserKey(String email) => 'local_user:${_normalizeEmail(email)}';

  String _localTokenKey(String token) => 'local_token:$token';

  String _localTokenFor(String email) {
    final normalized = _normalizeEmail(email);
    final encoded = base64Url
        .encode(utf8.encode(normalized))
        .replaceAll('=', '');
    return 'local_macro_$encoded';
  }

  UserProfile _userFromStoredJson(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserProfile(
      id: data['id']?.toString() ?? 'local_user',
      name: data['name']?.toString() ?? 'Workspace Member',
      email: data['email']?.toString() ?? 'user@macro.local',
      avatarUrl: data['avatar_url']?.toString() ?? '',
      role: data['role']?.toString() ?? 'Workspace Owner',
    );
  }

  Future<void> _persistLocalSession({
    required UserProfile user,
    required String token,
  }) async {
    await _storage.write(_authTokenKey, token);
    await _storage.write('user_name', user.name);
    await _storage.write('user_email', user.email);
    await _storage.write('has_onboarded', 'true');

    _authToken = token;
    _refreshToken = null;
    _isAuthenticated = true;
    _hasCompletedOnboarding = true;
    _currentUser = user;
    notifyListeners();
  }

  Future<AuthResult> _signupLocally({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!email.contains('@')) {
      return const AuthValidationFailure(
        message: 'Please enter a valid work email address.',
      );
    }

    if (password.trim().length < 8) {
      return const AuthValidationFailure(
        message: 'Password must be at least 8 characters.',
      );
    }

    final normalizedEmail = _normalizeEmail(email);
    final userKey = _localUserKey(normalizedEmail);
    final existingUser = await _storage.read(userKey);

    if (existingUser != null) {
      return const AuthValidationFailure(
        message: 'An account already exists for this email. Please sign in.',
      );
    }

    final token = _localTokenFor(normalizedEmail);
    final user = UserProfile(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      avatarUrl: '',
      role: 'Workspace Owner',
    );

    final payload = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'avatar_url': user.avatarUrl,
      'role': user.role,
      'password': password,
      'workspace_name': '${name.trim().split(' ').first} Workspace',
    });

    await _storage.write(userKey, payload);
    await _storage.write(_localTokenKey(token), userKey);
    await _persistLocalSession(user: user, token: token);

    return AuthSuccess(user: user, token: token);
  }

  Future<AuthResult> _loginWithLocalPassword(
    String email,
    String password,
  ) async {
    final userJson = await _storage.read(_localUserKey(email));

    if (userJson == null) {
      return const AuthInvalidCredentials(
        message: 'No local account found. Create a workspace account first.',
      );
    }

    final data = jsonDecode(userJson) as Map<String, dynamic>;
    if (data['password']?.toString() != password) {
      return const AuthInvalidCredentials(message: 'Incorrect password.');
    }

    final user = _userFromStoredJson(userJson);
    final token = _localTokenFor(user.email);
    await _storage.write(_localTokenKey(token), _localUserKey(user.email));
    await _persistLocalSession(user: user, token: token);

    return AuthSuccess(user: user, token: token);
  }

  Future<AuthResult> _validateLocalToken(String token) async {
    final userKey = await _storage.read(_localTokenKey(token));
    if (userKey == null) {
      return const AuthInvalidCredentials(message: 'Local session expired.');
    }

    final userJson = await _storage.read(userKey);
    if (userJson == null) {
      return const AuthInvalidCredentials(message: 'Local account not found.');
    }

    final user = _userFromStoredJson(userJson);
    _authToken = token;
    _refreshToken = null;
    _isAuthenticated = true;
    _currentUser = user;
    notifyListeners();

    return AuthSuccess(user: user, token: token);
  }
}
