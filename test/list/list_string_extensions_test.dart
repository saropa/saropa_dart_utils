import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_string_extensions.dart';

void main() {
  group('commonPrefix', () {
    test('basic', () => expect(<String>['flower', 'flow', 'flight'].commonPrefix(), 'fl'));
    test('no common', () => expect(<String>['a', 'b'].commonPrefix(), ''));
    test('empty list', () => expect(<String>[].commonPrefix(), ''));
  });
  group('commonSuffix', () {
    test('basic', () => expect(<String>['ending', 'ding'].commonSuffix(), 'ding'));
    test('full suffix', () => expect(<String>['abc', 'bc'].commonSuffix(), 'bc'));
  });

  group('joinDisplayList', () {
    test('should return null for an empty list', () {
      expect(<String>[].joinDisplayList(), isNull);
    });

    test('should return the single item for a one-item list', () {
      expect(<String>['Alice'].joinDisplayList(), 'Alice');
    });

    test('should join two items with the double joiner', () {
      expect(<String>['Alice', 'Bob'].joinDisplayList(), 'Alice and Bob');
    });

    test('should Oxford-comma join three or more items', () {
      expect(
        <String>['Alice', 'Bob', 'Carol'].joinDisplayList(),
        'Alice, Bob, and Carol',
      );
    });

    test('should Oxford-comma join four items (multiple middle commas)', () {
      // Four items exercises more than one mid-list comma, which the 3-item
      // case cannot — the only place the "comma between every non-final pair"
      // path is verified beyond a single comma.
      expect(
        <String>['A', 'B', 'C', 'D'].joinDisplayList(),
        'A, B, C, and D',
      );
    });

    test('should Oxford-comma join five items', () {
      expect(
        <String>['A', 'B', 'C', 'D', 'E'].joinDisplayList(),
        'A, B, C, D, and E',
      );
    });

    test('should de-duplicate by default (isUnique true)', () {
      expect(
        <String>['Alice', 'Bob', 'Alice'].joinDisplayList(),
        'Alice and Bob',
      );
    });

    test('should keep duplicates when isUnique is false', () {
      expect(
        <String>['Alice', 'Bob', 'Alice'].joinDisplayList(isUnique: false),
        'Alice, Bob, and Alice',
      );
    });

    test('should trim entries and drop blank/whitespace-only entries', () {
      expect(
        <String>[' Alice ', '', '  ', 'Bob'].joinDisplayList(),
        'Alice and Bob',
      );
    });

    test('should collapse to a single item when only one entry survives trimming', () {
      expect(<String>['', '  ', ' Alice '].joinDisplayList(), 'Alice');
    });

    test('should return null when every entry is blank', () {
      expect(<String>['', '   ', '\t'].joinDisplayList(), isNull);
    });

    test('should honor custom joiners', () {
      expect(
        <String>['a', 'b', 'c'].joinDisplayList(
          joiner: '; ',
          lastJoiner: '; or ',
        ),
        'a; b; or c',
      );
    });

    test('should honor a custom double joiner', () {
      expect(
        <String>['a', 'b'].joinDisplayList(doubleJoiner: ' or '),
        'a or b',
      );
    });
  });
}
