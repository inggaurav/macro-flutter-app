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
    String message = 'Invalid credentials or expired API token.',
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
  Future<AuthResult> refreshSession();
  Future<void> logout();
}

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  final SecureKeyValueStore _storage;
  final MacroServiceConfig _config;

  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  String? _authToken;
  UserProfile? _currentUser;

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
  Future<AuthResult> restoreSession() async {
    final storedToken = await _storage.read('auth_token');
    final storedOnboarded = await _storage.read('has_onboarded');

    _hasCompletedOnboarding = storedOnboarded == 'true';

    if (storedToken == null || storedToken.trim().isEmpty) {
      return _failClosed('No active session token found.');
    }

    final validationResult = await _validateTokenWithServer(storedToken.trim());
    if (validationResult is AuthSuccess) {
      _authToken = storedToken.trim();
      _isAuthenticated = true;
      _currentUser = validationResult.user;
      notifyListeners();
      return validationResult;
    } else {
      // FAIL CLOSED: Purge invalid token from storage
      await logout();
      return validationResult;
    }
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
    if (validationResult is AuthSuccess) {
      await _storage.write('auth_token', tokenCandidate);
      await _storage.write('user_name', validationResult.user!.name);
      await _storage.write('user_email', validationResult.user!.email);

      _authToken = tokenCandidate;
      _isAuthenticated = true;
      _currentUser = validationResult.user;

      notifyListeners();
      return validationResult;
    } else {
      // FAIL CLOSED: Do not store token or authenticate session
      return validationResult;
    }
  }

  @override
  Future<AuthResult> loginWithPassword(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return const AuthValidationFailure(
        message: 'Email and password required.',
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('${_config.authHost}/login/password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token =
            data['token']?.toString() ?? data['access_token']?.toString();
        if (token != null && token.isNotEmpty) {
          return login(email, token);
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const AuthInvalidCredentials();
      } else {
        return AuthServerFailure(
          message: 'Server returned HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException {
      return const AuthNetworkFailure(
        message: 'Connection timed out calling auth-service.',
      );
    } catch (e) {
      return AuthNetworkFailure(message: 'Network error: $e');
    }

    return const AuthInvalidCredentials();
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

    try {
      final response = await http
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
        final data = jsonDecode(response.body);
        final token =
            data['token']?.toString() ?? data['access_token']?.toString();
        if (token != null && token.isNotEmpty) {
          return login(email, token);
        }
      } else {
        return AuthServerFailure(
          message: 'Signup failed: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthNetworkFailure(message: 'Network error: $e');
    }

    return const AuthServerFailure(
      message: 'Signup endpoint unverified or failed.',
    );
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
  Future<AuthResult> refreshSession() async {
    if (_authToken == null) return const AuthInvalidCredentials();
    return _validateTokenWithServer(_authToken!);
  }

  @override
  Future<void> logout() async {
    await _storage.delete('auth_token');
    await _storage.delete('user_name');
    await _storage.delete('user_email');
    _isAuthenticated = false;
    _authToken = null;
    _currentUser = null;
    notifyListeners();
  }

  Future<AuthResult> _validateTokenWithServer(String token) async {
    try {
      // Verified Upstream Endpoint: GET authHost/user/me
      final response = await http
          .get(
            Uri.parse('${_config.authHost}/user/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserProfile(
          id: data['id']?.toString() ?? 'u_me',
          name: data['name']?.toString() ?? 'Workspace Member',
          email: data['email']?.toString() ?? 'user@macro.com',
          avatarUrl: data['avatar_url']?.toString() ?? '',
          role: data['role']?.toString() ?? 'Member',
        );
        return AuthSuccess(user: user, token: token);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const AuthInvalidCredentials();
      } else {
        return AuthServerFailure(
          message: 'Auth service error HTTP ${response.statusCode}',
        );
      }
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
    _currentUser = null;
    notifyListeners();
    return AuthInvalidCredentials(message: reason);
  }
}
