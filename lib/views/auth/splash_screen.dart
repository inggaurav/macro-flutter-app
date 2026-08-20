import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/startup/startup_service.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final AppConfig appConfig;
  final AuthRepository authRepository;
  final Function(StartupResult) onInitComplete;

  const SplashScreen({
    super.key,
    required this.appConfig,
    required this.authRepository,
    required this.onInitComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'Booting Application Engine...';

  @override
  void initState() {
    super.initState();
    _runStartupPipeline();
  }

  Future<void> _runStartupPipeline() async {
    final startupService = StartupService(
      appConfig: widget.appConfig,
      authRepository: widget.authRepository,
    );

    final result = await startupService.executeStartupPipeline((
      state,
      message,
    ) {
      if (mounted) {
        setState(() => _statusText = message);
      }
    });

    if (mounted) {
      widget.onInitComplete(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: widget.appConfig.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.appConfig.primaryColor.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.appConfig.logoText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.appConfig.appName.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.appConfig.workspaceName,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: widget.appConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusText,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
