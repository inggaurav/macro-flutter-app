import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AuthRepository extends ChangeNotifier {
  bool _isAuthenticated = true;
  UserProfile? _currentUser = const UserProfile(
    id: 'u1',
    name: 'Alex Rivera',
    email: 'alex@macro.inc',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    role: 'Lead Architect',
  );

  bool get isAuthenticated => _isAuthenticated;
  UserProfile? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _isAuthenticated = true;
    _currentUser = UserProfile(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@')[0],
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
      role: 'Member',
    );
    notifyListeners();
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
