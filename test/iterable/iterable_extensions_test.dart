import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';
import 'package:saropa_dart_utils/iterable/iterable_flatten_extensions.dart';
import 'package:saropa_dart_utils/iterable/occurrence.dart';

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
        expect(
          <String>['apple', 'banana', 'apple'].mostOccurrences(),
          equals(Occurrence<String>('apple', 2)),
        );
      });

      test('should find the most common DateTime', () {
        expect(
          <DateTime>[DateTime(2022), DateTime(2021), DateTime(2022)].mostOccurrences(),
          equals(Occurrence<DateTime>(DateTime(2022), 2)),
        );
      });

      // 9 new test cases
      test('should return null for an empty list', () {
        expect(<int>[].mostOccurrences(), isNull);
      });

      test('should return the single element for a list with one item', () {
        expect(<int>[100].mostOccurrences(), equals(Occurrence<int>(100, 1)));
      });

      test('should handle a list with all unique elements (returns first one)', () {
        // The fold implementation will likely return the last entry in case of a tie.
        expect(<int>[1, 2, 3, 4, 5].mostOccurrences(), equals(Occurrence<int>(1, 1)));
      });

      test('should find the most common negative number', () {
        expect(<int>[-1, -2, -1, -3, -1].mostOccurrences(), equals(Occurrence<int>(-1, 3)));
      });

      test('should handle a tie and return one of the most common elements', () {
        final Occurrence<String>? result = <String>['a', 'b', 'b', 'c', 'c'].mostOccurrences();
        // In a tie, either ('b', 2) or ('c', 2) is a valid result.
        expect(
          result,
          anyOf(equals(Occurrence<String>('b', 2)), equals(Occurrence<String>('c', 2))),
        );
      });

      test('should work with doubles', () {
        expect(<double>[1.1, 2.2, 1.1, 3.3].mostOccurrences(), equals(Occurrence<double>(1.1, 2)));
      });

      test('should find a clear winner in a longer list', () {
        final List<int> list = <int>[1, 5, 2, 5, 3, 5, 4, 5, 1, 5, 2, 5];
        expect(list.mostOccurrences(), equals(Occurrence<int>(5, 6)));
      });

      test('should find the most common element when it appears at the beginning', () {
        expect(<int>[1, 1, 1, 2, 3].mostOccurrences(), equals(Occurrence<int>(1, 3)));
      });

      test('should work with custom comparable objects', () {
        const _ComparableObject obj1 = _ComparableObject(1, 'A');
        const _ComparableObject obj2 = _ComparableObject(2, 'B');
        final List<_ComparableObject> list = <_ComparableObject>[obj1, obj2, obj1, obj2, obj1];
        expect(list.mostOccurrences(), equals(Occurrence<_ComparableObject>(obj1, 3)));
      });
    });

    group('leastOccurrences()', () {
      // Your existing tests
      test('should find one of the least common strings in a tie', () {
        expect(
          <String>['apple', 'banana', 'apple', 'cherry'].leastOccurrences(),
          anyOf(equals(Occurrence<String>('banana', 1)), equals(Occurrence<String>('cherry', 1))),
        );
      });

      test('should find the least common DateTime', () {
        expect(
          <DateTime>[DateTime(2022), DateTime(2021), DateTime(2022)].leastOccurrences(),
          equals(Occurrence<DateTime>(DateTime(2021), 1)),
        );
      });

      // 9 new test cases
      test('should return null for an empty list', () {
        expect(<int>[].leastOccurrences(), isNull);
      });

      test('should return the single element for a list with one item', () {
        expect(<int>[100].leastOccurrences(), equals(Occurrence<int>(100, 1)));
      });

      test('should return the single element for a list of all identical elements', () {
        expect(<int>[5, 5, 5].leastOccurrences(), equals(Occurrence<int>(5, 3)));
      });

      test('should find a clear loser in a mixed list', () {
        final List<int> list = <int>[1, 2, 2, 3, 3, 3, 4, 4, 4, 4];
        expect(list.leastOccurrences(), equals(Occurrence<int>(1, 1)));
      });

      test('should find the least common negative number', () {
        expect(<int>[-1, -2, -1, -3, -1, -2].leastOccurrences(), equals(Occurrence<int>(-3, 1)));
      });

      test('should handle a tie for least occurrences and return one of them', () {
        final Occurrence<int>? result = <int>[1, 1, 2, 2, 3, 4].leastOccurrences();
        expect(result, anyOf(equals(Occurrence<int>(3, 1)), equals(Occurrence<int>(4, 1))));
      });

      test('should find the least common element when it appears in the middle', () {
        expect(<int>[1, 1, 1, 2, 3, 3, 3].leastOccurrences(), equals(Occurrence<int>(2, 1)));
      });

      test('should work with doubles', () {
        expect(
          <double>[1.1, 2.2, 1.1, 3.3, 2.2, 4.4].leastOccurrences(),
          anyOf(equals(Occurrence<double>(3.3, 1)), equals(Occurrence<double>(4.4, 1))),
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
        expect(list.leastOccurrences(), equals(Occurrence<_ComparableObject>(obj3, 1)));
      });
    });

    group('randomElement', () {
      test('1. Empty list returns null', () {
        expect(<int>[].randomElement(), isNull);
      });
      test('2. Single element returns that element', () {
        expect(<int>[42].randomElement(), 42);
      });
      test('3. Returns element from list', () {
        final List<int> list = <int>[1, 2, 3, 4, 5];
        final int? result = list.randomElement();
        expect(list.contains(result), isTrue);
      });
      test('4. Works with strings', () {
        final List<String> list = <String>['a', 'b', 'c'];
        final String? result = list.randomElement();
        expect(list.contains(result), isTrue);
      });
      test('5. Works with doubles', () {
        final List<double> list = <double>[1.1, 2.2, 3.3];
        final double? result = list.randomElement();
        expect(list.contains(result), isTrue);
      });
      test('6. Result is not null for non-empty list', () {
        expect(<int>[1, 2, 3].randomElement(), isNotNull);
      });
      test('7. Works with custom objects', () {
        const _ComparableObject obj1 = _ComparableObject(1, 'A');
        const _ComparableObject obj2 = _ComparableObject(2, 'B');
        final List<_ComparableObject> list = <_ComparableObject>[obj1, obj2];
        final _ComparableObject? result = list.randomElement();
        expect(list.contains(result), isTrue);
      });
      test('8. Two elements returns one of them', () {
        final List<int> list = <int>[1, 2];
        final int? result = list.randomElement();
        expect(result == 1 || result == 2, isTrue);
      });
      test('9. Works with Set iterable', () {
        final Set<int> set = <int>{10, 20, 30};
        final int? result = set.randomElement();
        expect(set.contains(result), isTrue);
      });
      test('10. Large list returns element', () {
        final List<int> list = List<int>.generate(100, (int i) => i);
        final int? result = list.randomElement();
        expect(result, isNotNull);
        expect(result, allOf(greaterThanOrEqualTo(0), lessThan(100)));
      });
    });

    group('containsAll', () {
      test('1. Empty list contains empty list', () {
        expect(<int>[].containsAll(<int>[]), isTrue);
      });
      test('2. Non-empty list contains empty list', () {
        expect(<int>[1, 2, 3].containsAll(<int>[]), isTrue);
      });
      test('3. List contains all its elements', () {
        expect(<int>[1, 2, 3].containsAll(<int>[1, 2, 3]), isTrue);
      });
      test('4. List contains subset', () {
        expect(<int>[1, 2, 3, 4, 5].containsAll(<int>[2, 4]), isTrue);
      });
      test('5. List does not contain missing element', () {
        expect(<int>[1, 2, 3].containsAll(<int>[1, 4]), isFalse);
      });
      test('6. Empty list does not contain elements', () {
        expect(<int>[].containsAll(<int>[1]), isFalse);
      });
      test('7. Works with strings', () {
        expect(<String>['a', 'b', 'c'].containsAll(<String>['a', 'c']), isTrue);
      });
      test('8. Works with duplicates', () {
        expect(<int>[1, 1, 2, 2, 3].containsAll(<int>[1, 2]), isTrue);
      });
      test('9. Single element check', () {
        expect(<int>[5].containsAll(<int>[5]), isTrue);
      });
      test('10. Does not contain different elements', () {
        expect(<int>[1, 2, 3].containsAll(<int>[4, 5, 6]), isFalse);
      });
      test('11. Partial match returns false', () {
        expect(<int>[1, 2].containsAll(<int>[1, 2, 3]), isFalse);
      });
      test('12. Order does not matter', () {
        expect(<int>[3, 2, 1].containsAll(<int>[1, 2, 3]), isTrue);
      });
    });

    group('countWhere', () {
      test('1. Empty list returns 0', () {
        expect(<int>[].countWhere((int e) => e > 0), 0);
      });
      test('2. All match', () {
        expect(<int>[1, 2, 3, 4, 5].countWhere((int e) => e > 0), 5);
      });
      test('3. None match', () {
        expect(<int>[1, 2, 3].countWhere((int e) => e > 10), 0);
      });
      test('4. Some match', () {
        expect(<int>[1, 2, 3, 4, 5].countWhere((int e) => e > 3), 2);
      });
      test('5. Count even numbers', () {
        expect(<int>[1, 2, 3, 4, 5, 6].countWhere((int e) => e.isEven), 3);
      });
      test('6. Count odd numbers', () {
        expect(<int>[1, 2, 3, 4, 5, 6].countWhere((int e) => e.isOdd), 3);
      });
      test('7. Works with strings', () {
        expect(
          <String>['apple', 'banana', 'cherry'].countWhere((String s) => s.startsWith('a')),
          1,
        );
      });
      test('8. Count negative numbers', () {
        expect(<int>[-2, -1, 0, 1, 2].countWhere((int e) => e < 0), 2);
      });
      test('9. Single element matches', () {
        expect(<int>[5].countWhere((int e) => e == 5), 1);
      });
      test('10. Single element does not match', () {
        expect(<int>[5].countWhere((int e) => e == 10), 0);
      });
      test('11. Count with length condition', () {
        expect(
          <String>['a', 'bb', 'ccc', 'dddd'].countWhere((String s) => s.length > 2),
          2,
        );
      });
      test('12. Count duplicates that match', () {
        expect(<int>[1, 1, 1, 2, 2, 3].countWhere((int e) => e == 1), 3);
      });
    });
  });

  group('chunks', () {
    test('even split', () {
      expect(<int>[1, 2, 3, 4].chunks(2).toList(), <List<int>>[
        [1, 2],
        [3, 4],
      ]);
    });
    test('last chunk smaller', () {
      expect(<int>[1, 2, 3, 4, 5].chunks(2).toList(), <List<int>>[
        [1, 2],
        [3, 4],
        [5],
      ]);
    });
    test('size 1', () {
      expect(<int>[1, 2].chunks(1).toList(), <List<int>>[
        [1],
        [2],
      ]);
    });
    test('size larger than list', () {
      expect(<int>[1, 2].chunks(10).toList(), <List<int>>[
        [1, 2],
      ]);
    });
    test('empty', () {
      expect(<int>[].chunks(2).toList(), <List<int>>[]);
    });
    test('size 0 throws', () {
      expect(() => <int>[1].chunks(0), throwsArgumentError);
    });
  });

  group('partition', () {
    test('splits by predicate', () {
      final (List<int> even, List<int> odd) = <int>[1, 2, 3, 4].partition((int x) => x.isEven);
      expect(even, [2, 4]);
      expect(odd, [1, 3]);
    });
    test('all match', () {
      final (List<int> a, List<int> b) = <int>[2, 4].partition((int x) => x.isEven);
      expect(a, [2, 4]);
      expect(b, <int>[]);
    });
    test('none match', () {
      final (List<int> a, List<int> b) = <int>[1, 3].partition((int x) => x.isEven);
      expect(a, <int>[]);
      expect(b, [1, 3]);
    });
    test('empty', () {
      final (List<int> a, List<int> b) = <int>[].partition((int x) => true);
      expect(a, <int>[]);
      expect(b, <int>[]);
    });
  });

  group('groupBy', () {
    test('by length', () {
      final Map<int, List<String>> m = <String>[
        'a',
        'ab',
        'b',
        'bc',
      ].groupBy((String s) => s.length);
      expect(m[1], ['a', 'b']);
      expect(m[2], ['ab', 'bc']);
    });
    test('empty', () {
      expect(<int>[].groupBy((int x) => x), <int, List<int>>{});
    });
    test('single key', () {
      final Map<String, List<int>> m = <int>[1, 2, 3].groupBy((int x) => 'same');
      expect(m['same'], [1, 2, 3]);
    });
  });

  group('slidingWindow', () {
    test('size 2', () {
      expect(<int>[1, 2, 3, 4].slidingWindow(2).toList(), <List<int>>[
        [1, 2],
        [2, 3],
        [3, 4],
      ]);
    });
    test('size 0 throws', () => expect(() => <int>[1].slidingWindow(0), throwsArgumentError));
  });

  group('flatten', () {
    test('one level', () {
      expect(
        <List<int>>[
          [1, 2],
          [3],
        ].flatten().toList(),
        [1, 2, 3],
      );
    });
  });

  group('distinctBy', () {
    test('by key', () {
      expect(<String>['a', 'ab', 'b'].distinctBy((String s) => s.length), ['a', 'ab']);
    });
  });

  group('sortBy', () {
    test('by length', () {
      expect(<String>['aa', 'b', 'ccc'].sortBy((String s) => s.length), ['b', 'aa', 'ccc']);
    });
  });

  group('zipWithIndex', () {
    test('basic', () {
      expect(<String>['a', 'b'].zipWithIndex().toList(), [(0, 'a'), (1, 'b')]);
    });
  });

  group('takeEveryNth', () {
    test('every 2', () {
      expect(<int>[1, 2, 3, 4].takeEveryNth(2).toList(), [1, 3]);
    });
  });

  group('dedupeConsecutive', () {
    test('removes consecutive dupes', () {
      expect(<int>[1, 1, 2, 2, 1].dedupeConsecutive().toList(), [1, 2, 1]);
    });
  });
}
