import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureKeyValueStore {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class PlatformSecureStorageService implements SecureKeyValueStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('PlatformSecureStorage write error: $e');
      InMemorySecureStorageService.fallbackStorage[key] = value;
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
      return InMemorySecureStorageService.fallbackStorage[key];
    } catch (e) {
      debugPrint('PlatformSecureStorage read error: $e');
      return InMemorySecureStorageService.fallbackStorage[key];
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('PlatformSecureStorage delete error: $e');
    }
    InMemorySecureStorageService.fallbackStorage.remove(key);
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('PlatformSecureStorage clear error: $e');
    }
    InMemorySecureStorageService.fallbackStorage.clear();
  }
}

class InMemorySecureStorageService implements SecureKeyValueStore {
  static final Map<String, String> fallbackStorage = {};
  final Map<String, String> _data = fallbackStorage;

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _data[key];
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}
