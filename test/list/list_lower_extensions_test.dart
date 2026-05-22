// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_lower_extensions.dart';

void main() {
  group('ListLowerExtensions', () {
    group('swapAt', () {
      test('swaps two valid indices', () {
        expect(<int>[1, 2, 3].swapAt(0, 2), <int>[3, 2, 1]);
      });

      test('does not mutate the original list', () {
        final List<int> original = <int>[1, 2, 3];
        final List<int> swapped = original.swapAt(0, 1);
        expect(swapped, <int>[2, 1, 3]);
        expect(original, <int>[1, 2, 3]);
      });

      test('returns unchanged copy when an index is out of range', () {
        expect(<int>[1, 2, 3].swapAt(0, 5), <int>[1, 2, 3]);
      });

      test('returns unchanged copy for negative index', () {
        expect(<int>[1, 2, 3].swapAt(-1, 1), <int>[1, 2, 3]);
      });

      test('swapping an index with itself is a no-op', () {
        expect(<int>[1, 2, 3].swapAt(1, 1), <int>[1, 2, 3]);
      });
    });

    group('reversedCopy', () {
      test('reverses elements', () {
        expect(<int>[1, 2, 3].reversedCopy(), <int>[3, 2, 1]);
      });

      test('empty list reverses to empty', () {
        expect(<int>[].reversedCopy(), <int>[]);
      });

      test('does not mutate the original', () {
        final List<int> original = <int>[1, 2, 3];
        final List<int> reversed = original.reversedCopy();
        expect(reversed, <int>[3, 2, 1]);
        expect(original, <int>[1, 2, 3]);
      });
    });

    group('insertAt', () {
      test('inserts at a valid index', () {
        expect(<int>[1, 2, 3].insertAt(1, 9), <int>[1, 9, 2, 3]);
      });

      test('clamps negative index to 0', () {
        expect(<int>[1, 2, 3].insertAt(-5, 9), <int>[9, 1, 2, 3]);
      });

      test('clamps oversized index to the end', () {
        expect(<int>[1, 2, 3].insertAt(99, 9), <int>[1, 2, 3, 9]);
      });

      test('inserts into an empty list', () {
        expect(<int>[].insertAt(0, 9), <int>[9]);
      });
    });

    group('replaceAt', () {
      test('replaces at a valid index', () {
        expect(<int>[1, 2, 3].replaceAt(1, 9), <int>[1, 9, 3]);
      });

      test('out-of-range index leaves list unchanged', () {
        expect(<int>[1, 2, 3].replaceAt(5, 9), <int>[1, 2, 3]);
      });

      test('negative index leaves list unchanged', () {
        expect(<int>[1, 2, 3].replaceAt(-1, 9), <int>[1, 2, 3]);
      });
    });

    group('getOrNull', () {
      test('returns element at a valid index', () {
        expect(<int>[1, 2, 3].getOrNull(1), 2);
      });

      test('returns null for out-of-range index', () {
        expect(<int>[1, 2, 3].getOrNull(5), isNull);
      });

      test('returns null for negative index', () {
        expect(<int>[1, 2, 3].getOrNull(-1), isNull);
      });

      test('returns null for an empty list', () {
        expect(<int>[].getOrNull(0), isNull);
      });
    });

    group('orDefault', () {
      test('returns default for empty list', () {
        expect(<int>[].orDefault(<int>[9]), <int>[9]);
      });

      test('returns the list itself when non-empty', () {
        final List<int> list = <int>[1, 2];
        expect(list.orDefault(<int>[9]), same(list));
      });
    });

    group('firstOrCompute', () {
      test('returns the first element when present', () {
        expect(<int>[1, 2, 3].firstOrCompute(() => 99), 1);
      });

      test('computes a fallback for an empty list', () {
        expect(<int>[].firstOrCompute(() => 99), 99);
      });
    });
  });

  group('ListSingleExtension.singleOrNull', () {
    test('returns the only element', () {
      expect(<int>[7].singleOrNull, 7);
    });

    test('returns null for empty list', () {
      expect(<int>[].singleOrNull, isNull);
    });

    test('returns null for multiple elements', () {
      expect(<int>[1, 2].singleOrNull, isNull);
    });
  });

  group('IterableToSetExtension.toSetFrom', () {
    test('converts to a set of distinct elements', () {
      expect(<int>[1, 2, 2, 3].toSetFrom(), <int>{1, 2, 3});
    });

    test('empty iterable yields empty set', () {
      expect(<int>[].toSetFrom(), <int>{});
    });
  });

  group('IterableToListExtension.toListFrom', () {
    test('converts iterable to list preserving order', () {
      expect(<int>{1, 2, 3}.toListFrom(), <int>[1, 2, 3]);
    });

    test('empty iterable yields empty list', () {
      expect(<int>[].toListFrom(), <int>[]);
    });
  });
}
