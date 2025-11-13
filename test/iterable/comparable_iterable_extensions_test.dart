import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/comparable_iterable_extensions.dart';

void main() {
  group('ComparableIterableExtensions', () {
    test('smallestOccurrence', () {
      expect(<String>['apple', 'banana', 'cherry'].smallestOccurrence(), equals('apple'));
      expect(
        <DateTime>[DateTime(2022), DateTime(2021), DateTime(2023)].smallestOccurrence(),
        equals(DateTime(2021)),
      );
    });

    test('biggestOccurrence', () {
      expect(<String>['apple', 'banana', 'cherry'].biggestOccurrence(), equals('cherry'));
      expect(
        <DateTime>[DateTime(2022), DateTime(2021), DateTime(2023)].biggestOccurrence(),
        equals(DateTime(2023)),
      );
    });
  });
}
