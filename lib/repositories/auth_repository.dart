import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AuthRepository extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = true; // Default true, can be toggled
  String? _authToken;
  UserProfile? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get authToken => _authToken;
  UserProfile? get currentUser => _currentUser;

  Future<void> restoreSession() async {
    // Simulate reading secure storage token
    await Future.delayed(const Duration(milliseconds: 400));
    _authToken = 'macro_jwt_sec_mock_token_9402';
    _isAuthenticated = true;
    _currentUser = const UserProfile(
      id: 'u1',
      name: 'Alex Rivera',
      email: 'alex@macro.inc',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      role: 'Lead Architect',
    );
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _authToken = 'macro_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
    _isAuthenticated = true;
    _currentUser = UserProfile(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: email.contains('@') ? email.split('@')[0] : email,
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      role: 'Workspace Member',
    );
    notifyListeners();
    return true;
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _authToken = null;
    _currentUser = null;
    notifyListeners();
  }
}
