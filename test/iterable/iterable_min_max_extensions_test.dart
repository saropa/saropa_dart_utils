import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_min_max_extensions.dart';

void main() {
  group('minBy', () {
    test('returns element with minimum key', () {
      // Shortest string by length.
      expect(<String>['aaa', 'b', 'cc'].minBy((String s) => s.length), 'b');
    });

    test('returns null for empty iterable', () {
      expect(<String>[].minBy((String s) => s.length), isNull);
    });

    test('single element returns itself', () {
      expect(<int>[5].minBy((int x) => x), 5);
    });

    test('on a tie keeps the first-encountered element', () {
      // Both 'ab' and 'cd' have length 2; strict < keeps the first.
      expect(<String>['ab', 'cd'].minBy((String s) => s.length), 'ab');
    });

    test('works with negative keys', () {
      expect(<int>[-1, -5, -3].minBy((int x) => x), -5);
    });
  });

  group('maxBy', () {
    test('returns element with maximum key', () {
      expect(<String>['a', 'bbb', 'cc'].maxBy((String s) => s.length), 'bbb');
    });

    test('returns null for empty iterable', () {
      expect(<String>[].maxBy((String s) => s.length), isNull);
    });

    test('single element returns itself', () {
      expect(<int>[5].maxBy((int x) => x), 5);
    });

    test('on a tie keeps the first-encountered element', () {
      // Both length 2; strict > keeps the first.
      expect(<String>['ab', 'cd'].maxBy((String s) => s.length), 'ab');
    });

    test('works with negative keys', () {
      expect(<int>[-1, -5, -3].maxBy((int x) => x), -1);
    });
  });
}
