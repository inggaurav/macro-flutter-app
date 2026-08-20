import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../repositories/auth_repository.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final AppConfig appConfig;
  final AuthRepository authRepository;
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({
    super.key,
    required this.appConfig,
    required this.authRepository,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await widget.authRepository.requestPasswordReset(email);
    setState(() {
      _isLoading = false;
      _isSuccess = result.isSuccess;
      _statusMessage = result.message;
    });
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
                  Icon(Icons.lock_reset, size: 48, color: widget.appConfig.primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Reset Password',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your work email to receive a password reset link',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (_statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isSuccess ? AppTheme.accentEmerald.withOpacity(0.15) : AppTheme.accentRose.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _isSuccess ? AppTheme.accentEmerald.withOpacity(0.4) : AppTheme.accentRose.withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          Icon(_isSuccess ? Icons.check_circle_outline : Icons.error_outline, color: _isSuccess ? AppTheme.accentEmerald : AppTheme.accentRose, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            _statusMessage!,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.appConfig.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _handleReset,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: widget.onBackToLogin,
                    child: Text('Back to Sign in', style: TextStyle(color: widget.appConfig.primaryColor)),
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
