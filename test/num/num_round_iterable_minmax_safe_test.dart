import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_iterable_extensions.dart';
import 'package:saropa_dart_utils/num/num_min_max_utils.dart';
import 'package:saropa_dart_utils/num/num_range_inclusive_extensions.dart';
import 'package:saropa_dart_utils/num/num_round_multiple_extensions.dart';
import 'package:saropa_dart_utils/num/num_safe_division_extensions.dart';

void main() {
  group('roundToMultiple', () {
    test('round to 0.05', () {
      expect(2.73.roundToMultiple(0.05), 2.75);
    });
    test('round to nearest 5', () {
      expect(12.roundToMultiple(5), 10.0);
      expect(13.roundToMultiple(5), 15.0);
    });
    test('non-positive multiple throws', () {
      expect(() => 5.roundToMultiple(0), throwsArgumentError);
      expect(() => 5.roundToMultiple(-1), throwsArgumentError);
    });
  });
  group('floorToMultiple', () {
    test('floors to multiple', () {
      expect(13.floorToMultiple(5), 10.0);
      expect(10.floorToMultiple(5), 10.0);
    });
    test('non-positive multiple throws', () {
      expect(() => 5.floorToMultiple(0), throwsArgumentError);
    });
  });
  group('ceilToMultiple', () {
    test('ceils to multiple', () {
      expect(11.ceilToMultiple(5), 15.0);
      expect(10.ceilToMultiple(5), 10.0);
    });
    test('non-positive multiple throws', () {
      expect(() => 5.ceilToMultiple(0), throwsArgumentError);
    });
  });
  group('sum average count', () {
    test('sum and average', () {
      expect(<num>[1, 2, 3].sum, 6);
      expect(<num>[1, 2, 3].average, 2);
    });
    test('count of elements', () {
      expect(<num>[1, 2, 3].count, 3);
      expect(<num>[].count, 0);
    });
    test('empty sum is 0', () {
      expect(<num>[].sum, 0);
    });
    test('empty average is null', () {
      expect(<num>[].average, isNull);
    });
  });
  group('minOf maxOf', () {
    test('two-argument min and max', () {
      expect(minOf(3, 7), 3);
      expect(maxOf(3, 7), 7);
    });
    test('equal arguments return that value', () {
      expect(minOf(5, 5), 5);
      expect(maxOf(5, 5), 5);
    });
    test('negatives', () {
      expect(minOf(-3, -1), -3);
      expect(maxOf(-3, -1), -1);
    });
  });
  group('minOfMany maxOfMany', () {
    test('min and max', () {
      expect(minOfMany(<num>[3, 1, 2]), 1);
      expect(maxOfMany(<num>[3, 1, 2]), 3);
    });
    test('empty returns null', () {
      expect(minOfMany(<num>[]), isNull);
      expect(maxOfMany(<num>[]), isNull);
    });
    test('single element', () {
      expect(minOfMany(<num>[42]), 42);
      expect(maxOfMany(<num>[42]), 42);
    });
  });
  group('isInRangeExclusive', () {
    test('exclusive', () {
      expect(5.isInRangeExclusive(0, 10), isTrue);
      expect(0.isInRangeExclusive(0, 10), isFalse);
      expect(10.isInRangeExclusive(0, 10), isFalse);
    });
  });
  group('isInRangeInclusive', () {
    test('inclusive endpoints', () {
      expect(5.isInRangeInclusive(0, 10), isTrue);
      expect(0.isInRangeInclusive(0, 10), isTrue);
      expect(10.isInRangeInclusive(0, 10), isTrue);
      expect(11.isInRangeInclusive(0, 10), isFalse);
    });
  });
  group('divideSafe', () {
    test('by zero returns default', () {
      expect(10.divideSafe(0, -1), -1);
    });
    test('by zero with no default returns 0', () {
      expect(10.divideSafe(0), 0);
    });
    test('normal division', () {
      expect(10.divideSafe(2), 5);
    });
  });
  group('safeDivide', () {
    test('normal division', () {
      expect(safeDivide(10, 4), 2.5);
    });
    test('by zero returns null', () {
      expect(safeDivide(10, 0), isNull);
    });
    test('zero numerator', () {
      expect(safeDivide(0, 5), 0.0);
    });
  });
}
