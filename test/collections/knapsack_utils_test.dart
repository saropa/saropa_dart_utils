import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/knapsack_utils.dart';

void main() {
  group('KnapsackUtils (item)', () {
    test('should expose weight and value', () {
      const KnapsackUtils item = KnapsackUtils(3, 7);
      expect(item.weight, 3);
      expect(item.value, 7);
    });

    test('should format toString', () {
      expect(const KnapsackUtils(2, 5).toString(), 'KnapsackItem(weight: 2, value: 5)');
    });
  });

  group('knapsack01', () {
    test('should select the optimal subset and value', () {
      final List<KnapsackUtils> items = [
        const KnapsackUtils(2, 3),
        const KnapsackUtils(3, 4),
        const KnapsackUtils(4, 5),
        const KnapsackUtils(5, 6),
      ];
      // Best within capacity 5: items 0 (w2,v3) + 1 (w3,v4) -> value 7.
      final (int, List<int>) result = knapsack01(items, 5);
      expect(result.$1, 7);
      expect(result.$2, [0, 1]);
    });

    test('should return zero value and empty for zero capacity', () {
      // A record holding a List does not compare structurally with ==, so
      // assert each field separately.
      final (int, List<int>) result = knapsack01([const KnapsackUtils(1, 1)], 0);
      expect(result.$1, 0);
      expect(result.$2, <int>[]);
    });

    test('should return zero value and empty for negative capacity', () {
      final (int, List<int>) result = knapsack01([const KnapsackUtils(1, 1)], -5);
      expect(result.$1, 0);
      expect(result.$2, <int>[]);
    });

    test('should return zero value and empty for no items', () {
      final (int, List<int>) result = knapsack01(<KnapsackUtils>[], 10);
      expect(result.$1, 0);
      expect(result.$2, <int>[]);
    });

    test('should take a single item that fits', () {
      final (int, List<int>) result = knapsack01([const KnapsackUtils(3, 9)], 5);
      expect(result.$1, 9);
      expect(result.$2, [0]);
    });

    test('should skip an item that does not fit', () {
      final (int, List<int>) result = knapsack01([const KnapsackUtils(10, 99)], 5);
      expect(result.$1, 0);
      expect(result.$2, <int>[]);
    });

    test('should take all items when capacity is ample', () {
      final List<KnapsackUtils> items = [
        const KnapsackUtils(1, 1),
        const KnapsackUtils(2, 2),
        const KnapsackUtils(3, 3),
      ];
      final (int, List<int>) result = knapsack01(items, 100);
      expect(result.$1, 6);
      expect(result.$2, [0, 1, 2]);
    });

    test('should prefer the higher-value item under tight capacity', () {
      final List<KnapsackUtils> items = [
        const KnapsackUtils(4, 5),
        const KnapsackUtils(4, 10),
      ];
      // Only one item fits in capacity 4; pick the value-10 one.
      final (int, List<int>) result = knapsack01(items, 4);
      expect(result.$1, 10);
      expect(result.$2, [1]);
    });
  });
}
