import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/bool/bool_iterable_extensions.dart';

void main() {
  group('ListExtensions', () {
    test('mostOccurrences', () {
      expect(<bool>[true, false, true].mostOccurrences(), equals((true, 2)));
    });

    test('leastOccurrences', () {
      expect(<bool>[true, false, true].leastOccurrences(), equals((false, 1)));
    });
  });

  group('anyTrue', () {
    // Additional test cases
    test('returns true for list with single true element', () {
      expect(<bool>[true].anyTrue, true);
    });

    test('returns false for list with single false element', () {
      expect(<bool>[false].anyTrue, false);
    });

    test('returns true for list with multiple true elements', () {
      expect(<bool>[true, true, true, true, true].anyTrue, true);
    });

    test('returns false for list with multiple false elements', () {
      expect(<bool>[false, false, false, false, false].anyTrue, false);
    });

    test('returns true for list with alternating true and false elements', () {
      expect(<bool>[true, false, true, false, true].anyTrue, true);
    });

    test('returns false for list with alternating false and true elements '
        'starting with false', () {
      expect(<bool>[false, true, false, true, false].anyTrue, true);
    });

    test('returns true for list with all elements true except the first one', () {
      expect(<bool>[false, true, true, true, true].anyTrue, true);
    });

    test('returns true for list with all elements true except the last one', () {
      expect(<bool>[true, true, true, true, false].anyTrue, true);
    });

    test('returns true for list with all elements true except the middle one', () {
      expect(<bool>[true, true, false, true, true].anyTrue, true);
    });

    test('returns false for list with all elements false except the middle one', () {
      expect(<bool>[false, false, true, false, false].anyTrue, true);
    });
  });

  group('anyFalse', () {
    // Additional test cases
    test('returns false for list with multiple true elements', () {
      expect(<bool>[true, true, true, true, true].anyFalse, false);
    });

    test('returns true for list with alternating true and false elements', () {
      expect(<bool>[true, false, true, false, true].anyFalse, true);
    });

    test('returns true for list with all elements true except the first one', () {
      expect(<bool>[true, true, true, true, false].anyFalse, true);
    });
  });

  group('countTrue', () {
    // Additional test cases
    test('returns 0 for list with single false element', () {
      expect(<bool>[false].countTrue, 0);
    });

    test('returns 3 for list with alternating true and false elements', () {
      expect(<bool>[true, false, true, false, true].countTrue, 3);
    });

    test('returns 4 for list with all elements true except the first one', () {
      expect(<bool>[false, true, true, true, true].countTrue, 4);
    });
  });

  group('countFalse', () {
    // Additional test cases
    test('returns 0 for list with single true element', () {
      expect(<bool>[true].countFalse, 0);
    });

    test('returns 2 for list with alternating true and false elements', () {
      expect(<bool>[true, false, true, false, true].countFalse, 2);
    });

    test('returns 1 for list with all elements true except the first one', () {
      expect(<bool>[false, true, true, true, true].countFalse, 1);
    });
  });

  group('reverse', () {
    // Additional test cases
    test('returns [true] for list with single false element', () {
      expect(<bool>[false].reverse, <bool>[true]);
    });

    test('returns [false, true, false, true, false] for list with alternating '
        'true and false elements', () {
      expect(<bool>[true, false, true, false, true].reverse, <bool>[
        false,
        true,
        false,
        true,
        false,
      ]);
    });

    test('returns [true, false, false, false, false] for list with all '
        'elements true except the first one', () {
      expect(<bool>[false, true, true, true, true].reverse, <bool>[
        true,
        false,
        false,
        false,
        false,
      ]);
    });
  });
}
