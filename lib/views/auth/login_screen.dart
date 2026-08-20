import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.authRepository,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'alex@macro.inc');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final success = await widget.authRepository.login(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('M', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign in to Macro',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your workspace credentials or Google SSO',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 28),

                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Work Email',
                      labelStyle: TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Continue to Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
