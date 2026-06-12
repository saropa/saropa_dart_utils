import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/write_through_cache.dart';

void main() {
  group('WriteThroughStore', () {
    test('should load on a miss and cache the result (one load per key)', () async {
      int loads = 0;
      final WriteThroughStore<String, int> c = WriteThroughStore<String, int>(
        load: (String k) async {
          loads++;
          return k.length;
        },
        store: (String k, int v) async {},
      );

      expect(await c.get('abc'), equals(3));
      expect(await c.get('abc'), equals(3));
      expect(loads, equals(1));
    });

    test('should persist to the store on every put before updating the cache', () async {
      final Map<String, int> backing = <String, int>{};
      final WriteThroughStore<String, int> c = WriteThroughStore<String, int>(
        load: (String k) async => backing[k],
        store: (String k, int v) async => backing[k] = v,
      );

      await c.put('x', 42);

      expect(backing['x'], equals(42));
      expect(await c.get('x'), equals(42));
    });

    test('should not cache a null load result', () async {
      int loads = 0;
      final WriteThroughStore<String, int> c = WriteThroughStore<String, int>(
        load: (String k) async {
          loads++;
          return null;
        },
        store: (String k, int v) async {},
      );

      expect(await c.get('missing'), isNull);
      expect(await c.get('missing'), isNull);
      expect(loads, equals(2)); // a missing key is re-loaded, not cached
    });

    test('should leave the cache unchanged when the store write fails', () async {
      final WriteThroughStore<String, int> c = WriteThroughStore<String, int>(
        load: (String k) async => null,
        store: (String k, int v) async => throw StateError('store down'),
      );

      await expectLater(c.put('y', 1), throwsStateError);
      expect(c.length, equals(0));
    });

    test('should drop an entry on invalidate', () async {
      int loads = 0;
      final WriteThroughStore<String, int> c = WriteThroughStore<String, int>(
        load: (String k) async {
          loads++;
          return 7;
        },
        store: (String k, int v) async {},
      );

      await c.get('k');
      c.invalidate('k');
      await c.get('k');

      expect(loads, equals(2));
    });
  });

  group('WriteBackStore', () {
    test('should buffer writes and only persist on flush', () async {
      final Map<String, int> backing = <String, int>{};
      final WriteBackStore<String, int> c = WriteBackStore<String, int>(
        load: (String k) async => backing[k],
        store: (String k, int v) async => backing[k] = v,
      )
        ..put('a', 1)
        ..put('b', 2);

      expect(backing, isEmpty);
      expect(c.dirtyKeys, equals(<String>{'a', 'b'}));

      await c.flush();

      expect(backing, equals(<String, int>{'a': 1, 'b': 2}));
      expect(c.dirtyKeys, isEmpty);
    });

    test('should coalesce repeated writes to one store call on flush', () async {
      int stores = 0;
      final WriteBackStore<String, int> c = WriteBackStore<String, int>(
        load: (String k) async => null,
        store: (String k, int v) async => stores++,
      )
        ..put('a', 1)
        ..put('a', 2)
        ..put('a', 3);

      await c.flush();

      expect(stores, equals(1));
    });

    test('should serve buffered writes from the cache before flush', () async {
      final WriteBackStore<String, int> c = WriteBackStore<String, int>(
        load: (String k) async => 0,
        store: (String k, int v) async {},
      )..put('a', 99);

      expect(await c.get('a'), equals(99));
    });

    test('should read through to the store on a miss', () async {
      final WriteBackStore<String, int> c = WriteBackStore<String, int>(
        load: (String k) async => 5,
        store: (String k, int v) async {},
      );

      expect(await c.get('fresh'), equals(5));
    });
  });
}
