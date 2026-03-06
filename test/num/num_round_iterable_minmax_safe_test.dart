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
  });
  group('sum average', () {
    test('sum and average', () {
      expect(<num>[1, 2, 3].sum, 6);
      expect(<num>[1, 2, 3].average, 2);
    });
  });
  group('minOfMany maxOfMany', () {
    test('min and max', () {
      expect(minOfMany(<num>[3, 1, 2]), 1);
      expect(maxOfMany(<num>[3, 1, 2]), 3);
    });
  });
  group('isInRangeExclusive', () {
    test('exclusive', () {
      expect(5.isInRangeExclusive(0, 10), isTrue);
      expect(0.isInRangeExclusive(0, 10), isFalse);
    });
  });
  group('divideSafe', () {
    test('by zero returns default', () {
      expect(10.divideSafe(0, -1), -1);
    });
    test('normal division', () {
      expect(10.divideSafe(2), 5);
    });
  });
}
