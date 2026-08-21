import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/core/storage/secure_key_value_store.dart';

void main() {
  group('SecureKeyValueStore Tests', () {
    test('InMemorySecureStorageService CRUD operations', () async {
      final store = InMemorySecureStorageService();
      await store.clear();

      expect(await store.read('token'), isNull);

      await store.write('token', 'secret_jwt_123');
      expect(await store.read('token'), 'secret_jwt_123');

      await store.delete('token');
      expect(await store.read('token'), isNull);

      await store.write('k1', 'v1');
      await store.write('k2', 'v2');
      await store.clear();
      expect(await store.read('k1'), isNull);
      expect(await store.read('k2'), isNull);
    });

    test('SecureStorageException toString formatting', () {
      const ex = SecureStorageException('Access Denied', 'Keystore locked');
      expect(
        ex.toString(),
        contains('SecureStorageException: Access Denied (Keystore locked)'),
      );
    });
  });
}
