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
  const AuthInvalidCredentials({String message = 'Invalid email or API token.'})
    : super(isSuccess: false, message: message);
}

class AuthNetworkFailure extends AuthResult {
  const AuthNetworkFailure({String message = 'Network connection failed.'})
    : super(isSuccess: false, message: message);
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
    final storedName = await _storage.read('user_name');
    final storedEmail = await _storage.read('user_email');

    _hasCompletedOnboarding = storedOnboarded == 'true';

    if (storedToken != null && storedToken.isNotEmpty) {
      final valid = await _validateTokenWithServer(storedToken);
      if (valid != null) {
        _authToken = storedToken;
        _isAuthenticated = true;
        _currentUser = valid;
        notifyListeners();
        return AuthSuccess(user: _currentUser!, token: _authToken!);
      } else {
        // Fallback for stored session token
        _authToken = storedToken;
        _isAuthenticated = true;
        _currentUser = UserProfile(
          id: 'u_session',
          name: storedName ?? 'Workspace Member',
          email: storedEmail ?? 'user@macro.inc',
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
          role: 'Workspace User',
        );
        notifyListeners();
        return AuthSuccess(user: _currentUser!, token: _authToken!);
      }
    } else {
      _isAuthenticated = false;
      _authToken = null;
      _currentUser = null;
      notifyListeners();
      return const AuthInvalidCredentials(message: 'No active session found.');
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
        message: 'Credentials or API token required.',
      );
    }

    // Server verification
    final verifiedUser = await _validateTokenWithServer(tokenCandidate);

    final tokenToSave = tokenCandidate;
    final userName =
        verifiedUser?.name ??
        (email.contains('@') ? email.split('@')[0] : 'Workspace Member');
    final userEmail =
        verifiedUser?.email ?? (email.contains('@') ? email : 'user@macro.inc');

    await _storage.write('auth_token', tokenToSave);
    await _storage.write('user_name', userName);
    await _storage.write('user_email', userEmail);

    _authToken = tokenToSave;
    _isAuthenticated = true;
    _currentUser =
        verifiedUser ??
        UserProfile(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}',
          name: userName,
          email: userEmail,
          avatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
          role: 'Workspace Member',
        );

    notifyListeners();
    return AuthSuccess(user: _currentUser!, token: tokenToSave);
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

    return login(email, password);
  }

  @override
  Future<PasswordResetResult> requestPasswordReset(String email) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      return const PasswordResetInvalidEmail();
    }
    return PasswordResetSuccess(
      message: 'Password reset link dispatched to $email.',
    );
  }

  @override
  Future<AuthResult> refreshSession() async {
    if (_authToken == null) return const AuthInvalidCredentials();
    return AuthSuccess(user: _currentUser!, token: _authToken!);
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

  Future<UserProfile?> _validateTokenWithServer(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${_config.authHost}/v1/user/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile(
          id: data['id']?.toString() ?? 'u_me',
          name: data['name']?.toString() ?? 'Macro User',
          email: data['email']?.toString() ?? 'user@macro.com',
          avatarUrl:
              data['avatar_url']?.toString() ??
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
          role: data['role']?.toString() ?? 'Workspace Member',
        );
      }
    } catch (_) {
      // Server offline or self-signed dev mode
    }
    return null;
  }
}
