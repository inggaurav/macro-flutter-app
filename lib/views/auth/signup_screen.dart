import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  final AppConfig appConfig;
  final AuthRepository authRepository;
  final VoidCallback onNavToLogin;

  const SignupScreen({
    super.key,
    required this.appConfig,
    required this.authRepository,
    required this.onNavToLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.authRepository.signup(
      name: name,
      email: email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (!result.isSuccess) {
      setState(() => _errorMessage = result.message ?? 'Signup failed');
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
            constraints: const BoxConstraints(maxWidth: 420),
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
                      color: widget.appConfig.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        widget.appConfig.logoText,
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Create ${widget.appConfig.appName} Account',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join ${widget.appConfig.workspaceName} team workspace',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRose.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.accentRose.withOpacity(0.4)),
                      ),
                      child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.accentRose, fontSize: 12)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.bgDark,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 14),

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
                        backgroundColor: widget.appConfig.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _handleSignup,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create Account & Join', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onNavToLogin,
                    child: Text('Already have an account? Sign in', style: TextStyle(color: widget.appConfig.primaryColor)),
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
