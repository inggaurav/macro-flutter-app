import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum CachePolicy { cacheFirst, networkFirst, staleWhileRevalidate }

abstract interface class LocalCacheStore {
  Future<void> put(String key, dynamic value, {Duration? ttl});
  Future<dynamic> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesLocalCacheStore implements LocalCacheStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    final prefs = await _getPrefs();
    final entry = _CacheEntry(
      value: value,
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
    );
    final jsonStr = jsonEncode(entry.toJson());
    await prefs.setString('cache_$key', jsonStr);
  }

  @override
  Future<dynamic> get(String key) async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString('cache_$key');
    if (jsonStr == null) return null;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final entry = _CacheEntry.fromJson(map);
      if (entry.isExpired) {
        await prefs.remove('cache_$key');
        return null;
      }
      return entry.value;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove('cache_$key');
  }

  @override
  Future<void> clear() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

class InMemoryLocalCacheStore implements LocalCacheStore {
  static final Map<String, _CacheEntry> _store = {};

  @override
  Future<void> put(String key, dynamic value, {Duration? ttl}) async {
    _store[key] = _CacheEntry(
      value: value,
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
    );
  }

  @override
  Future<dynamic> get(String key) async {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime? expiresAt;

  const _CacheEntry({required this.value, this.expiresAt});

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Map<String, dynamic> toJson() => {
    'value': value,
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory _CacheEntry.fromJson(Map<String, dynamic> json) => _CacheEntry(
    value: json['value'],
    expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'])
        : null,
  );
}
