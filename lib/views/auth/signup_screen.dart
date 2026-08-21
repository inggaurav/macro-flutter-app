import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../design/components/app_button.dart';
import '../../design/tokens/app_colors.dart';
import '../../design/tokens/app_radius.dart';
import '../../design/tokens/app_spacing.dart';
import '../../design/tokens/app_typography.dart';
import '../../repositories/auth_repository.dart';

class SignupScreen extends StatefulWidget {
  final AppConfig appConfig;
  final AuthRepository? authRepository;
  final VoidCallback? onSignupSuccess;
  final VoidCallback? onNavigateLogin;
  final VoidCallback? onNavToLogin;

  const SignupScreen({
    super.key,
    required this.appConfig,
    this.authRepository,
    this.onSignupSuccess,
    this.onNavigateLogin,
    this.onNavToLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please complete all required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final result = await authRepo.signup(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result is AuthSuccess) {
      widget.onSignupSuccess?.call();
    } else {
      setState(() => _errorMessage = 'Failed to create workspace account.');
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
                    'Create Workspace Account',
                    style: AppTypography.titleLarge(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Get started with ${widget.appConfig.appName}',
                    style: AppTypography.bodySmall(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x2l),

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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: AppTypography.sectionTitle(
                          context,
                        ).copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _nameController,
                        style: AppTypography.body(
                          context,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Alex Rivera',
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
                            Icons.person_outline,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: AppTypography.sectionTitle(
                          context,
                        ).copyWith(fontSize: 12),
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
                          hintText: 'At least 8 characters',
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
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2l),

                  AppButton(
                    label: 'Create Account & Workspace',
                    onPressed: _handleSignup,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: AppSpacing.x2l),

                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodySmall(context),
                      ),
                      GestureDetector(
                        onTap: widget.onNavigateLogin ?? widget.onNavToLogin,
                        child: Text(
                          'Sign in',
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
