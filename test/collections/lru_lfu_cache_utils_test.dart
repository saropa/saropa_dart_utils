import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/lru_lfu_cache_utils.dart';

void main() {
  group('LruLfuCacheUtils constructor', () {
    test('should throw ArgumentError for negative capacity', () {
      expect(() => LruLfuCacheUtils<String, int>(-1), throwsArgumentError);
    });

    test('should allow capacity 0 and store nothing', () {
      final cache = LruLfuCacheUtils<String, int>(0)..put('a', 1);
      expect(cache.length, equals(0));
      expect(cache.get('a'), isNull);
    });

    test('should start empty', () {
      expect(LruLfuCacheUtils<String, int>(3).length, equals(0));
    });
  });

  group('get and put', () {
    test('should return stored value', () {
      final cache = LruLfuCacheUtils<String, int>(2)..put('a', 1);
      expect(cache.get('a'), 1);
    });

    test('should return null for a missing key', () {
      expect(LruLfuCacheUtils<String, int>(2).get('x'), isNull);
    });

    test('should not create an entry on a miss', () {
      final cache = LruLfuCacheUtils<String, int>(2)..get('ghost');
      expect(cache.length, equals(0));
    });

    test('should overwrite the value when putting an existing key', () {
      final cache = LruLfuCacheUtils<String, int>(2)
        ..put('a', 1)
        ..put('a', 99);
      expect(cache.get('a'), 99);
      expect(cache.length, equals(1));
    });

    test('should hold a single entry at capacity 1', () {
      final cache = LruLfuCacheUtils<String, int>(1)
        ..put('a', 1)
        ..put('b', 2);
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), 2);
      expect(cache.length, equals(1));
    });
  });

  group('eviction', () {
    test('should evict the least-frequently-used entry', () {
      // 'a' is accessed twice (frequency 3), 'b' once; inserting 'c' must drop
      // 'b' as the lowest-frequency victim.
      final cache = LruLfuCacheUtils<String, int>(2)
        ..put('a', 1)
        ..put('b', 2);
      cache
        ..get('a')
        ..get('a')
        ..put('c', 3);
      expect(cache.get('b'), isNull);
      expect(cache.get('a'), 1);
      expect(cache.get('c'), 3);
    });

    test('should break frequency ties by least-recently-used', () {
      // 'a' and 'b' both have frequency 1, but 'a' was inserted first and never
      // re-touched, so it is the staler tie and gets evicted.
      final cache = LruLfuCacheUtils<String, int>(2)
        ..put('a', 1)
        ..put('b', 2)
        ..put('c', 3);
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
    });

    test('should refresh recency via get to protect a frequency-tied entry', () {
      // After get('a'), 'a' has frequency 2 and is newest; 'b' (frequency 1) is
      // the clear victim when 'c' is inserted.
      final cache = LruLfuCacheUtils<String, int>(2)
        ..put('a', 1)
        ..put('b', 2);
      cache
        ..get('a')
        ..put('c', 3);
      expect(cache.get('b'), isNull);
      expect(cache.length, equals(2));
    });

    test('should stay within capacity across many inserts', () {
      final cache = LruLfuCacheUtils<int, int>(3);
      for (int i = 0; i < 100; i++) {
        cache.put(i, i);
      }
      expect(cache.length, equals(3));
    });
  });

  group('remove and length', () {
    test('should remove an existing key and return its value', () {
      final cache = LruLfuCacheUtils<String, int>(2)..put('a', 1);
      expect(cache.remove('a'), 1);
      expect(cache.get('a'), isNull);
      expect(cache.length, equals(0));
    });

    test('should return null when removing a missing key', () {
      expect(LruLfuCacheUtils<String, int>(2).remove('nope'), isNull);
    });

    test('should free a slot so a later put does not evict', () {
      final cache = LruLfuCacheUtils<String, int>(2)
        ..put('a', 1)
        ..put('b', 2)
        ..remove('a')
        ..put('c', 3);
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
      expect(cache.length, equals(2));
    });
  });

  group('toString', () {
    test('should report capacity and length', () {
      final cache = LruLfuCacheUtils<String, int>(5)..put('a', 1);
      expect(cache.toString(), 'LruLfuCacheUtils(capacity: 5, length: 1)');
    });
  });
}
