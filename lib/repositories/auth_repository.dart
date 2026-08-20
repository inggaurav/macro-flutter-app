import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/secure_storage_service.dart';

class AuthResult {
  final bool isSuccess;
  final String? message;
  final UserProfile? user;

  const AuthResult({
    required this.isSuccess,
    this.message,
    this.user,
  });
}

class AuthRepository extends ChangeNotifier {
  final SecureStorageService _storage = SecureStorageService();

  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  String? _authToken;
  UserProfile? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get authToken => _authToken;
  UserProfile? get currentUser => _currentUser;

  Future<bool> restoreSession() async {
    final storedToken = await _storage.read(key: 'auth_token');
    final storedOnboarded = await _storage.read(key: 'has_onboarded');
    final storedName = await _storage.read(key: 'user_name');
    final storedEmail = await _storage.read(key: 'user_email');

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
      return true;
    } else {
      _isAuthenticated = false;
      _authToken = null;
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _storage.write(key: 'has_onboarded', value: 'true');
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final token = 'macro_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    final name = email.contains('@') ? email.split('@')[0] : email;

    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_email', value: email);

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
    return AuthResult(isSuccess: true, user: _currentUser);
  }

  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final token = 'macro_jwt_token_signup_${DateTime.now().millisecondsSinceEpoch}';

    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_email', value: email);

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
    return AuthResult(isSuccess: true, user: _currentUser);
  }

  Future<AuthResult> requestPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.isEmpty || !email.contains('@')) {
      return const AuthResult(isSuccess: false, message: 'Please enter a valid work email address');
    }
    return AuthResult(
      isSuccess: true,
      message: 'Password reset link sent to $email',
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
    _isAuthenticated = false;
    _authToken = null;
    _currentUser = null;
    notifyListeners();
  }
}
