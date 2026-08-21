import '../networking/api_client.dart';
import 'auth_repository.dart';

class AuthRepositoryTokenProvider implements AuthTokenProvider {
  final AuthRepository authRepository;

  AuthRepositoryTokenProvider(this.authRepository);

  @override
  Future<String?> getAccessToken() async {
    return authRepository.authToken;
  }

  @override
  Future<bool> refreshSession() async {
    final result = await authRepository.refreshSession();
    return result is AuthSuccess;
  }

  @override
  Future<void> clearSession() async {
    await authRepository.logout();
  }
}
