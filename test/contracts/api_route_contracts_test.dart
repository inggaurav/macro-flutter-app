import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/config/macro_service_config.dart';
import 'package:macro_app/core/auth/auth_repository.dart';
import 'package:macro_app/core/storage/secure_key_value_store.dart';

void main() {
  group('Upstream endpoint contracts', () {
    final config = MacroServiceConfig.production();

    test('Macro service hosts match the verified upstream topology', () {
      expect(config.authHost, equals('https://auth-service.macro.com'));
      expect(config.storageHost, equals('https://cloud-storage.macro.com'));
      expect(config.searchHost, equals('https://cloud-storage.macro.com'));
      expect(config.emailHost, equals('https://email-service.macro.com'));
      expect(
        config.cognitionHost,
        equals('https://document-cognition.macro.com'),
      );
      expect(
        config.connectionGateway,
        equals('wss://connection-gateway.macro.com'),
      );
    });

    test('AuthRepository fails closed when secure storage is empty', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(storage: storage, config: config);
      final result = await authRepo.restoreSession();

      expect(result.isSuccess, isFalse);
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentUser, isNull);
      expect(authRepo.authToken, isNull);
      expect(authRepo.refreshToken, isNull);
    });

    test('Mobile SSO rejects unrelated deep links without network access', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(storage: storage, config: config);

      final result = await authRepo.completeMobileGoogleSignIn(
        Uri.parse('macro://google-link-callback'),
      );

      expect(result, isA<AuthValidationFailure>());
      expect(authRepo.isAuthenticated, isFalse);
    });

    test('Mobile SSO requires a one-time session code', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(storage: storage, config: config);

      final result = await authRepo.completeMobileGoogleSignIn(
        Uri.parse('macro://login'),
      );

      expect(result, isA<AuthValidationFailure>());
      expect(authRepo.isAuthenticated, isFalse);
    });
  });
}
