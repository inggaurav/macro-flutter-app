import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitComplete;

  const SplashScreen({super.key, required this.onInitComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        widget.onInitComplete();
      }
    });
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
                color: AppTheme.primaryIndigo,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MACRO WORKSPACE',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unified Team Intelligence & Swarm Memory',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primaryIndigo),
            ),
          ],
        ),
      ),
    );
  }
}
