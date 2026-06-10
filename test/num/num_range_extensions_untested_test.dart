import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_range_extensions.dart';

void main() {
  group('isInRange', () {
    test('true within the inclusive bounds', () {
      expect(5.isInRange(1, 10), isTrue);
    });

    test('true on the boundaries (inclusive)', () {
      expect(1.isInRange(1, 10), isTrue);
      expect(10.isInRange(1, 10), isTrue);
    });

    test('false outside the bounds', () {
      expect(0.isInRange(1, 10), isFalse);
      expect(11.isInRange(1, 10), isFalse);
    });
  });

  group('forceInRange', () {
    test('returns the value when within range', () {
      expect(5.forceInRange(1, 10), 5);
    });

    test('clamps below to min', () {
      expect((-3).forceInRange(1, 10), 1);
    });

    test('clamps above to max', () {
      expect(99.forceInRange(1, 10), 10);
    });
  });
}
