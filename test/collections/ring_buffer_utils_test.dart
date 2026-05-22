import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/ring_buffer_utils.dart';

void main() {
  group('RingBufferUtils', () {
    group('constructor', () {
      test('should expose capacity', () {
        expect(RingBufferUtils<int>(3).capacity, 3);
      });

      test('should throw for capacity < 1', () {
        expect(() => RingBufferUtils<int>(0), throwsArgumentError);
        expect(() => RingBufferUtils<int>(-1), throwsArgumentError);
      });
    });

    group('add / toList', () {
      test('should keep elements in insertion order below capacity', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(3)
          ..add(1)
          ..add(2);
        expect(buf.toList(), [1, 2]);
        expect(buf, hasLength(2));
      });

      test('should overwrite the oldest element when full', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(3)
          ..add(1)
          ..add(2)
          ..add(3)
          ..add(4);
        // 1 was overwritten by 4; oldest-first order is 2,3,4.
        expect(buf.toList(), [2, 3, 4]);
        expect(buf, hasLength(3));
      });

      test('should wrap multiple times correctly', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(2);
        for (int i = 1; i <= 5; i++) {
          buf.add(i);
        }
        expect(buf.toList(), [4, 5]);
      });
    });

    group('removeFirst', () {
      test('should remove and return the oldest element', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(3)
          ..add(1)
          ..add(2);
        expect(buf.removeFirst(), 1);
        expect(buf.toList(), [2]);
        expect(buf, hasLength(1));
      });

      test('should return null when empty', () {
        expect(RingBufferUtils<int>(3).removeFirst(), isNull);
      });

      test('should support add after remove past a wrap', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(2)
          ..add(1)
          ..add(2);
        expect(buf.removeFirst(), 1);
        buf.add(3);
        expect(buf.toList(), [2, 3]);
      });
    });

    group('length / isEmpty / isNotEmpty', () {
      test('should report empty state for a fresh buffer', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(3);
        expect(buf.isEmpty, isTrue);
        expect(buf.isNotEmpty, isFalse);
        expect(buf, hasLength(0));
      });

      test('should report non-empty after add', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(3)..add(1);
        expect(buf.isEmpty, isFalse);
        expect(buf.isNotEmpty, isTrue);
      });
    });

    group('toString', () {
      test('should report capacity and length', () {
        final RingBufferUtils<int> buf = RingBufferUtils<int>(3)..add(1);
        expect(buf.toString(), 'RingBufferUtils(capacity: 3, length: 1)');
      });
    });
  });
}
