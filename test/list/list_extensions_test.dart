import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_extensions.dart';

void main() {
  group('ListExtensions', () {
    group('equalsIgnoringOrder', () {
      // Test Case 1: Basic Equality - Two lists with the same elements in a different order.
      test('should return true for lists with same elements in different order', () {
        final List<int> listA = <int>[1, 2, 3];
        final List<int> listB = <int>[3, 1, 2];
        expect(listA.equalsIgnoringOrder(listB), isTrue);
      });

      // Test Case 2: Basic Inequality - Two lists with different elements.
      test('should return false for lists with different elements', () {
        final List<int> listA = <int>[1, 2, 3];
        final List<int> listB = <int>[1, 2, 4];
        expect(listA.equalsIgnoringOrder(listB), isFalse);
      });

      // Test Case 3: Duplicate Elements - Lists with duplicate elements that are still considered equal.
      test('should return true when duplicates are present but unique elements match', () {
        final List<int> listA = <int>[1, 2, 2, 3];
        final List<int> listB = <int>[3, 2, 1, 2];
        expect(listA.equalsIgnoringOrder(listB), isTrue);
      });

      // Test Case 4: Empty Lists - Comparing two empty lists.
      test('should return true for two empty lists', () {
        final List<int> listA = <int>[];
        final List<int> listB = <int>[];
        expect(listA.equalsIgnoringOrder(listB), isTrue);
      });

      // Test Case 5: One Empty List - Comparing an empty list with a non-empty list.
      test('should return false when one list is empty and the other is not', () {
        final List<int> listA = <int>[];
        final List<int> listB = <int>[1];
        expect(listA.equalsIgnoringOrder(listB), isFalse);
      });

      // Test Case 6: Different Lengths - Comparing two lists with different numbers of elements.
      test('should return false for lists with different lengths', () {
        final List<int> listA = <int>[1, 2, 3];
        final List<int> listB = <int>[1, 2];
        expect(listA.equalsIgnoringOrder(listB), isFalse);
      });

      // Test Case 7: Identical Lists - Comparing a list to itself, which should always be true.
      test('should return true when comparing a list to itself', () {
        final List<int> listA = <int>[1, 2, 3];
        expect(listA.equalsIgnoringOrder(listA), isTrue);
      });

      // Test Case 8: Lists with Nulls - Comparing lists that both contain null values.
      test('should return true for lists with same elements including nulls', () {
        final List<int?> listA = <int?>[1, null, 3];
        final List<int?> listB = <int?>[3, 1, null];
        expect(listA.equalsIgnoringOrder(listB), isTrue);
      });

      // Test Case 9: One Null List - Comparing a non-null list to a null list.
      test('should return false when comparing a non-null list to a null list', () {
        final List<int> listA = <int>[1, 2, 3];
        expect(listA.equalsIgnoringOrder(null), isFalse);
      });

      // Test Case 10: Different Data Types (when T is dynamic or Object)
      // Note: If T is explicitly defined (e.g., List<int>), this test might not compile.
      // It's valid if the lists are `List<Object>` or `List<dynamic>`.
      test('should return false for lists with elements of different types (if allowed by T)', () {
        final List<Object> listA = <Object>[1, 'a', 3];
        final List<Object> listB = <Object>[3, 1, 'b']; // 'b' is different from 'a'
        expect(listA.equalsIgnoringOrder(listB), isFalse);
      });
    });

    group('topOccurrence', () {
      test('Empty list returns null', () {
        final List<String> list = <String>[];
        expect(list.topOccurrence(), null);
      });

      test('List with one element', () {
        final List<String> list = <String>['apple'];
        expect(list.topOccurrence(), 'apple');
      });

      test('List with multiple unique elements', () {
        final List<String> list = <String>['apple', 'banana', 'cherry'];
        expect(list.topOccurrence(), 'apple'); // Returns the first encountered
      });

      test('List with one dominant element', () {
        final List<String> list = <String>['apple', 'apple', 'apple', 'banana', 'cherry'];
        expect(list.topOccurrence(), 'apple');
      });

      test('List with multiple elements with same max occurrence - returns first', () {
        final List<String> list = <String>['apple', 'apple', 'banana', 'banana', 'cherry'];
        expect(list.topOccurrence(), 'apple'); // Returns the first encountered
      });

      test('List with numbers', () {
        final List<int> list = <int>[1, 2, 2, 3, 3, 3];
        expect(list.topOccurrence(), 3);
      });

      test('List with mixed types (using toString for comparison)', () {
        final List<dynamic> list = <dynamic>['a', 1, 'a', true, 'a'];
        expect(list.topOccurrence(), 'a');
      });

      test('List with null values (nulls are counted)', () {
        final List<String?> list = <String?>['apple', null, 'apple', null, null];
        expect(list.topOccurrence(), null);
      });

      test('List with symbols', () {
        final List<String> list = <String>['#', '#', '@', '%', '#'];
        expect(list.topOccurrence(), '#');
      });

      test('Long list with repeated elements', () {
        final List<String> list =
            List<String>.generate(
              100,
              (int index) => index % 3 == 0 ? 'a' : (index % 3 == 1 ? 'b' : 'c'),
            ) +
            <String>['a', 'a'];
        expect(list.topOccurrence(), 'a');
      });
    });

    group('addNotNull', () {
      test('Add not null value', () {
        final List<String> list = <String>[]..addNotNull('apple');
        expect(list, <String>['apple']);
      });

      test('Add null value', () {
        final List<String> list = <String>[]..addNotNull(null);
        expect(list, isEmpty);
      });

      test('Add multiple values, some null', () {
        final List<String> list = <String>[]
          ..addNotNull('apple')
          ..addNotNull(null)
          ..addNotNull('banana');
        expect(list, <String>['apple', 'banana']);
      });

      test('Add null to existing list', () {
        final List<String> list = <String>['apple']..addNotNull(null);
        expect(list, <String>['apple']);
      });

      test('Add not null to existing list', () {
        final List<String> list = <String>['apple']..addNotNull('banana');
        expect(list, <String>['apple', 'banana']);
      });

      test('Add null when list is not empty', () {
        final List<int> list = <int>[1]..addNotNull(null);
        expect(list, <int>[1]);
      });

      test('Add not null int value', () {
        final List<int> list = <int>[]..addNotNull(10);
        expect(list, <int>[10]);
      });

      test('Add not null boolean value', () {
        final List<bool> list = <bool>[]..addNotNull(true);
        expect(list, <bool>[true]);
      });

      test('Add null to empty list of integers', () {
        final List<int> list = <int>[]..addNotNull(null);
        expect(list, <int>[]);
      });

      test('Add not null string to empty list', () {
        final List<String> list = <String>[]..addNotNull('test');
        expect(list, <String>['test']);
      });
    });

    group('limit', () {
      test('Limit 0 returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.limit(0), list);
      });

      test('Negative limit returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.limit(-1), list);
      });

      test('Limit equal to list length returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.limit(3), list);
      });

      test('Limit smaller than list length', () {
        final List<int> list = <int>[1, 2, 3, 4, 5];
        expect(list.limit(3), <int>[1, 2, 3]);
      });

      test('Limit larger than list length returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.limit(5), list);
      });

      test('Empty list returns empty list for any limit', () {
        final List<int> list = <int>[];
        expect(list.limit(3), <int>[]);
        expect(list.limit(0), <int>[]);
        expect(list.limit(-1), <int>[]);
      });

      test('Limit with a list of strings', () {
        final List<String> list = <String>['a', 'b', 'c', 'd'];
        expect(list.limit(2), <String>['a', 'b']);
      });

      test('Limit 1 returns first element list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.limit(1), <int>[1]);
      });

      test('Limit with decimal numbers', () {
        final List<double> list = <double>[1.1, 2.2, 3.3, 4.4];
        expect(list.limit(2), <double>[1.1, 2.2]);
      });

      test('Limit with negative numbers', () {
        final List<int> list = <int>[-1, -2, -3, -4, -5];
        expect(list.limit(3), <int>[-1, -2, -3]);
      });
    });

    group('lastOrNull', () {
      test('Empty list returns null', () {
        final List<int> list = <int>[];
        expect(list.lastOrNull, null);
      });

      test('List with one element returns that element', () {
        final List<int> list = <int>[1];
        expect(list.lastOrNull, 1);
      });

      test('List with multiple elements returns last element', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.lastOrNull, 3);
      });

      test('List with null last element returns null', () {
        final List<String?> list = <String?>['a', 'b', null];
        expect(list.lastOrNull, null);
      });

      test('List of strings returns last string', () {
        final List<String> list = <String>['apple', 'banana', 'cherry'];
        expect(list.lastOrNull, 'cherry');
      });

      test('List of doubles returns last double', () {
        final List<double> list = <double>[1.1, 2.2, 3.3];
        expect(list.lastOrNull, 3.3);
      });

      test('List with negative numbers returns last negative number', () {
        final List<int> list = <int>[-1, -2, -3];
        expect(list.lastOrNull, -3);
      });

      test('List with zero returns zero', () {
        final List<int> list = <int>[1, 2, 0];
        expect(list.lastOrNull, 0);
      });

      test('List with mixed types returns last element', () {
        final List<dynamic> list = <dynamic>[1, 'a', true];
        expect(list.lastOrNull, true);
      });

      test('List with only null element', () {
        final List<String?> list = <String?>[null];
        expect(list.lastOrNull, null);
      });
    });

    group('itemAt / safeIndex', () {
      test('Null index returns null', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.itemAt(null), null);
      });

      test('Empty list returns null for any index', () {
        final List<int> list = <int>[];
        expect(list.itemAt(0), null);
        expect(list.itemAt(1), null);
        expect(list.itemAt(-1), null);
      });

      test('Valid index 0 returns first element', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.itemAt(0), 1);
      });

      test('Valid index in the middle returns correct element', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.itemAt(1), 2);
      });

      test('Valid last index returns last element', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.itemAt(2), 3);
      });

      test('Index out of range (positive) returns null', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.itemAt(3), null);
      });

      test('Index out of range (negative) returns null', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.itemAt(-1), null);
      });

      test('List of strings, valid index', () {
        final List<String> list = <String>['a', 'b', 'c'];
        expect(list.itemAt(1), 'b');
      });

      test('List of doubles, valid index', () {
        final List<double> list = <double>[1.1, 2.2, 3.3];
        expect(list.itemAt(2), 3.3);
      });

      test('List with null element at valid index', () {
        final List<String?> list = <String?>['a', null, 'c'];
        expect(list.itemAt(1), null);
      });
    });

    group('nullIfEmpty', () {
      test('Empty list returns null', () {
        final List<int> list = <int>[];
        expect(list.nullIfEmpty(), null);
      });

      test('Non-empty list returns the list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.nullIfEmpty(), list);
      });

      test('List with null elements returns the list', () {
        final List<String?> list = <String?>[null, null];
        expect(list.nullIfEmpty(), list);
      });

      test('List with one element returns the list', () {
        final List<String> list = <String>['a'];
        expect(list.nullIfEmpty(), list);
      });

      test('List with mixed elements returns the list', () {
        final List<dynamic> list = <dynamic>[1, 'a', true];
        expect(list.nullIfEmpty(), list);
      });

      test('Non-empty list of strings returns the list', () {
        final List<String> list = <String>['apple', 'banana'];
        expect(list.nullIfEmpty(), list);
      });

      test('Non-empty list of doubles returns the list', () {
        final List<double> list = <double>[1.1, 2.2];
        expect(list.nullIfEmpty(), list);
      });

      test('List with zero returns the list', () {
        final List<int> list = <int>[0];
        expect(list.nullIfEmpty(), list);
      });

      test('List with negative number returns the list', () {
        final List<int> list = <int>[-1];
        expect(list.nullIfEmpty(), list);
      });

      test('List with spaces returns the list', () {
        final List<String> list = <String>[' '];
        expect(list.nullIfEmpty(), list);
      });
    });

    group('takeSafe', () {
      test('Null count returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.takeSafe(null), list);
      });

      test('Count 0 with ignoreZeroOrLess true returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.takeSafe(0, ignoreZeroOrLess: true), list);
      });

      test('Count 0 with ignoreZeroOrLess false returns empty list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.takeSafe(0, ignoreZeroOrLess: false), <int>[]);
      });

      test('Negative count with ignoreZeroOrLess true returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.takeSafe(-1, ignoreZeroOrLess: true), list);
      });

      test('Negative count with ignoreZeroOrLess false returns empty list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.takeSafe(-1, ignoreZeroOrLess: false), <int>[]);
      });

      test('Count smaller than list length', () {
        final List<int> list = <int>[1, 2, 3, 4, 5];
        expect(list.takeSafe(3), <int>[1, 2, 3]);
      });

      test('Count equal to list length returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.takeSafe(3), list);
      });

      test('Count larger than list length returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.takeSafe(5), list);
      });

      test('Empty list returns empty list for any count', () {
        final List<int> list = <int>[];
        expect(list.takeSafe(3), <int?>[]);
        expect(list.takeSafe(0), <int?>[]);
        expect(list.takeSafe(-1), <int?>[]);
        expect(list.takeSafe(null), <int?>[]);
      });

      test('Take safe with list of strings', () {
        final List<String> list = <String>['a', 'b', 'c', 'd'];
        expect(list.takeSafe(2), <String>['a', 'b']);
      });
    });

    group('exclude', () {
      test('Null exclude list returns original list', () {
        final List<int?> list = <int?>[1, 2, 3];
        expect(list.exclude(<int?>[]), list);
      });

      test('Empty exclude list returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.exclude(<int>[]), list);
      });

      test('Empty input list returns empty list', () {
        final List<int> list = <int>[];
        expect(list.exclude(<int>[1, 2]), <int>[]);
      });

      test('Some elements to exclude', () {
        final List<int> list = <int>[1, 2, 3, 4, 5];
        expect(list.exclude(<int>[2, 4]), <int>[1, 3, 5]);
      });

      test('All elements to exclude returns empty list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.exclude(<int>[1, 2, 3]), <int>[]);
      });

      test('No elements to exclude returns original list', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.exclude(<int>[4, 5, 6]), <int>[1, 2, 3]);
      });

      test('Exclude list with duplicates', () {
        final List<int> list = <int>[1, 2, 3, 4, 5];
        expect(list.exclude(<int>[2, 2, 4, 4]), <int>[1, 3, 5]);
      });

      test('Exclude list with different types (using contains equality)', () {
        final List<dynamic> list = <dynamic>[1, '2', true, 4.0];
        expect(list.exclude(<dynamic>['2', 4.0]), <Object>[1, true]);
      });

      test('Exclude with list of strings', () {
        final List<String> list = <String>['a', 'b', 'c', 'd'];
        expect(list.exclude(<String>['b', 'd']), <String>['a', 'c']);
      });

      test('Exclude with empty input and empty exclude list returns empty list', () {
        final List<String> list = <String>[];
        expect(list.exclude(<String>[]), <String>[]);
      });
    });

    group('containsAny', () {
      test('Empty list returns false', () {
        final List<int> list = <int>[];
        expect(list.containsAny(<int>[1, 2]), false);
      });

      test('Null inThis list returns false', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.containsAny(null), false);
      });

      test('Empty inThis list returns false', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.containsAny(<int>[]), false);
      });

      test('List contains one element from inThis', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.containsAny(<int>[3, 4]), true);
      });

      test('List contains multiple elements from inThis', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.containsAny(<int>[2, 3, 4]), true);
      });

      test('List contains all elements from inThis', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.containsAny(<int>[1, 2, 3]), true);
      });

      test('List contains no elements from inThis returns false', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.containsAny(<int>[4, 5, 6]), false);
      });

      test('inThis list with duplicates', () {
        final List<int> list = <int>[1, 2, 3];
        expect(list.containsAny(<int>[3, 3, 4]), true);
      });

      test('List of strings contains any from inThis strings', () {
        final List<String> list = <String>['a', 'b', 'c'];
        expect(list.containsAny(<String>['c', 'd']), true);
      });

      test('List with different types, contains any (using contains equality)', () {
        final List<dynamic> list = <dynamic>[1, '2', true];
        expect(list.containsAny(<dynamic>['2', false]), true); // '2' is String, should match
      });

      test('Empty input list and empty inThis list returns false', () {
        final List<String> list = <String>[];
        expect(list.containsAny(<String>[]), false);
      });
    });
  });
}
