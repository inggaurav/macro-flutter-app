import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final AppConfig appConfig;
  final VoidCallback onOnboardingComplete;

  const OnboardingScreen({
    super.key,
    required this.appConfig,
    required this.onOnboardingComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.appConfig.onboardingPages;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onOnboardingComplete,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigo.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 64,
                            color: AppTheme.primaryIndigo,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator Dots & Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (idx) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == idx ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == idx
                              ? AppTheme.primaryIndigo
                              : AppTheme.borderDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        widget.onOnboardingComplete();
                      }
                    },
                    child: Text(
                      _currentPage == pages.length - 1 ? 'Get Started' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
