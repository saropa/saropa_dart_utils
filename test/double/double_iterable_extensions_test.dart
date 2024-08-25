import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/double/double_iterable_extensions.dart';

void main() {
  group('DoubleListExtensions', () {
    test('smallestOccurrence', () {
      expect([3.5, 1.2, 4.8, 1.2, 5.9, 9.1].smallestOccurrence(), equals(1.2));
      expect(<double>[].smallestOccurrence(), isNull);
    });

    test('biggestOccurrence', () {
      expect([3.5, 1.2, 4.8, 1.2, 5.9, 9.1].biggestOccurrence(), equals(9.1));
      expect(<double>[].biggestOccurrence(), isNull);
    });

    test('mostOccurrences', () {
      expect(
        [3.5, 1.2, 4.8, 1.2, 5.9, 9.1, 1.2].mostOccurrences(),
        equals((1.2, 3)),
      );
      expect(<double>[].mostOccurrences(), isNull);
    });

    test('leastOccurrences', () {
      expect(
        [3.5, 1.2, 4.8, 1.2, 5.9, 9.1, 1.2].leastOccurrences(),
        anyOf(
          equals((3.5, 1)),
          equals((4.8, 1)),
          equals((5.9, 1)),
          equals((9.1, 1)),
        ),
      );
      expect(<double>[].leastOccurrences(), isNull);
    });
  });
}
