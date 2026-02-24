import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/double/double_iterable_extensions.dart';
import 'package:saropa_dart_utils/iterable/occurrence.dart';

void main() {
  group('DoubleListExtensions', () {
    test('smallestOccurrence', () {
      expect(<double>[3.5, 1.2, 4.8, 1.2, 5.9, 9.1].smallestOccurrence(), equals(1.2));
      expect(<double>[].smallestOccurrence(), isNull);
    });

    test('biggestOccurrence', () {
      expect(<double>[3.5, 1.2, 4.8, 1.2, 5.9, 9.1].biggestOccurrence(), equals(9.1));
      expect(<double>[].biggestOccurrence(), isNull);
    });

    test('mostOccurrences', () {
      expect(<double>[3.5, 1.2, 4.8, 1.2, 5.9, 9.1, 1.2].mostOccurrences(), equals(Occurrence<double>(1.2, 3)));
      expect(<double>[].mostOccurrences(), isNull);
    });

    test('leastOccurrences', () {
      expect(
        <double>[3.5, 1.2, 4.8, 1.2, 5.9, 9.1, 1.2].leastOccurrences(),
        anyOf(
          equals(Occurrence<double>(3.5, 1)),
          equals(Occurrence<double>(4.8, 1)),
          equals(Occurrence<double>(5.9, 1)),
          equals(Occurrence<double>(9.1, 1)),
        ),
      );
      expect(<double>[].leastOccurrences(), isNull);
    });
  });
}
