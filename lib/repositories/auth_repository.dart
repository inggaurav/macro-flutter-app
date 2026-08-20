import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/secure_storage_service.dart';

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

    _hasCompletedOnboarding = storedOnboarded == 'true';

    if (storedToken != null && storedToken.isNotEmpty) {
      _authToken = storedToken;
      _isAuthenticated = true;
      _currentUser = const UserProfile(
        id: 'u1',
        name: 'Alex Rivera',
        email: 'alex@macro.inc',
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

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final token = 'macro_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    await _storage.write(key: 'auth_token', value: token);

    _authToken = token;
    _isAuthenticated = true;
    _currentUser = UserProfile(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: email.contains('@') ? email.split('@')[0] : email,
      email: email.contains('@') ? email : '$email@macro.inc',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      role: 'Workspace Member',
    );
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _isAuthenticated = false;
    _authToken = null;
    _currentUser = null;
    notifyListeners();
  }
}
