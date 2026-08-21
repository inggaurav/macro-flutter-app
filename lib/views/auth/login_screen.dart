import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/google/google_service.dart';
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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleWorkspaceLink() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final googleService = Provider.of<GoogleService>(context, listen: false);
    final launched = await googleService.initiateGoogleOAuth();

    if (mounted) {
      setState(() => _isLoading = false);
      if (launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Opening Google Workspace authorization in browser...',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              googleService.errorMessage ??
              'Could not initialize Google OAuth link.';
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(
        () => _errorMessage =
            'Please enter both work email and password/API token.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authRepo =
        widget.authRepository ??
        Provider.of<AuthRepository>(context, listen: false);

    // If input looks like an API bearer token, use token validation; otherwise use password login.
    final AuthResult result = password.length > 20 || email.contains('bearer_')
        ? await authRepo.login(email, password)
        : await authRepo.loginWithPassword(email, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result is AuthSuccess) {
        widget.onLoginSuccess();
      } else {
        setState(() {
          _errorMessage =
              result.message ??
              'Authentication failed. Invalid credentials or token.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfig>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
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
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: appConfig.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          appConfig.logoText,
                          style: AppTypography.titleLarge(
                            context,
                            color: Colors.white,
                          ),
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
                            'Collaborative Workspace',
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
                  'Sign In to Workspace',
                  style: AppTypography.titleLarge(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter your Macro credentials or Bearer API token',
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

                // Email Input
                Text('Work Email', style: AppTypography.caption(context)),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.body(context),
                  decoration: InputDecoration(
                    hintText: 'user@company.com',
                    hintStyle: AppTypography.bodySmall(
                      context,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Password / Token Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Password or API Token',
                      style: AppTypography.caption(context),
                    ),
                    GestureDetector(
                      onTap: widget.onNavigateToForgotPassword,
                      child: Text(
                        'Forgot?',
                        style: AppTypography.caption(
                          context,
                          color: appConfig.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: AppTypography.body(context),
                  decoration: InputDecoration(
                    hintText: 'Enter password or bearer token',
                    hintStyle: AppTypography.bodySmall(
                      context,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appConfig.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: AppTypography.body(
                              context,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.borderDark)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        'OR',
                        style: AppTypography.caption(
                          context,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.borderDark)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Google OAuth Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleWorkspaceLink,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.g_mobiledata,
                          size: 24,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Connect Gmail / Google Workspace',
                            style: AppTypography.body(
                              context,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x2l),

                // Footer Nav
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Don\'t have a workspace yet? ',
                        style: AppTypography.bodySmall(
                          context,
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onNavigateToSignup,
                      child: Text(
                        'Sign Up',
                        style: AppTypography.bodySmall(
                          context,
                          color: appConfig.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
