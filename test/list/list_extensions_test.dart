import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_extensions.dart';

void main() {
  group('ListExtensions', () {
    test('smallestOccurrence', () {
      expect(
        ['apple', 'banana', 'cherry'].smallestOccurrence(),
        equals('apple'),
      );
      expect(
        [
          DateTime(2022),
          DateTime(2021),
          DateTime(2023),
        ].smallestOccurrence(),
        equals(DateTime(2021)),
      );
    });

    test('biggestOccurrence', () {
      expect(
        ['apple', 'banana', 'cherry'].biggestOccurrence(),
        equals('cherry'),
      );
      expect(
        [
          DateTime(2022),
          DateTime(2021),
          DateTime(2023),
        ].biggestOccurrence(),
        equals(DateTime(2023)),
      );
    });

    test('mostOccurrences', () {
      expect(
        ['apple', 'banana', 'apple'].mostOccurrences(),
        equals(('apple', 2)),
      );
      expect(
        [
          DateTime(2022),
          DateTime(2021),
          DateTime(2022),
        ].mostOccurrences(),
        equals((DateTime(2022), 2)),
      );
    });

    test('leastOccurrences', () {
      expect(
        ['apple', 'banana', 'apple', 'cherry'].leastOccurrences(),
        anyOf(
          equals(('banana', 1)),
          equals(('cherry', 1)),
        ),
      );
      expect(
        [
          DateTime(2022),
          DateTime(2021),
          DateTime(2022),
        ].leastOccurrences(),
        equals((DateTime(2021), 1)),
      );
    });
  });
}
