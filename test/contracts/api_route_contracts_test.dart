import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/config/macro_service_config.dart';
import 'package:macro_app/core/auth/auth_repository.dart';
import 'package:macro_app/features/inbox/inbox_repository.dart';
import 'package:macro_app/features/chat/chat_repository.dart';
import 'package:macro_app/features/agents/agent_repository.dart';
import 'package:macro_app/features/docs/docs_repository.dart';
import 'package:macro_app/features/tasks/tasks_repository.dart';
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
  });
}
