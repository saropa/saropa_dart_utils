import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/pareto_frontier_utils.dart';

void main() {
  // Two-objective minimize options over [x, y] integer points.
  ParetoOptions<List<int>> minMin() => ParetoOptions<List<int>>(
    criteria: [(p) => p[0], (p) => p[1]],
    directions: [ParetoDirection.minimize, ParetoDirection.minimize],
  );

  group('ParetoOptions', () {
    test('should throw when criteria is empty', () {
      expect(
        () => ParetoOptions<int>(criteria: [], directions: []),
        throwsArgumentError,
      );
    });

    test('should throw when criteria and directions length mismatch', () {
      expect(
        () => ParetoOptions<int>(
          criteria: [(v) => v],
          directions: [ParetoDirection.minimize, ParetoDirection.maximize],
        ),
        throwsArgumentError,
      );
    });

    test('should construct when lengths match', () {
      expect(minMin().criteria, hasLength(2));
    });
  });

  group('paretoFrontier', () {
    test('should return empty list for empty input', () {
      expect(paretoFrontier(<List<int>>[], minMin()), isEmpty);
    });

    test('should keep a single item (always non-dominated)', () {
      expect(
        paretoFrontier([
          [5, 5],
        ], minMin()),
        equals([
          [5, 5],
        ]),
      );
    });

    test('should drop dominated points and keep the frontier', () {
      // (3,3) is dominated by both (1,2) and (2,1) under minimize/minimize.
      final result = paretoFrontier([
        [1, 2],
        [2, 1],
        [3, 3],
      ], minMin());
      expect(
        result,
        equals([
          [1, 2],
          [2, 1],
        ]),
      );
    });

    test('should keep all-equal points (none dominates another)', () {
      final result = paretoFrontier([
        [2, 2],
        [2, 2],
        [2, 2],
      ], minMin());
      expect(result, hasLength(3));
    });

    test('should keep duplicates of a frontier point', () {
      // A duplicate ties on every objective, so neither dominates the other.
      final result = paretoFrontier([
        [1, 1],
        [1, 1],
        [9, 9],
      ], minMin());
      expect(
        result,
        equals([
          [1, 1],
          [1, 1],
        ]),
      );
    });

    test('should preserve original order of surviving items', () {
      final result = paretoFrontier([
        [2, 1],
        [1, 2],
      ], minMin());
      expect(result.first, equals([2, 1]));
    });

    test('should honor maximize direction', () {
      // Larger is better on both axes: (5,5) dominates (1,1) and (3,3).
      final opts = ParetoOptions<List<int>>(
        criteria: [(p) => p[0], (p) => p[1]],
        directions: [ParetoDirection.maximize, ParetoDirection.maximize],
      );
      final result = paretoFrontier([
        [1, 1],
        [3, 3],
        [5, 5],
      ], opts);
      expect(
        result,
        equals([
          [5, 5],
        ]),
      );
    });

    test('should handle mixed minimize and maximize objectives', () {
      // Minimize price, maximize rating: low price + high rating dominates.
      final opts = ParetoOptions<List<num>>(
        criteria: [(p) => p[0], (p) => p[1]],
        directions: [ParetoDirection.minimize, ParetoDirection.maximize],
      );
      final result = paretoFrontier([
        [10, 4],
        [10, 5],
        [20, 5],
      ], opts);
      expect(
        result,
        equals([
          [10, 5],
        ]),
      );
    });

    test('should support three objectives', () {
      final opts = ParetoOptions<List<int>>(
        criteria: [(p) => p[0], (p) => p[1], (p) => p[2]],
        directions: const [
          ParetoDirection.minimize,
          ParetoDirection.minimize,
          ParetoDirection.minimize,
        ],
      );
      // (2,2,2) is dominated by (1,1,1); both others survive on a trade-off.
      final result = paretoFrontier([
        [1, 1, 1],
        [2, 2, 2],
        [3, 0, 3],
      ], opts);
      expect(
        result,
        equals([
          [1, 1, 1],
          [3, 0, 3],
        ]),
      );
    });

    test('should handle negative and zero objective values', () {
      final result = paretoFrontier([
        [-5, 0],
        [0, -5],
        [0, 0],
      ], minMin());
      // (0,0) is dominated by both negative points under minimize/minimize.
      expect(
        result,
        equals([
          [-5, 0],
          [0, -5],
        ]),
      );
    });
  });
}
