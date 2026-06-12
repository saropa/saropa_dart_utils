import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/backtracking_utils.dart';

void main() {
  group('BacktrackingSolver', () {
    group('N-Queens', () {
      // State: the column chosen for each placed queen, one row at a time. A
      // complete state has one queen per row; isValid rejects same-column and
      // diagonal conflicts so impossible branches are pruned early.
      BacktrackingSolver<List<int>, int> queens(int n) => BacktrackingSolver<List<int>, int>(
        choices: (List<int> cols) =>
            cols.length < n ? List<int>.generate(n, (int c) => c) : <int>[],
        apply: (List<int> cols, int col) => <int>[...cols, col],
        isComplete: (List<int> cols) => cols.length == n,
        isValid: (List<int> cols) {
          // Check only the last-placed queen against the earlier ones.
          final int row = cols.length - 1;
          if (row < 0) {
            return true;
          }
          final int col = cols[row];
          for (int r = 0; r < row; r++) {
            final int c = cols[r];
            // Same column, or on a shared diagonal (|dRow| == |dCol|).
            if (c == col || (row - r) == (col - c).abs()) {
              return false;
            }
          }
          return true;
        },
      );

      test('should count 2 solutions for n = 4', () {
        final List<List<int>> all = queens(4).solveAll(<int>[]);
        expect(all, hasLength(2));
      });

      test('should count 4 solutions for n = 6', () {
        final List<List<int>> all = queens(6).solveAll(<int>[]);
        expect(all, hasLength(4));
      });

      test('should produce a valid first solution for n = 8', () {
        final List<int>? first = queens(8).solveFirst(<int>[]);

        expect(first, isNotNull);
        expect(first, hasLength(8));
      });

      test('should cap solveAll at the given limit', () {
        // n = 8 has 92 solutions; the limit must clamp the returned count.
        final List<List<int>> capped = queens(8).solveAll(<int>[], limit: 3);
        expect(capped, hasLength(3));
      });
    });

    group('subset-sum', () {
      // State record: (next index to decide, running sum). Each step either
      // skips or takes nums[index]; isValid prunes sums that overshoot target.
      BacktrackingSolver<(int index, int sum), int> subsetSum(
        List<int> nums,
        int target,
      ) => BacktrackingSolver<(int, int), int>(
        choices: ((int, int) s) => s.$1 < nums.length ? <int>[0, 1] : <int>[],
        apply: ((int, int) s, int take) =>
            take == 1 ? (s.$1 + 1, s.$2 + nums[s.$1]) : (s.$1 + 1, s.$2),
        isComplete: ((int, int) s) => s.$2 == target,
        isValid: ((int, int) s) => s.$2 <= target,
      );

      test('should find a first solution reaching the target', () {
        final (int, int)? hit = subsetSum(
          <int>[3, 34, 4, 12, 5, 2],
          9,
        ).solveFirst((0, 0));

        expect(hit, isNotNull);
        expect(hit!.$2, equals(9));
      });

      test('should return null when no subset reaches the target', () {
        // All elements are even; an odd target is unreachable.
        final (int, int)? hit = subsetSum(
          <int>[2, 4, 6],
          7,
        ).solveFirst((0, 0));

        expect(hit, isNull);
      });
    });

    test('should return null from solveFirst when the root is invalid', () {
      // isValid false at the root prunes everything immediately.
      final BacktrackingSolver<int, int> solver = BacktrackingSolver<int, int>(
        choices: (int s) => <int>[],
        apply: (int s, int c) => s,
        isComplete: (int s) => true,
        isValid: (int s) => false,
      );

      expect(solver.solveFirst(0), isNull);
      expect(solver.solveAll(0), isEmpty);
    });
  });
}
