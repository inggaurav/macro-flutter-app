import '../../config/app_config.dart';
import '../auth/auth_repository.dart';

enum StartupState {
  initializing,
  loadingConfig,
  openingStorage,
  restoringSession,
  ready,
  recoverableFailure,
  fatalFailure,
}

enum AppDestination {
  splash,
  onboarding,
  login,
  signup,
  forgotPassword,
  workspace,
}

class StartupResult {
  final StartupState state;
  final AppDestination destination;
  final bool hasSession;
  final bool hasOnboarded;
  final String statusMessage;

  const StartupResult({
    required this.state,
    required this.destination,
    required this.hasSession,
    required this.hasOnboarded,
    required this.statusMessage,
  });
}

class StartupService {
  final AppConfig appConfig;
  final AuthRepository authRepository;

  StartupService({required this.appConfig, required this.authRepository});

  Future<StartupResult> executeStartupPipeline(
    Function(StartupState, String) onProgress,
  ) async {
    onProgress(
      StartupState.initializing,
      'Initializing ${appConfig.appName} engine...',
    );
    await Future.delayed(const Duration(milliseconds: 150));

    onProgress(
      StartupState.loadingConfig,
      'Evaluating runtime configuration (${appConfig.environment.name})...',
    );
    await Future.delayed(const Duration(milliseconds: 150));

    onProgress(
      StartupState.openingStorage,
      'Opening secure platform storage...',
    );
    await Future.delayed(const Duration(milliseconds: 150));

    onProgress(StartupState.restoringSession, 'Restoring user session...');
    final authResult = await authRepository.restoreSession();

    onProgress(StartupState.ready, 'Boot sequence complete.');

    final hasSession = authResult is AuthSuccess;
    final hasOnboarded = authRepository.hasCompletedOnboarding;

    AppDestination destination;
    if (!hasOnboarded) {
      destination = AppDestination.onboarding;
    } else if (!hasSession) {
      destination = AppDestination.login;
    } else {
      destination = AppDestination.workspace;
    }

    return StartupResult(
      state: StartupState.ready,
      destination: destination,
      hasSession: hasSession,
      hasOnboarded: hasOnboarded,
      statusMessage: 'Ready',
    );
  }
}
