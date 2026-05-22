import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/size_limit_cache.dart';

// SizeLimitCache TTL uses wall-clock DateTime.now(), which fake_async cannot
// advance, so the TTL test uses a short real delay instead.

void main() {
  group('SizeLimitCache', () {
    test('maxSize getter reflects the configured capacity', () {
      expect(SizeLimitCache<String, int>(3).maxSize, 3);
    });

    test('stores and retrieves values', () {
      final SizeLimitCache<String, int> c = SizeLimitCache<String, int>(3)..set('a', 1);
      expect(c.get('a'), 1);
    });

    test('get returns null for an absent key', () {
      expect(SizeLimitCache<String, int>(2).get('missing'), isNull);
    });

    test('evicts the oldest inserted entry at capacity (insertion order)', () {
      final SizeLimitCache<String, int> c = SizeLimitCache<String, int>(2)
        ..set('a', 1)
        ..set('b', 2)
        ..set('c', 3); // evicts 'a' (oldest)
      expect(c.get('a'), isNull); // evicted
      expect(c.get('b'), 2);
      expect(c.get('c'), 3);
    });

    test('reading does not affect eviction order (unlike LRU)', () {
      final SizeLimitCache<String, int> c = SizeLimitCache<String, int>(2)
        ..set('a', 1)
        ..set('b', 2);
      // Touch 'a' — must NOT promote it, since this is insertion-order eviction.
      expect(c.get('a'), 1);
      c.set('c', 3); // still evicts 'a' (oldest insert)
      expect(c.get('a'), isNull);
      expect(c.get('b'), 2);
      expect(c.get('c'), 3);
    });

    test('updating an existing key does not evict and keeps insertion order', () {
      final SizeLimitCache<String, int> c = SizeLimitCache<String, int>(2)
        ..set('a', 1)
        ..set('b', 2)
        ..set('a', 99); // update in place, no eviction
      expect(c.get('a'), 99);
      expect(c.get('b'), 2);
      c.set('c', 3); // 'a' is still the oldest insert -> evicted
      expect(c.get('a'), isNull);
      expect(c.get('b'), 2);
    });

    test('clear removes all entries', () {
      final SizeLimitCache<String, int> c = SizeLimitCache<String, int>(3)
        ..set('a', 1)
        ..set('b', 2)
        ..clear();
      expect(c.get('a'), isNull);
      expect(c.toString(), contains('length: 0'));
    });

    test('expired entries return null when a TTL is set', () async {
      final SizeLimitCache<String, int> c = SizeLimitCache<String, int>(
        3,
        ttl: const Duration(milliseconds: 20),
      )..set('a', 1);
      expect(c.get('a'), 1);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.get('a'), isNull); // expired
    });

    test('toString reports maxSize and length', () {
      final SizeLimitCache<String, int> c = SizeLimitCache<String, int>(4)..set('a', 1);
      expect(c.toString(), 'SizeLimitCache(maxSize: 4, length: 1)');
    });
  });
}
