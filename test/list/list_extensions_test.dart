import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_extensions.dart';

void main() {
  group('ListExtensions', () {
    group('topOccurrence', () {
      test('Empty list returns null', () {
        final List<String> list = [];
        expect(list.topOccurrence(), null);
      });

      test('List with one element', () {
        final List<String> list = ['apple'];
        expect(list.topOccurrence(), 'apple');
      });

      test('List with multiple unique elements', () {
        final List<String> list = ['apple', 'banana', 'cherry'];
        expect(list.topOccurrence(), 'apple'); // Returns the first encountered
      });

      test('List with one dominant element', () {
        final List<String> list = ['apple', 'apple', 'apple', 'banana', 'cherry'];
        expect(list.topOccurrence(), 'apple');
      });

      test('List with multiple elements with same max occurrence - returns first', () {
        final List<String> list = ['apple', 'apple', 'banana', 'banana', 'cherry'];
        expect(list.topOccurrence(), 'apple'); // Returns the first encountered
      });

      test('List with numbers', () {
        final List<int> list = [1, 2, 2, 3, 3, 3];
        expect(list.topOccurrence(), 3);
      });

      test('List with mixed types (using toString for comparison)', () {
        final List<dynamic> list = ['a', 1, 'a', true, 'a'];
        expect(list.topOccurrence(), 'a');
      });

      test('List with null values (nulls are counted)', () {
        final List<String?> list = ['apple', null, 'apple', null, null];
        expect(list.topOccurrence(), null);
      });

      test('List with symbols', () {
        final List<String> list = ['#', '#', '@', '%', '#'];
        expect(list.topOccurrence(), '#');
      });

      test('Long list with repeated elements', () {
        final List<String> list =
            List.generate(100, (index) => index % 3 == 0 ? 'a' : (index % 3 == 1 ? 'b' : 'c')) +
            ['a', 'a'];
        expect(list.topOccurrence(), 'a');
      });
    });

    group('addNotNull', () {
      test('Add not null value', () {
        final List<String> list = []..addNotNull('apple');
        expect(list, ['apple']);
      });

      test('Add null value', () {
        final List<String> list = []..addNotNull(null);
        expect(list, isEmpty);
      });

      test('Add multiple values, some null', () {
        final List<String> list =
            []
              ..addNotNull('apple')
              ..addNotNull(null)
              ..addNotNull('banana');
        expect(list, ['apple', 'banana']);
      });

      test('Add null to existing list', () {
        final List<String> list = ['apple']..addNotNull(null);
        expect(list, ['apple']);
      });

      test('Add not null to existing list', () {
        final List<String> list = ['apple']..addNotNull('banana');
        expect(list, ['apple', 'banana']);
      });

      test('Add null when list is not empty', () {
        final List<int> list = [1]..addNotNull(null);
        expect(list, [1]);
      });

      test('Add not null int value', () {
        final List<int> list = []..addNotNull(10);
        expect(list, [10]);
      });

      test('Add not null boolean value', () {
        final List<bool> list = []..addNotNull(true);
        expect(list, [true]);
      });

      test('Add null to empty list of integers', () {
        final List<int> list = []..addNotNull(null);
        expect(list, <int>[]);
      });

      test('Add not null string to empty list', () {
        final List<String> list = []..addNotNull('test');
        expect(list, ['test']);
      });
    });

    group('limit', () {
      test('Limit 0 returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.limit(0), list);
      });

      test('Negative limit returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.limit(-1), list);
      });

      test('Limit equal to list length returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.limit(3), list);
      });

      test('Limit smaller than list length', () {
        final List<int> list = [1, 2, 3, 4, 5];
        expect(list.limit(3), [1, 2, 3]);
      });

      test('Limit larger than list length returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.limit(5), list);
      });

      test('Empty list returns empty list for any limit', () {
        final List<int> list = [];
        expect(list.limit(3), <int>[]);
        expect(list.limit(0), <int>[]);
        expect(list.limit(-1), <int>[]);
      });

      test('Limit with a list of strings', () {
        final List<String> list = ['a', 'b', 'c', 'd'];
        expect(list.limit(2), ['a', 'b']);
      });

      test('Limit 1 returns first element list', () {
        final List<int> list = [1, 2, 3];
        expect(list.limit(1), [1]);
      });

      test('Limit with decimal numbers', () {
        final List<double> list = [1.1, 2.2, 3.3, 4.4];
        expect(list.limit(2), [1.1, 2.2]);
      });

      test('Limit with negative numbers', () {
        final List<int> list = [-1, -2, -3, -4, -5];
        expect(list.limit(3), [-1, -2, -3]);
      });
    });

    group('lastOrNull', () {
      test('Empty list returns null', () {
        final List<int> list = [];
        expect(list.lastOrNull, null);
      });

      test('List with one element returns that element', () {
        final List<int> list = [1];
        expect(list.lastOrNull, 1);
      });

      test('List with multiple elements returns last element', () {
        final List<int> list = [1, 2, 3];
        expect(list.lastOrNull, 3);
      });

      test('List with null last element returns null', () {
        final List<String?> list = ['a', 'b', null];
        expect(list.lastOrNull, null);
      });

      test('List of strings returns last string', () {
        final List<String> list = ['apple', 'banana', 'cherry'];
        expect(list.lastOrNull, 'cherry');
      });

      test('List of doubles returns last double', () {
        final List<double> list = [1.1, 2.2, 3.3];
        expect(list.lastOrNull, 3.3);
      });

      test('List with negative numbers returns last negative number', () {
        final List<int> list = [-1, -2, -3];
        expect(list.lastOrNull, -3);
      });

      test('List with zero returns zero', () {
        final List<int> list = [1, 2, 0];
        expect(list.lastOrNull, 0);
      });

      test('List with mixed types returns last element', () {
        final List<dynamic> list = [1, 'a', true];
        expect(list.lastOrNull, true);
      });

      test('List with only null element', () {
        final List<String?> list = [null];
        expect(list.lastOrNull, null);
      });
    });

    group('itemAt / safeIndex', () {
      test('Null index returns null', () {
        final List<int> list = [1, 2, 3];
        expect(list.itemAt(null), null);
      });

      test('Empty list returns null for any index', () {
        final List<int> list = [];
        expect(list.itemAt(0), null);
        expect(list.itemAt(1), null);
        expect(list.itemAt(-1), null);
      });

      test('Valid index 0 returns first element', () {
        final List<int> list = [1, 2, 3];
        expect(list.itemAt(0), 1);
      });

      test('Valid index in the middle returns correct element', () {
        final List<int> list = [1, 2, 3];
        expect(list.itemAt(1), 2);
      });

      test('Valid last index returns last element', () {
        final List<int> list = [1, 2, 3];
        expect(list.itemAt(2), 3);
      });

      test('Index out of range (positive) returns null', () {
        final List<int> list = [1, 2, 3];
        expect(list.itemAt(3), null);
      });

      test('Index out of range (negative) returns null', () {
        final List<int> list = [1, 2, 3];
        expect(list.itemAt(-1), null);
      });

      test('List of strings, valid index', () {
        final List<String> list = ['a', 'b', 'c'];
        expect(list.itemAt(1), 'b');
      });

      test('List of doubles, valid index', () {
        final List<double> list = [1.1, 2.2, 3.3];
        expect(list.itemAt(2), 3.3);
      });

      test('List with null element at valid index', () {
        final List<String?> list = ['a', null, 'c'];
        expect(list.itemAt(1), null);
      });
    });

    group('nullIfEmpty', () {
      test('Empty list returns null', () {
        final List<int> list = [];
        expect(list.nullIfEmpty(), null);
      });

      test('Non-empty list returns the list', () {
        final List<int> list = [1, 2, 3];
        expect(list.nullIfEmpty(), list);
      });

      test('List with null elements returns the list', () {
        final List<String?> list = [null, null];
        expect(list.nullIfEmpty(), list);
      });

      test('List with one element returns the list', () {
        final List<String> list = ['a'];
        expect(list.nullIfEmpty(), list);
      });

      test('List with mixed elements returns the list', () {
        final List<dynamic> list = [1, 'a', true];
        expect(list.nullIfEmpty(), list);
      });

      test('Non-empty list of strings returns the list', () {
        final List<String> list = ['apple', 'banana'];
        expect(list.nullIfEmpty(), list);
      });

      test('Non-empty list of doubles returns the list', () {
        final List<double> list = [1.1, 2.2];
        expect(list.nullIfEmpty(), list);
      });

      test('List with zero returns the list', () {
        final List<int> list = [0];
        expect(list.nullIfEmpty(), list);
      });

      test('List with negative number returns the list', () {
        final List<int> list = [-1];
        expect(list.nullIfEmpty(), list);
      });

      test('List with spaces returns the list', () {
        final List<String> list = [' '];
        expect(list.nullIfEmpty(), list);
      });
    });

    group('takeSafe', () {
      test('Null count returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.takeSafe(null), list);
      });

      test('Count 0 with ignoreZeroOrLess true returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.takeSafe(0, ignoreZeroOrLess: true), list);
      });

      test('Count 0 with ignoreZeroOrLess false returns empty list', () {
        final List<int> list = [1, 2, 3];
        expect(list.takeSafe(0, ignoreZeroOrLess: false), <int>[]);
      });

      test('Negative count with ignoreZeroOrLess true returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.takeSafe(-1, ignoreZeroOrLess: true), list);
      });

      test('Negative count with ignoreZeroOrLess false returns empty list', () {
        final List<int> list = [1, 2, 3];
        expect(list.takeSafe(-1, ignoreZeroOrLess: false), <int>[]);
      });

      test('Count smaller than list length', () {
        final List<int> list = [1, 2, 3, 4, 5];
        expect(list.takeSafe(3), [1, 2, 3]);
      });

      test('Count equal to list length returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.takeSafe(3), list);
      });

      test('Count larger than list length returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.takeSafe(5), list);
      });

      test('Empty list returns empty list for any count', () {
        final List<int> list = [];
        expect(list.takeSafe(3), <int?>[]);
        expect(list.takeSafe(0), <int?>[]);
        expect(list.takeSafe(-1), <int?>[]);
        expect(list.takeSafe(null), <int?>[]);
      });

      test('Take safe with list of strings', () {
        final List<String> list = ['a', 'b', 'c', 'd'];
        expect(list.takeSafe(2), ['a', 'b']);
      });
    });

    group('exclude', () {
      test('Null exclude list returns original list', () {
        final List<int?> list = <int?>[1, 2, 3];
        expect(list.exclude(<int?>[]), list);
      });

      test('Empty exclude list returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.exclude([]), list);
      });

      test('Empty input list returns empty list', () {
        final List<int> list = [];
        expect(list.exclude([1, 2]), <int>[]);
      });

      test('Some elements to exclude', () {
        final List<int> list = [1, 2, 3, 4, 5];
        expect(list.exclude([2, 4]), [1, 3, 5]);
      });

      test('All elements to exclude returns empty list', () {
        final List<int> list = [1, 2, 3];
        expect(list.exclude([1, 2, 3]), <int>[]);
      });

      test('No elements to exclude returns original list', () {
        final List<int> list = [1, 2, 3];
        expect(list.exclude([4, 5, 6]), [1, 2, 3]);
      });

      test('Exclude list with duplicates', () {
        final List<int> list = [1, 2, 3, 4, 5];
        expect(list.exclude([2, 2, 4, 4]), [1, 3, 5]);
      });

      test('Exclude list with different types (using contains equality)', () {
        final List<dynamic> list = [1, '2', true, 4.0];
        expect(list.exclude(['2', 4.0]), [1, true]);
      });

      test('Exclude with list of strings', () {
        final List<String> list = ['a', 'b', 'c', 'd'];
        expect(list.exclude(['b', 'd']), ['a', 'c']);
      });

      test('Exclude with empty input and empty exclude list returns empty list', () {
        final List<String> list = [];
        expect(list.exclude([]), <String>[]);
      });
    });

    group('containsAny', () {
      test('Empty list returns false', () {
        final List<int> list = [];
        expect(list.containsAny([1, 2]), false);
      });

      test('Null inThis list returns false', () {
        final List<int> list = [1, 2, 3];
        expect(list.containsAny(null), false);
      });

      test('Empty inThis list returns false', () {
        final List<int> list = [1, 2, 3];
        expect(list.containsAny([]), false);
      });

      test('List contains one element from inThis', () {
        final List<int> list = [1, 2, 3];
        expect(list.containsAny([3, 4]), true);
      });

      test('List contains multiple elements from inThis', () {
        final List<int> list = [1, 2, 3];
        expect(list.containsAny([2, 3, 4]), true);
      });

      test('List contains all elements from inThis', () {
        final List<int> list = [1, 2, 3];
        expect(list.containsAny([1, 2, 3]), true);
      });

      test('List contains no elements from inThis returns false', () {
        final List<int> list = [1, 2, 3];
        expect(list.containsAny([4, 5, 6]), false);
      });

      test('inThis list with duplicates', () {
        final List<int> list = [1, 2, 3];
        expect(list.containsAny([3, 3, 4]), true);
      });

      test('List of strings contains any from inThis strings', () {
        final List<String> list = ['a', 'b', 'c'];
        expect(list.containsAny(['c', 'd']), true);
      });

      test('List with different types, contains any (using contains equality)', () {
        final List<dynamic> list = [1, '2', true];
        expect(list.containsAny(['2', false]), true); // '2' is String, should match
      });

      test('Empty input list and empty inThis list returns false', () {
        final List<String> list = [];
        expect(list.containsAny([]), false);
      });
    });
  });
}
