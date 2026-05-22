import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_first_last_extensions.dart';

void main() {
  group('firstWhereOrElse', () {
    test('returns first matching element', () {
      expect(<int>[1, 2, 3, 4].firstWhereOrElse((int x) => x > 2, -1), 3);
    });

    test('returns orElse when none match', () {
      expect(<int>[1, 2].firstWhereOrElse((int x) => x > 10, -1), -1);
    });

    test('returns orElse for empty iterable', () {
      expect(<int>[].firstWhereOrElse((int x) => true, 99), 99);
    });

    test('returns the FIRST of several matches', () {
      expect(<int>[5, 6, 7].firstWhereOrElse((int x) => x > 4, -1), 5);
    });

    test('works with strings', () {
      expect(
        <String>['ab', 'cde', 'f'].firstWhereOrElse((String s) => s.length == 1, 'none'),
        'f',
      );
    });
  });

  group('lastWhereOrElse', () {
    test('returns last matching element', () {
      expect(<int>[1, 2, 3, 4].lastWhereOrElse((int x) => x < 4, -1), 3);
    });

    test('returns orElse when none match', () {
      expect(<int>[1, 2].lastWhereOrElse((int x) => x > 10, -1), -1);
    });

    test('returns orElse for empty iterable', () {
      expect(<int>[].lastWhereOrElse((int x) => true, 99), 99);
    });

    test('returns the LAST of several matches', () {
      expect(<int>[5, 6, 7].lastWhereOrElse((int x) => x > 4, -1), 7);
    });

    test('works with strings', () {
      expect(
        <String>['a', 'bc', 'd'].lastWhereOrElse((String s) => s.length == 1, 'none'),
        'd',
      );
    });
  });
}
