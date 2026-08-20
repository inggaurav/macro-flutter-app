import 'package:flutter/foundation.dart';

class SecureStorageService {
  static final Map<String, String> _memoryStorage = {};

  Future<void> write({required String key, required String value}) async {
    _memoryStorage[key] = value;
  }

  Future<String?> read({required String key}) async {
    return _memoryStorage[key];
  }

  Future<void> delete({required String key}) async {
    _memoryStorage.remove(key);
  }

  Future<void> clear() async {
    _memoryStorage.clear();
  }
}
