import '../config/app_config.dart';
import '../repositories/auth_repository.dart';

class StartupResult {
  final bool hasSession;
  final bool hasOnboarded;
  final String statusMessage;

  const StartupResult({
    required this.hasSession,
    required this.hasOnboarded,
    required this.statusMessage,
  });
}

class StartupService {
  final AppConfig appConfig;
  final AuthRepository authRepository;

  StartupService({
    required this.appConfig,
    required this.authRepository,
  });

  Future<StartupResult> executeStartupPipeline(Function(String) onProgress) async {
    onProgress('Loading ${appConfig.appName} configuration...');
    await Future.delayed(const Duration(milliseconds: 250));

    onProgress('Evaluating feature flags (${appConfig.environment.name})...');
    await Future.delayed(const Duration(milliseconds: 200));

    onProgress('Checking local secure session storage...');
    final hasSession = await authRepository.restoreSession();

    onProgress('Verifying onboarding state...');
    await Future.delayed(const Duration(milliseconds: 200));

    return StartupResult(
      hasSession: hasSession,
      hasOnboarded: authRepository.hasCompletedOnboarding,
      statusMessage: 'Ready',
    );
  }
}
