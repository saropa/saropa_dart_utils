import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/lazy_combinatorics_utils.dart';

void main() {
  // n! for small n, used to assert permutation counts.
  int factorial(int n) {
    int product = 1;
    for (int i = 2; i <= n; i++) {
      product *= i;
    }
    return product;
  }

  // nCk via the multiplicative formula, used to assert combination counts.
  int choose(int n, int k) {
    if (k < 0 || k > n) {
      return 0;
    }
    int result = 1;
    for (int i = 0; i < k; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }

  group('permutations', () {
    test('should yield n! permutations', () {
      expect(permutations<int>(<int>[1, 2, 3]).length, equals(factorial(3)));
      expect(permutations<int>(<int>[1, 2, 3, 4]).length, equals(factorial(4)));
    });

    test('should match the known enumeration for three items', () {
      expect(
        permutations<int>(<int>[1, 2, 3]).toList(),
        equals(<List<int>>[
          <int>[1, 2, 3],
          <int>[1, 3, 2],
          <int>[2, 1, 3],
          <int>[2, 3, 1],
          <int>[3, 1, 2],
          <int>[3, 2, 1],
        ]),
      );
    });

    test('should yield k-permutations when length is given', () {
      // 3 items taken 2 at a time = 3!/(3-2)! = 6 arrangements.
      final List<List<int>> result = permutations<int>(
        <int>[1, 2, 3],
        length: 2,
      ).toList();

      expect(result, hasLength(6));
      expect(result.first, equals(<int>[1, 2]));
    });

    test('should yield a single empty permutation for length 0', () {
      expect(
        permutations<int>(<int>[1, 2, 3], length: 0).toList(),
        equals(<List<int>>[<int>[]]),
      );
    });

    test('should yield nothing when length exceeds item count', () {
      expect(permutations<int>(<int>[1, 2], length: 5), isEmpty);
    });

    test('should yield one empty permutation for empty input', () {
      expect(
        permutations<int>(<int>[]).toList(),
        equals(<List<int>>[<int>[]]),
      );
    });

    test('should be lazy — take without enumerating the full factorial', () {
      // Iterating only the first two of a 10! space must not hang.
      final List<List<int>> firstTwo = permutations<int>(
        List<int>.generate(10, (int i) => i),
      ).take(2).toList();

      expect(firstTwo, hasLength(2));
    });
  });

  group('combinations', () {
    test('should yield nCk combinations', () {
      expect(
        combinations<int>(<int>[1, 2, 3, 4], 2).length,
        equals(choose(4, 2)),
      );
      expect(
        combinations<int>(<int>[1, 2, 3, 4, 5], 3).length,
        equals(choose(5, 3)),
      );
    });

    test('should match the known enumeration', () {
      expect(
        combinations<int>(<int>[1, 2, 3, 4], 2).toList(),
        equals(<List<int>>[
          <int>[1, 2],
          <int>[1, 3],
          <int>[1, 4],
          <int>[2, 3],
          <int>[2, 4],
          <int>[3, 4],
        ]),
      );
    });

    test('should yield a single empty combination for k = 0', () {
      expect(
        combinations<int>(<int>[1, 2, 3], 0).toList(),
        equals(<List<int>>[<int>[]]),
      );
    });

    test('should yield nothing when k exceeds item count', () {
      expect(combinations<int>(<int>[1, 2], 5), isEmpty);
    });

    test('should yield nothing for empty input with k > 0', () {
      expect(combinations<int>(<int>[], 2), isEmpty);
    });
  });

  group('cartesianProduct', () {
    test('should yield the product of the list lengths', () {
      final List<List<int>> result = cartesianProduct<int>(<List<int>>[
        <int>[1, 2],
        <int>[3, 4, 5],
      ]).toList();

      expect(result, hasLength(2 * 3));
    });

    test('should match the known enumeration', () {
      expect(
        cartesianProduct<int>(<List<int>>[
          <int>[1, 2],
          <int>[3, 4],
        ]).toList(),
        equals(<List<int>>[
          <int>[1, 3],
          <int>[1, 4],
          <int>[2, 3],
          <int>[2, 4],
        ]),
      );
    });

    test('should yield one empty tuple for an empty list of lists', () {
      expect(
        cartesianProduct<int>(<List<int>>[]).toList(),
        equals(<List<int>>[<int>[]]),
      );
    });

    test('should yield nothing when any inner list is empty', () {
      expect(
        cartesianProduct<int>(<List<int>>[
          <int>[1, 2],
          <int>[],
        ]),
        isEmpty,
      );
    });
  });

  group('powerSet', () {
    test('should yield 2^n subsets', () {
      expect(powerSet<int>(<int>[1, 2, 3]).length, equals(8));
      expect(powerSet<int>(<int>[1, 2, 3, 4]).length, equals(16));
    });

    test('should match the known enumeration ordered by size', () {
      expect(
        powerSet<int>(<int>[1, 2]).toList(),
        equals(<List<int>>[
          <int>[],
          <int>[1],
          <int>[2],
          <int>[1, 2],
        ]),
      );
    });

    test('should yield a single empty subset for empty input', () {
      expect(
        powerSet<int>(<int>[]).toList(),
        equals(<List<int>>[<int>[]]),
      );
    });
  });
}
