import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/lru_cache.dart';
import 'package:saropa_dart_utils/caching/memoize_sync_utils.dart';
import 'package:saropa_dart_utils/caching/ttl_cache.dart';

void main() {
  group('LruCache', () {
    test('evicts oldest', () {
      final LruCache<String, int> c = LruCache<String, int>(2);
      c.set('a', 1);
      c.set('b', 2);
      c.set('c', 3);
      expect(c.get('a'), isNull);
      expect(c.get('b'), 2);
      expect(c.get('c'), 3);
    });
  });
  group('TtlCache', () {
    test('get returns value', () {
      final TtlCache<String, int> c = TtlCache<String, int>(Duration(minutes: 5));
      c.set('x', 1);
      expect(c.get('x'), 1);
    });
  });
  group('memoize1', () {
    test('caches by argument', () {
      int calls = 0;
      final int Function(int) fn = memoize1((int x) => ++calls + x);
      expect(fn(1), 2);
      expect(fn(1), 2);
      expect(calls, 1);
    });
  });
  group('singleValueCache', () {
    test('computes once', () {
      int calls = 0;
      final int Function() get = singleValueCache(() => ++calls);
      expect(get(), 1);
      expect(get(), 1);
      expect(calls, 1);
    });
  });
}
