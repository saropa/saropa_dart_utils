import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

// A helper class to test with custom comparable objects.
class _ComparableObject implements Comparable<_ComparableObject> {
  const _ComparableObject(this.id, this.name);
  final int id;
  final String name;

  @override
  int compareTo(_ComparableObject other) => id.compareTo(other.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ComparableObject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TestObject{id: $id, name: $name}';
}

void main() {
  group('ComparableIterableExtensions', () {
    group('mostOccurrences()', () {
      // Your existing tests
      test('should find the most common string', () {
        expect(<String>['apple', 'banana', 'apple'].mostOccurrences(), equals(('apple', 2)));
      });

      test('should find the most common DateTime', () {
        expect(
          <DateTime>[DateTime(2022), DateTime(2021), DateTime(2022)].mostOccurrences(),
          equals((DateTime(2022), 2)),
        );
      });

      // 9 new test cases
      test('should return null for an empty list', () {
        expect(<int>[].mostOccurrences(), isNull);
      });

      test('should return the single element for a list with one item', () {
        expect(<int>[100].mostOccurrences(), equals((100, 1)));
      });

      test('should handle a list with all unique elements (returns first one)', () {
        // The fold implementation will likely return the last entry in case of a tie.
        expect(<int>[1, 2, 3, 4, 5].mostOccurrences(), equals((1, 1)));
      });

      test('should find the most common negative number', () {
        expect(<int>[-1, -2, -1, -3, -1].mostOccurrences(), equals((-1, 3)));
      });

      test('should handle a tie and return one of the most common elements', () {
        final (String, int)? result = <String>['a', 'b', 'b', 'c', 'c'].mostOccurrences();
        // In a tie, either ('b', 2) or ('c', 2) is a valid result.
        expect(result, anyOf(equals(('b', 2)), equals(('c', 2))));
      });

      test('should work with doubles', () {
        expect(<double>[1.1, 2.2, 1.1, 3.3].mostOccurrences(), equals((1.1, 2)));
      });

      test('should find a clear winner in a longer list', () {
        final List<int> list = <int>[1, 5, 2, 5, 3, 5, 4, 5, 1, 5, 2, 5];
        expect(list.mostOccurrences(), equals((5, 6)));
      });

      test('should find the most common element when it appears at the beginning', () {
        expect(<int>[1, 1, 1, 2, 3].mostOccurrences(), equals((1, 3)));
      });

      test('should work with custom comparable objects', () {
        const _ComparableObject obj1 = _ComparableObject(1, 'A');
        const _ComparableObject obj2 = _ComparableObject(2, 'B');
        final List<_ComparableObject> list = <_ComparableObject>[obj1, obj2, obj1, obj2, obj1];
        expect(list.mostOccurrences(), equals((obj1, 3)));
      });
    });

    group('leastOccurrences()', () {
      // Your existing tests
      test('should find one of the least common strings in a tie', () {
        expect(
          <String>['apple', 'banana', 'apple', 'cherry'].leastOccurrences(),
          anyOf(equals(('banana', 1)), equals(('cherry', 1))),
        );
      });

      test('should find the least common DateTime', () {
        expect(
          <DateTime>[DateTime(2022), DateTime(2021), DateTime(2022)].leastOccurrences(),
          equals((DateTime(2021), 1)),
        );
      });

      // 9 new test cases
      test('should return null for an empty list', () {
        expect(<int>[].leastOccurrences(), isNull);
      });

      test('should return the single element for a list with one item', () {
        expect(<int>[100].leastOccurrences(), equals((100, 1)));
      });

      test('should return the single element for a list of all identical elements', () {
        expect(<int>[5, 5, 5].leastOccurrences(), equals((5, 3)));
      });

      test('should find a clear loser in a mixed list', () {
        final List<int> list = <int>[1, 2, 2, 3, 3, 3, 4, 4, 4, 4];
        expect(list.leastOccurrences(), equals((1, 1)));
      });

      test('should find the least common negative number', () {
        expect(<int>[-1, -2, -1, -3, -1, -2].leastOccurrences(), equals((-3, 1)));
      });

      test('should handle a tie for least occurrences and return one of them', () {
        final (int, int)? result = <int>[1, 1, 2, 2, 3, 4].leastOccurrences();
        expect(result, anyOf(equals((3, 1)), equals((4, 1))));
      });

      test('should find the least common element when it appears in the middle', () {
        expect(<int>[1, 1, 1, 2, 3, 3, 3].leastOccurrences(), equals((2, 1)));
      });

      test('should work with doubles', () {
        expect(
          <double>[1.1, 2.2, 1.1, 3.3, 2.2, 4.4].leastOccurrences(),
          anyOf(equals((3.3, 1)), equals((4.4, 1))),
        );
      });

      test('should work with custom comparable objects', () {
        const _ComparableObject obj1 = _ComparableObject(1, 'A');
        const _ComparableObject obj2 = _ComparableObject(2, 'B');
        const _ComparableObject obj3 = _ComparableObject(3, 'C');
        final List<_ComparableObject> list = <_ComparableObject>[
          obj1,
          obj2,
          obj1,
          obj2,
          obj1,
          obj3,
        ];
        expect(list.leastOccurrences(), equals((obj3, 1)));
      });
    });
  });
}
