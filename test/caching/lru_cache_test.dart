import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/lru_cache.dart';

// LruCache TTL uses wall-clock DateTime.now(), which fake_async cannot advance,
// so the TTL tests use short real delays instead.

void main() {
  group('LruCache', () {
    test('maxSize getter reflects the configured capacity', () {
      expect(LruCache<String, int>(3).maxSize, 3);
    });

    test('get returns null for an absent key', () {
      expect(LruCache<String, int>(2).get('missing'), isNull);
    });

    test('evicts the least-recently-used entry at capacity', () {
      final LruCache<String, int> c = LruCache<String, int>(2)
        ..set('a', 1)
        ..set('b', 2)
        ..set('c', 3); // capacity 2 -> 'a' evicted
      expect(c.get('a'), isNull); // evicted
      expect(c.get('b'), 2);
      expect(c.get('c'), 3);
    });

    test('get promotes a key so it is not the next eviction target', () {
      final LruCache<String, int> c = LruCache<String, int>(2)
        ..set('a', 1)
        ..set('b', 2);
      // Touch 'a' so 'b' becomes least-recently-used.
      expect(c.get('a'), 1);
      c.set('c', 3); // evicts 'b', not 'a'
      expect(c.get('a'), 1);
      expect(c.get('b'), isNull); // evicted
      expect(c.get('c'), 3);
    });

    test('re-setting an existing key updates value without evicting others', () {
      final LruCache<String, int> c = LruCache<String, int>(2)
        ..set('a', 1)
        ..set('b', 2)
        ..set('a', 99); // update, also promotes 'a'
      expect(c.get('a'), 99);
      expect(c, hasLength(2));
      c.set('c', 3); // 'b' is LRU now -> evicted
      expect(c.get('b'), isNull);
      expect(c.get('a'), 99);
    });

    test('length reflects the number of stored entries', () {
      final LruCache<String, int> c = LruCache<String, int>(5);
      expect(c, hasLength(0));
      c.set('a', 1);
      c.set('b', 2);
      expect(c, hasLength(2));
    });

    test('clear removes all entries', () {
      final LruCache<String, int> c = LruCache<String, int>(3)
        ..set('a', 1)
        ..set('b', 2)
        ..clear();
      expect(c, hasLength(0));
      expect(c.get('a'), isNull);
    });

    test('expired entries return null when a TTL is set', () async {
      final LruCache<String, int> c = LruCache<String, int>(
        3,
        ttl: const Duration(milliseconds: 20),
      )..set('a', 1);
      expect(c.get('a'), 1); // fresh
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.get('a'), isNull); // expired
      expect(c, hasLength(0)); // expired entry purged
    });

    test('non-expired entries within TTL are still returned', () {
      final LruCache<String, int> c = LruCache<String, int>(
        3,
        ttl: const Duration(seconds: 30),
      )..set('a', 1);
      expect(c.get('a'), 1);
    });

    test('toString reports maxSize and length', () {
      final LruCache<String, int> c = LruCache<String, int>(4)..set('a', 1);
      expect(c.toString(), 'LruCache(maxSize: 4, length: 1)');
    });
  });
}
