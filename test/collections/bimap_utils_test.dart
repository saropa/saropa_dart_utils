// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/bimap_utils.dart';

void main() {
  group('BimapUtils', () {
    test('should start empty', () {
      final BimapUtils<String, int> map = BimapUtils<String, int>();
      expect(map, hasLength(0));
      expect(map.get('a'), isNull);
      expect(map.getKey(1), isNull);
    });

    group('put / get / getKey', () {
      test('should support forward and reverse lookup', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>();
        map.put('a', 1);
        expect(map.get('a'), 1);
        expect(map.getKey(1), 'a');
        expect(map, hasLength(1));
      });

      test('should replace existing value for a key and clean reverse', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>();
        map.put('a', 1);
        map.put('a', 2);
        expect(map.get('a'), 2);
        expect(map.getKey(1), isNull); // old value's reverse removed
        expect(map.getKey(2), 'a');
        expect(map, hasLength(1));
      });

      test('should replace existing key for a value and clean forward', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>();
        map.put('a', 1);
        map.put('b', 1);
        expect(map.getKey(1), 'b');
        expect(map.get('a'), isNull); // old key's forward removed
        expect(map.get('b'), 1);
        expect(map, hasLength(1));
      });
    });

    group('containsKey / containsValue', () {
      test('should report presence of keys and values', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>();
        map.put('a', 1);
        expect(map.containsKey('a'), isTrue);
        expect(map.containsKey('z'), isFalse);
        expect(map.containsValue(1), isTrue);
        expect(map.containsValue(99), isFalse);
      });
    });

    group('removeByKey', () {
      test('should remove both directions', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>();
        map.put('a', 1);
        map.removeByKey('a');
        expect(map.get('a'), isNull);
        expect(map.getKey(1), isNull);
        expect(map, hasLength(0));
      });

      test('should be a no-op for an absent key', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>()..put('a', 1);
        map.removeByKey('missing');
        expect(map, hasLength(1));
      });
    });

    group('removeByValue', () {
      test('should remove both directions', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>();
        map.put('a', 1);
        map.removeByValue(1);
        expect(map.get('a'), isNull);
        expect(map.getKey(1), isNull);
        expect(map, hasLength(0));
      });

      test('should be a no-op for an absent value', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>()..put('a', 1);
        map.removeByValue(999);
        expect(map, hasLength(1));
      });
    });

    group('length', () {
      test('should track number of pairs', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>();
        expect(map, hasLength(0));
        map.put('a', 1);
        map.put('b', 2);
        expect(map, hasLength(2));
      });
    });

    group('toString', () {
      test('should include length', () {
        final BimapUtils<String, int> map = BimapUtils<String, int>()..put('a', 1);
        expect(map.toString(), 'BimapUtils(length: 1)');
      });
    });
  });
}
