import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/bool/bool_sort_extensions.dart';

void main() {
  group('BoolSortingHelper', () {
    // The closed 2x2 domain — every input combination has an exact result.
    group('compareTo', () {
      test('should return 0 when both booleans are true', () {
        expect(true.compareTo(true), equals(0));
      });

      test('should return -1 when this is true and other is false', () {
        expect(true.compareTo(false), equals(-1));
      });

      test('should return 1 when this is false and other is true', () {
        expect(false.compareTo(true), equals(1));
      });

      test('should return 0 when both booleans are false', () {
        expect(false.compareTo(false), equals(0));
      });
    });

    // Antisymmetry: a.compareTo(b) must be the exact negation of b.compareTo(a)
    // for unequal pairs, and 0 for equal pairs — the core Comparable law.
    group('antisymmetry', () {
      test('should negate the comparison for the true/false pair', () {
        expect(true.compareTo(false), equals(-false.compareTo(true)));
      });

      test('should negate the comparison for the false/true pair', () {
        expect(false.compareTo(true), equals(-true.compareTo(false)));
      });

      test('should be 0 in both directions for the equal true pair', () {
        expect(true.compareTo(true), equals(0));
        expect(true.compareTo(true), equals(-true.compareTo(true)));
      });

      test('should be 0 in both directions for the equal false pair', () {
        expect(false.compareTo(false), equals(0));
        expect(false.compareTo(false), equals(-false.compareTo(false)));
      });
    });

    // Reflexivity: comparing a value to itself is always 0 (identity law).
    group('reflexivity', () {
      test('should return 0 for true compared to itself', () {
        expect(true.compareTo(true), isZero);
      });

      test('should return 0 for false compared to itself', () {
        expect(false.compareTo(false), isZero);
      });
    });

    // Sign-only contract: assert direction (negative/zero/positive), not the
    // exact -1/1 magnitude, so the util stays valid if it ever returns -2/2.
    group('sign-only contract', () {
      test('should be negative when this is true and other is false', () {
        expect(true.compareTo(false), isNegative);
      });

      test('should be positive when this is false and other is true', () {
        expect(false.compareTo(true), isPositive);
      });

      test('should be zero for equal true values', () {
        expect(true.compareTo(true), isZero);
      });

      test('should be zero for equal false values', () {
        expect(false.compareTo(false), isZero);
      });
    });

    // Real List.sort integration — the primary use case. Proves the
    // "true first" convention through the actual sort engine.
    group('List.sort integration', () {
      test('should float true values to the front in ascending order', () {
        final List<bool> list = <bool>[false, true, false, true]
          ..sort((bool a, bool b) => a.compareTo(b));

        expect(list, equals(<bool>[true, true, false, false]));
      });

      test('should push true values to the back when comparator is reversed', () {
        final List<bool> list = <bool>[false, true, false, true]
          ..sort((bool a, bool b) => b.compareTo(a));

        expect(list, equals(<bool>[false, false, true, true]));
      });
    });

    // Bucket-partition correctness. Dart's List.sort is not guaranteed stable,
    // so we assert the partition (all true before all false) rather than
    // intra-bucket ordering, then verify counts are preserved.
    group('partition under sort', () {
      test('should split records into a true block then a false block', () {
        final List<(bool, int)> rows = <(bool, int)>[
          (false, 0),
          (true, 1),
          (false, 2),
          (true, 3),
          (false, 4),
        ]..sort(((bool, int) a, (bool, int) b) => a.$1.compareTo(b.$1));

        final List<bool> flags = rows.map(((bool, int) r) => r.$1).toList();

        // Every true must precede every false — the partition is clean.
        final int firstFalse = flags.indexOf(false);
        expect(flags.sublist(0, firstFalse).every((bool f) => f), isTrue);
        expect(flags.sublist(firstFalse).every((bool f) => !f), isTrue);

        // No element is lost or duplicated by the sort.
        expect(flags.where((bool f) => f).length, equals(2));
        expect(flags.where((bool f) => !f).length, equals(3));
      });
    });

    // Boundary / no-op lists must not throw and must stay unchanged.
    group('boundary lists', () {
      test('should leave an empty list unchanged', () {
        final List<bool> list = <bool>[]..sort((bool a, bool b) => a.compareTo(b));

        expect(list, isEmpty);
      });

      test('should leave a single-element list unchanged', () {
        final List<bool> list = <bool>[true]..sort((bool a, bool b) => a.compareTo(b));

        expect(list, equals(<bool>[true]));
      });

      test('should leave an all-true list unchanged', () {
        final List<bool> list = <bool>[true, true, true]
          ..sort((bool a, bool b) => a.compareTo(b));

        expect(list, equals(<bool>[true, true, true]));
      });

      test('should leave an all-false list unchanged', () {
        final List<bool> list = <bool>[false, false, false]
          ..sort((bool a, bool b) => a.compareTo(b));

        expect(list, equals(<bool>[false, false, false]));
      });
    });

    // Transitivity is trivial with two values, but a large alternating list
    // catches any future off-by-one in the branch logic: the result must be a
    // clean true-block followed by a clean false-block.
    group('large-list partition', () {
      test('should sort 10000 alternating booleans into true then false', () {
        final List<bool> list = List<bool>.generate(10000, (int i) => i.isEven)
          ..sort((bool a, bool b) => a.compareTo(b));

        final int trueCount = list.where((bool b) => b).length;

        // Both buckets carry exactly half of the alternating input.
        expect(trueCount, equals(5000));
        // Leading half all true, trailing half all false — no interleaving.
        expect(list.sublist(0, trueCount).every((bool b) => b), isTrue);
        expect(list.sublist(trueCount).every((bool b) => !b), isTrue);
      });
    });
  });
}
