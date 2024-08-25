import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_int_extensions.dart';

void main() {
  group('ListIntExtensions', () {
    test('mostOccurrences', () {
      expect([3, 1, 4, 1, 5, 9, 1].mostOccurrences(), equals((1, 3)));
      expect([10, 20, 10, 30, 10].mostOccurrences(), equals((10, 3)));

      expect(
        [1, 2, 3, 4, 5].mostOccurrences(),
        anyOf(
          equals((1, 1)),
          equals((2, 1)),
          equals((3, 1)),
          equals((4, 1)),
          equals((5, 1)),
        ),
      );

      expect(<int>[].mostOccurrences(), isNull);
    });

    test('leastOccurrences', () {
      expect(
        [3, 1, 4, 1, 5, 9, 1].leastOccurrences(),
        anyOf(
          equals((3, 1)),
          equals((4, 1)),
          equals((5, 1)),
          equals((9, 1)),
        ),
      );
      expect(
        [10, 20, 10, 30, 10].leastOccurrences(),
        anyOf(
          equals((20, 1)),
          equals((30, 1)),
        ),
      );

      expect(
        [1, 2, 3, 4, 5].leastOccurrences(),
        anyOf(
          equals((1, 1)),
          equals((2, 1)),
          equals((3, 1)),
          equals((4, 1)),
          equals((5, 1)),
        ),
      );

      expect(<int>[].leastOccurrences(), isNull);
    });
  });
}
