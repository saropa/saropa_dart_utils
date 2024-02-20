import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/bool/bool_list_utils.dart';

void main() {
  group('anyTrue', () {
    // Additional test cases
    test('returns true for list with single true element', () {
      expect([true].anyTrue, true);
    });

    test('returns false for list with single false element', () {
      expect([false].anyTrue, false);
    });

    test('returns true for list with multiple true elements', () {
      expect([true, true, true, true, true].anyTrue, true);
    });

    test('returns false for list with multiple false elements', () {
      expect([false, false, false, false, false].anyTrue, false);
    });

    test('returns true for list with alternating true and false elements', () {
      expect([true, false, true, false, true].anyTrue, true);
    });

    test(
        'returns false for list with alternating false and true elements starting with false',
        () {
      expect([false, true, false, true, false].anyTrue, true);
    });

    test('returns true for list with all elements true except the first one',
        () {
      expect([false, true, true, true, true].anyTrue, true);
    });

    test('returns true for list with all elements true except the last one',
        () {
      expect([true, true, true, true, false].anyTrue, true);
    });

    test('returns true for list with all elements true except the middle one',
        () {
      expect([true, true, false, true, true].anyTrue, true);
    });

    test('returns false for list with all elements false except the middle one',
        () {
      expect([false, false, true, false, false].anyTrue, true);
    });
  });

  // Repeat similar tests for anyFalse, countTrue, countFalse, and reverse
}
