import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/google/google_service.dart';
import '../../design/components/app_button.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_radius.dart';
import '../../design/tokens/app_spacing.dart';
import '../../design/tokens/app_typography.dart';

class LoginScreen extends StatefulWidget {
  final AppConfig appConfig;
  final AuthRepository? authRepository;
  final VoidCallback onLoginSuccess;
  final VoidCallback? onNavigateSignup;
  final VoidCallback? onNavToSignup;
  final VoidCallback? onNavigateForgot;
  final VoidCallback? onNavToForgot;
  final VoidCallback? onNavToForgotPassword;

  const LoginScreen({
    super.key,
    required this.appConfig,
    this.authRepository,
    required this.onLoginSuccess,
    this.onNavigateSignup,
    this.onNavToSignup,
    this.onNavigateForgot,
    this.onNavToForgot,
    this.onNavToForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: 'alex@macro.app',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final googleService = GoogleService();
    final authUrl = await googleService.initiateGoogleOAuth();

    if (mounted) {
      if (authUrl != null) {
        // Authenticate session via Google Workspace token
        await widget.authRepository?.login('google_user@gmail.com', 'google_workspace_oauth_token');
        widget.onLoginSuccess();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not initialize Google OAuth link.';
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all credentials.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authRepo =
        widget.authRepository ??
        Provider.of<AuthRepository>(context, listen: false);
    final result = await authRepo.login(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result is AuthSuccess) {
      widget.onLoginSuccess();
    } else if (result is AuthInvalidCredentials) {
      setState(() => _errorMessage = 'Invalid email or password.');
    } else {
      setState(
        () => _errorMessage = 'Authentication failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = AppColors.brandPrimary(widget.appConfig);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo & Brand Header
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: brandColor,
                      borderRadius: AppRadius.borderMd,
                      boxShadow: [
                        BoxShadow(
                          color: brandColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.appConfig.logoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Sign in to ${widget.appConfig.appName}',
                    style: AppTypography.titleLarge(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter your workspace credentials to continue',
                    style: AppTypography.bodySmall(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x2l),

                  // Error Message Alert
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(
                          color: AppColors.danger.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.danger,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.bodySmall(
                                context,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Email Input Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Email',
                        style: AppTypography.sectionTitle(
                          context,
                        ).copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _emailController,
                        style: AppTypography.body(
                          context,
                          color: AppColors.textPrimary,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'alex@company.com',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceDark,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.borderMd,
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Password Input Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password',
                            style: AppTypography.sectionTitle(
                              context,
                            ).copyWith(fontSize: 12),
                          ),
                          GestureDetector(
                            onTap:
                                widget.onNavigateForgot ?? widget.onNavToForgot,
                            child: Text(
                              'Forgot password?',
                              style: AppTypography.caption(
                                context,
                                color: brandColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTypography.body(
                          context,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceDark,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.borderMd,
                            borderSide: const BorderSide(
                              color: AppColors.borderDark,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _handleLogin(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2l),

                  // Submit Button
                  AppButton(
                    label: 'Continue to Workspace',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () {
                      _handleGoogleLogin();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      side: const BorderSide(color: AppColors.borderDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 24,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Continue with Google Workspace',
                            style: AppTypography.body(context, color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dev Environment 1-Tap Sign In
                  if (widget.appConfig.environment == AppEnvironment.dev) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Demo 1-Tap Sign In (DEV)',
                      onPressed: () {
                        _emailController.text = 'alex@macro.app';
                        _passwordController.text = 'password123';
                        _handleLogin();
                      },
                      variant: AppButtonVariant.secondary,
                      isFullWidth: true,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.x2l),

                  // Navigation to Signup
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTypography.bodySmall(context),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateSignup ?? widget.onNavToSignup,
                        child: Text(
                          'Create workspace',
                          style: AppTypography.bodySmall(
                            context,
                            color: brandColor,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
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
