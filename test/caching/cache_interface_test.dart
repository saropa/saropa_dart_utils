import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/cache_interface.dart';
import 'package:saropa_dart_utils/caching/lru_cache.dart';
import 'package:saropa_dart_utils/caching/size_limit_cache.dart';
import 'package:saropa_dart_utils/caching/ttl_cache.dart';

void main() {
  group('Cache interface conformance', () {
    test('LruCache, TtlCache, SizeLimitCache are all a Cache', () {
      expect(LruCache<String, int>(2), isA<Cache<String, int>>());
      expect(TtlCache<String, int>(const Duration(minutes: 1)), isA<Cache<String, int>>());
      expect(SizeLimitCache<String, int>(2), isA<Cache<String, int>>());
    });

    test('a consumer can depend on Cache without the concrete policy', () {
      final Cache<String, int> cache = LruCache<String, int>(8);
      cache.set('a', 1);
      expect(cache.get('a'), 1);
      cache.clear();
      expect(cache.get('a'), isNull);
    });
  });

  group('WriteThroughCache', () {
    test('loads a miss once, then serves from cache', () async {
      int loads = 0;
      final WriteThroughCache<String, int> wt = WriteThroughCache<String, int>(
        LruCache<String, int>(8),
        (String k) async {
          loads++;
          return k.length;
        },
      );
      expect(await wt.getOrLoad('abc'), 3);
      expect(await wt.getOrLoad('abc'), 3);
      expect(loads, 1); // second call hit the cache
    });

    test('concurrent misses for the same key share one load', () async {
      int loads = 0;
      final Completer<int> gate = Completer<int>();
      final WriteThroughCache<String, int> wt = WriteThroughCache<String, int>(
        LruCache<String, int>(8),
        (String k) {
          loads++;
          return gate.future;
        },
      );
      final Future<int> a = wt.getOrLoad('x');
      final Future<int> b = wt.getOrLoad('x');
      gate.complete(42);
      expect(await a, 42);
      expect(await b, 42);
      expect(loads, 1); // thundering-herd guard
    });

    test('a failed load is not cached and is retried', () async {
      int loads = 0;
      final WriteThroughCache<String, int> wt = WriteThroughCache<String, int>(
        LruCache<String, int>(8),
        (String k) async {
          loads++;
          if (loads == 1) throw StateError('transient');
          return 7;
        },
      );
      await expectLater(wt.getOrLoad('k'), throwsStateError);
      expect(await wt.getOrLoad('k'), 7); // retry succeeds
      expect(loads, 2);
    });
  });
}
