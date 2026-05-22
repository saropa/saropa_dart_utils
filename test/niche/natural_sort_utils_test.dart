import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/natural_sort_utils.dart';

void main() {
  group('naturalCompare', () {
    test('numeric runs compare by value, not lexically', () {
      // 'a2' sorts before 'a10' because 2 < 10.
      expect(naturalCompare('a2', 'a10'), lessThan(0));
      expect(naturalCompare('a10', 'a2'), greaterThan(0));
    });

    test('identical strings compare equal', () {
      expect(naturalCompare('img5', 'img5'), 0);
    });

    test('prefix sorts before the longer string', () {
      // 'a' has fewer tokens than 'a1'.
      expect(naturalCompare('a', 'a1'), lessThan(0));
    });

    test('textual runs fall back to lexicographic order', () {
      expect(naturalCompare('apple', 'banana'), lessThan(0));
    });

    test('mixed text and number tokens', () {
      expect(naturalCompare('file9part2', 'file9part10'), lessThan(0));
    });
  });

  group('NaturalSortExtension.sortedNatural', () {
    test('orders embedded numbers by value', () {
      expect(
        <String>['a10', 'a2', 'a1'].sortedNatural(),
        <String>['a1', 'a2', 'a10'],
      );
    });

    test('does not mutate the original list', () {
      final List<String> original = <String>['b', 'a'];
      final List<String> sorted = original.sortedNatural();
      expect(sorted, <String>['a', 'b']);
      expect(original, <String>['b', 'a']);
    });

    test('empty list stays empty', () {
      expect(<String>[].sortedNatural(), isEmpty);
    });

    test('already sorted list is unchanged', () {
      expect(
        <String>['x1', 'x2', 'x3'].sortedNatural(),
        <String>['x1', 'x2', 'x3'],
      );
    });
  });
}
