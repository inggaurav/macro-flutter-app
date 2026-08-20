import '../core/storage/secure_key_value_store.dart';

class SecureStorageService implements SecureKeyValueStore {
  final SecureKeyValueStore _innerStore;

  SecureStorageService([SecureKeyValueStore? store])
    : _innerStore = store ?? PlatformSecureStorageService();

  @override
  Future<void> write(String key, String value) => _innerStore.write(key, value);

  @override
  Future<String?> read(String key) => _innerStore.read(key);

  @override
  Future<void> delete(String key) => _innerStore.delete(key);

  @override
  Future<void> clear() => _innerStore.clear();
}
