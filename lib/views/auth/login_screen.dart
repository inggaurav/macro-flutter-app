import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../core/auth/auth_repository.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_spacing.dart';
import '../../design/tokens/app_typography.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToSignup;
  final VoidCallback onNavigateToForgotPassword;
  final AuthRepository? authRepository;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToSignup,
    required this.onNavigateToForgotPassword,
    this.authRepository,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _showPasswordLogin = false;
  String? _errorMessage;

  AuthRepository get _authRepo =>
      widget.authRepository ??
      Provider.of<AuthRepository>(context, listen: false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final launched = await _authRepo.startGoogleSignIn();
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (!launched) {
      setState(() {
        _errorMessage = 'Could not open Google sign-in. Please try again.';
      });
    }
  }

  Future<void> _handlePasswordLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Enter your email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authRepo.loginWithPassword(email, password);
    if (!mounted) return;

    setState(() => _isLoading = false);
    if (result is AuthSuccess) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _errorMessage = result.message ?? 'Authentication failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(AppSpacing.x2l),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: appConfig.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          appConfig.logoText,
                          style: AppTypography.titleLarge(
                            context,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appConfig.appName,
                              style: AppTypography.titleLarge(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'One workspace for mail, calendar, chat and AI',
                              style: AppTypography.caption(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2l),
                  Text(
                    'Welcome back',
                    style: AppTypography.titleLarge(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in with Google to use your workspace. Gmail and Calendar permissions are connected separately and can be managed at any time.',
                    style: AppTypography.bodySmall(
                      context,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall(
                          context,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF202124),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata_rounded, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(
                              () => _showPasswordLogin = !_showPasswordLogin,
                            ),
                      child: Text(
                        _showPasswordLogin
                            ? 'Hide email/password sign in'
                            : 'Use email and password instead',
                        style: AppTypography.bodySmall(
                          context,
                          color: appConfig.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  if (_showPasswordLogin) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text('Email', style: AppTypography.caption(context)),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: AppTypography.body(context),
                      decoration: InputDecoration(
                        hintText: 'user@company.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: AppTypography.caption(context)),
                        TextButton(
                          onPressed: widget.onNavigateToForgotPassword,
                          child: const Text('Need a sign-in link?'),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      autofillHints: const [AutofillHints.password],
                      style: AppTypography.body(context),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handlePasswordLogin,
                        child: const Text('Sign in with password'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.x2l),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'New workspace? ',
                          style: AppTypography.bodySmall(
                            context,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onNavigateToSignup,
                        child: const Text('Create account'),
                      ),
                    ],
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
