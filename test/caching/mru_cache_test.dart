import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/caching/mru_cache.dart';

void main() {
  group('MruCache', () {
    test('should store and retrieve values', () {
      final MruCache<String, int> c = MruCache<String, int>(2)..put('a', 1);

      expect(c.get('a'), equals(1));
      expect(c.get('missing'), isNull);
    });

    test('should evict the most-recently-used entry when full', () {
      final MruCache<String, int> c = MruCache<String, int>(2)
        ..put('a', 1)
        ..put('b', 2) // 'b' is now most-recently-used
        ..put('c', 3); // full: evicts 'b', keeps 'a'

      expect(c.get('a'), equals(1));
      expect(c.get('b'), isNull);
      expect(c.get('c'), equals(3));
      expect(c.length, equals(2));
    });

    test('should treat a get as making the key the MRU eviction target', () {
      final MruCache<String, int> c = MruCache<String, int>(2)
        ..put('a', 1)
        ..put('b', 2);
      c.get('a'); // 'a' becomes most-recently-used
      c.put('c', 3); // evicts 'a' (the MRU), keeps 'b'

      expect(c.get('a'), isNull);
      expect(c.get('b'), equals(2));
      expect(c.get('c'), equals(3));
    });

    test('should update an existing key without eviction', () {
      final MruCache<String, int> c = MruCache<String, int>(2)
        ..put('a', 1)
        ..put('b', 2)
        ..put('a', 10); // update, not insert

      expect(c.get('a'), equals(10));
      expect(c.get('b'), equals(2));
      expect(c.length, equals(2));
    });

    test('should count access frequency across get and put', () {
      final MruCache<String, int> c = MruCache<String, int>(3)..put('a', 1);
      c
        ..get('a')
        ..get('a');

      expect(c.frequencyOf('a'), equals(3)); // 1 put + 2 gets
      expect(c.frequencyOf('never'), equals(0));
    });

    test('should not count a miss as an access', () {
      final MruCache<String, int> c = MruCache<String, int>(2);
      c.get('absent');

      expect(c.frequencyOf('absent'), equals(0));
    });

    test('should clear frequency when an entry is evicted', () {
      final MruCache<String, int> c = MruCache<String, int>(1)
        ..put('a', 1)
        ..put('b', 2); // evicts 'a'

      expect(c.frequencyOf('a'), equals(0));
    });

    test('should remove an entry and its frequency', () {
      final MruCache<String, int> c = MruCache<String, int>(2)..put('a', 1);
      c.remove('a');

      expect(c.get('a'), isNull);
      expect(c.frequencyOf('a'), equals(0));
      expect(c.length, equals(0));
    });

    test('should assert on a non-positive capacity', () {
      expect(() => MruCache<String, int>(0), throwsA(isA<AssertionError>()));
    });
  });
}
