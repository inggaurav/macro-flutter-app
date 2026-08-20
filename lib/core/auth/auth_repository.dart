import 'package:flutter/foundation.dart';
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
  const AuthInvalidCredentials({String message = 'Invalid email or password.'})
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
  const PasswordResetInvalidEmail({String message = 'Please enter a valid work email address.'})
      : super(isSuccess: false, message: message);
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
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> signup({required String name, required String email, required String password});
  Future<PasswordResetResult> requestPasswordReset(String email);
  Future<AuthResult> refreshSession();
  Future<void> logout();
}

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  final SecureKeyValueStore _storage;

  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  String? _authToken;
  UserProfile? _currentUser;

  AuthRepositoryImpl({SecureKeyValueStore? storage})
      : _storage = storage ?? PlatformSecureStorageService();

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
      _authToken = storedToken;
      _isAuthenticated = true;
      _currentUser = UserProfile(
        id: 'u_restored',
        name: storedName ?? 'Alex Rivera',
        email: storedEmail ?? 'alex@macro.inc',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        role: 'Lead Architect',
      );
      notifyListeners();
      return AuthSuccess(user: _currentUser!, token: _authToken!);
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
  Future<AuthResult> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return const AuthValidationFailure(message: 'Email and password cannot be empty.');
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final token = 'macro_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    final name = email.contains('@') ? email.split('@')[0] : email;

    await _storage.write('auth_token', token);
    await _storage.write('user_name', name);
    await _storage.write('user_email', email);

    _authToken = token;
    _isAuthenticated = true;
    _currentUser = UserProfile(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      role: 'Workspace Member',
    );
    notifyListeners();
    return AuthSuccess(user: _currentUser!, token: token);
  }

  @override
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      return const AuthValidationFailure(message: 'Name, email, and password are required.');
    }

    await Future.delayed(const Duration(milliseconds: 400));
    final token = 'macro_jwt_token_signup_${DateTime.now().millisecondsSinceEpoch}';

    await _storage.write('auth_token', token);
    await _storage.write('user_name', name);
    await _storage.write('user_email', email);

    _authToken = token;
    _isAuthenticated = true;
    _currentUser = UserProfile(
      id: 'u_new_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      role: 'Workspace Member',
    );
    notifyListeners();
    return AuthSuccess(user: _currentUser!, token: token);
  }

  @override
  Future<PasswordResetResult> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (email.trim().isEmpty || !email.contains('@')) {
      return const PasswordResetInvalidEmail();
    }
    return PasswordResetSuccess(message: 'Password reset link dispatched to $email.');
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
}
