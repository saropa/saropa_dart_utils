import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/multiset_utils.dart';

void main() {
  group('multisetUnion', () {
    test('should take the max count per element', () {
      expect(multisetUnion({'a': 2, 'b': 1}, {'a': 1, 'b': 3, 'c': 2}), {
        'a': 2,
        'b': 3,
        'c': 2,
      });
    });

    test('should include elements unique to either side', () {
      expect(multisetUnion({'a': 1}, {'b': 1}), {'a': 1, 'b': 1});
    });

    test('should return a copy of a when b is empty', () {
      expect(multisetUnion({'a': 5}, <String, int>{}), {'a': 5});
    });

    test('should return b when a is empty', () {
      expect(multisetUnion(<String, int>{}, {'b': 4}), {'b': 4});
    });

    test('should not mutate the input maps', () {
      final Map<String, int> a = {'a': 1};
      final Map<String, int> b = {'a': 2};
      multisetUnion(a, b);
      expect(a, {'a': 1});
      expect(b, {'a': 2});
    });
  });

  group('multisetIntersection', () {
    test('should take the min count per shared element', () {
      expect(multisetIntersection({'a': 2, 'b': 5}, {'a': 3, 'b': 1}), {
        'a': 2,
        'b': 1,
      });
    });

    test('should omit elements absent from either side', () {
      expect(multisetIntersection({'a': 1, 'b': 2}, {'b': 1, 'c': 5}), {'b': 1});
    });

    test('should return empty map when there is no overlap', () {
      expect(multisetIntersection({'a': 1}, {'b': 1}), <String, int>{});
    });

    test('should return empty map when one side is empty', () {
      expect(multisetIntersection(<String, int>{}, {'a': 1}), <String, int>{});
    });
  });

  group('multisetDifference', () {
    test('should subtract counts and keep positive remainders', () {
      expect(multisetDifference({'a': 5, 'b': 2}, {'a': 2}), {'a': 3, 'b': 2});
    });

    test('should drop elements whose count falls to zero', () {
      expect(multisetDifference({'a': 2}, {'a': 2}), <String, int>{});
    });

    test('should drop elements whose count falls below zero', () {
      expect(multisetDifference({'a': 1}, {'a': 5}), <String, int>{});
    });

    test('should ignore subtraction of absent elements', () {
      expect(multisetDifference({'a': 3}, {'z': 1}), {'a': 3});
    });

    test('should return a copy of a when b is empty', () {
      expect(multisetDifference({'a': 1, 'b': 2}, <String, int>{}), {'a': 1, 'b': 2});
    });
  });
}
