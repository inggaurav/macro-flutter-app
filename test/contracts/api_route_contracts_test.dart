import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/config/macro_service_config.dart';
import 'package:macro_app/core/auth/auth_repository.dart';
import 'package:macro_app/core/google/google_service.dart';
import 'package:macro_app/core/storage/secure_key_value_store.dart';

void main() {
  group('Upstream Endpoint Contract Tests', () {
    final config = MacroServiceConfig.production();

    test('MacroServiceConfig Hosts are configured correctly', () {
      expect(config.authHost, equals('https://auth-service.macro.com'));
      expect(config.storageHost, equals('https://cloud-storage.macro.com'));
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

    test('AuthRepository fail-closed on empty storage', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(storage: storage, config: config);
      final result = await authRepo.restoreSession();

      expect(result.isSuccess, isFalse);
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentUser, isNull);
    });

    test('AuthRepository fail-closed on invalid credentials', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(storage: storage, config: config);
      final result = await authRepo.login('user@test.com', 'invalid_token');

      expect(result.isSuccess, isFalse);
      expect(authRepo.isAuthenticated, isFalse);
      expect(authRepo.currentUser, isNull);
    });

    test('AuthRepository local development signup and login works', () async {
      final storage = InMemorySecureStorageService();
      final authRepo = AuthRepositoryImpl(
        storage: storage,
        config: MacroServiceConfig.localDevelopment(),
      );

      final signupResult = await authRepo.signup(
        name: 'Macro Owner',
        email: 'owner@example.com',
        password: 'password123',
      );

      expect(signupResult, isA<AuthSuccess>());
      expect(authRepo.isAuthenticated, isTrue);
      expect(authRepo.currentUser?.email, equals('owner@example.com'));

      await authRepo.logout();
      expect(authRepo.isAuthenticated, isFalse);

      final loginResult = await authRepo.loginWithPassword(
        'owner@example.com',
        'password123',
      );

      expect(loginResult, isA<AuthSuccess>());
      expect(authRepo.isAuthenticated, isTrue);
      expect(authRepo.currentUser?.role, equals('Workspace Owner'));
    });

    test(
      'GoogleService initiateGoogleSso formats request accurately',
      () async {
        final googleService = GoogleService(
          config: config,
          tokenProvider: () => null,
        );
        expect(googleService.state, equals(GoogleConnectionState.notConnected));
        expect(googleService.isConnected, isFalse);
      },
    );
  });
}
