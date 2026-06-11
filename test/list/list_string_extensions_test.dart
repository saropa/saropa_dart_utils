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
