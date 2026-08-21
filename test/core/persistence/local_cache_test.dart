import 'package:flutter_test/flutter_test.dart';
import 'package:macro_app/core/persistence/local_cache.dart';

void main() {
  group('LocalCacheStore Tests', () {
    test(
      'InMemoryLocalCacheStore put, get, remove, clear and TTL expiration',
      () async {
        final cache = InMemoryLocalCacheStore();
        await cache.clear();

        await cache.put('key1', {'name': 'Macro'});
        final val = await cache.get('key1');
        expect(val, equals({'name': 'Macro'}));

        await cache.remove('key1');
        expect(await cache.get('key1'), isNull);

        // Test TTL expiration
        await cache.put(
          'tempKey',
          'tempVal',
          ttl: const Duration(milliseconds: 50),
        );
        expect(await cache.get('tempKey'), equals('tempVal'));

        await Future.delayed(const Duration(milliseconds: 60));
        expect(await cache.get('tempKey'), isNull);
      },
    );
  });
}
