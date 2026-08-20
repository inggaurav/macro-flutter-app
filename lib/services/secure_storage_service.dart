import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final Map<String, String> _memoryFallback = {};

  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureStorage write fallback: $e');
      _memoryFallback[key] = value;
    }
  }

  Future<String?> read({required String key}) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
      return _memoryFallback[key];
    } catch (e) {
      debugPrint('SecureStorage read fallback: $e');
      return _memoryFallback[key];
    }
  }

  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('SecureStorage delete fallback: $e');
    }
    _memoryFallback.remove(key);
  }

  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('SecureStorage clear fallback: $e');
    }
    _memoryFallback.clear();
  }
}
