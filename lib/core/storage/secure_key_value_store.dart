import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageException implements Exception {
  final String message;
  final dynamic cause;

  const SecureStorageException(this.message, [this.cause]);

  @override
  String toString() =>
      'SecureStorageException: $message ${cause != null ? '($cause)' : ''}';
}

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
      if (kDebugMode) debugPrint('PlatformSecureStorage write error: $e');
      throw SecureStorageException(
        'Failed to write key "$key" to platform secure storage.',
        e,
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kDebugMode) debugPrint('PlatformSecureStorage read error: $e');
      throw SecureStorageException(
        'Failed to read key "$key" from platform secure storage.',
        e,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (kDebugMode) debugPrint('PlatformSecureStorage delete error: $e');
      throw SecureStorageException(
        'Failed to delete key "$key" from platform secure storage.',
        e,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (kDebugMode) debugPrint('PlatformSecureStorage clear error: $e');
      throw SecureStorageException(
        'Failed to clear platform secure storage.',
        e,
      );
    }
  }
}

class InMemorySecureStorageService implements SecureKeyValueStore {
  final Map<String, String> _data = {};

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
