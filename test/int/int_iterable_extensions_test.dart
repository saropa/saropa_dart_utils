import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/int/int_iterable_extensions.dart';
import 'package:saropa_dart_utils/iterable/occurrence.dart';

void main() {
  group('ListIntExtensions', () {
    test('mostOccurrences', () {
      expect(<int>[3, 1, 4, 1, 5, 9, 1].mostOccurrences(), equals(Occurrence<int>(1, 3)));
      expect(<int>[10, 20, 10, 30, 10].mostOccurrences(), equals(Occurrence<int>(10, 3)));

      expect(
        <int>[1, 2, 3, 4, 5].mostOccurrences(),
        anyOf(
          equals(Occurrence<int>(1, 1)),
          equals(Occurrence<int>(2, 1)),
          equals(Occurrence<int>(3, 1)),
          equals(Occurrence<int>(4, 1)),
          equals(Occurrence<int>(5, 1)),
        ),
      );

      expect(<int>[].mostOccurrences(), isNull);
    });

    test('leastOccurrences', () {
      expect(
        <int>[3, 1, 4, 1, 5, 9, 1].leastOccurrences(),
        anyOf(
          equals(Occurrence<int>(3, 1)),
          equals(Occurrence<int>(4, 1)),
          equals(Occurrence<int>(5, 1)),
          equals(Occurrence<int>(9, 1)),
        ),
      );
      expect(
        <int>[10, 20, 10, 30, 10].leastOccurrences(),
        anyOf(equals(Occurrence<int>(20, 1)), equals(Occurrence<int>(30, 1))),
      );

      expect(
        <int>[1, 2, 3, 4, 5].leastOccurrences(),
        anyOf(
          equals(Occurrence<int>(1, 1)),
          equals(Occurrence<int>(2, 1)),
          equals(Occurrence<int>(3, 1)),
          equals(Occurrence<int>(4, 1)),
          equals(Occurrence<int>(5, 1)),
        ),
      );

      expect(<int>[].leastOccurrences(), isNull);
    });
  });
}
