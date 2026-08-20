enum CachePolicy { cacheFirst, networkFirst, staleWhileRevalidate }

abstract interface class LocalCacheStore {
  Future<void> put(String key, dynamic value, {Duration? ttl});
  Future<dynamic> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
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
}
