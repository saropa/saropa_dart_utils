import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/make_list_extensions.dart';

void main() {
  group('toListIfNotNull', () {
    // Test 1: A regular number should become a list with that number.
    test('should convert a number to a list', () {
      const int number = 5;
      expect(number.toListIfNotNull(), <int>[5]);
    });

    // Test 2: A regular string should become a list with that string.
    test('should convert a string to a list', () {
      const String text = 'hello';
      expect(text.toListIfNotNull(), <String>['hello']);
    });

    // Test 3: A variable that is null should result in null.
    test('should return null for a null variable', () {
      int? value; // This variable is null
      expect(value.toListIfNotNull(), isNull);
    });

    // Test 4: A boolean `true` should become a list containing `true`.
    test('should convert true to a list', () {
      const bool myBool = true;
      expect(myBool.toListIfNotNull(), <bool>[true]);
    });

    // Test 5: A double should become a list containing that double.
    test('should convert a double to a list', () {
      const double myDouble = 99.9;
      expect(myDouble.toListIfNotNull(), <double>[99.9]);
    });

    // Test 6: An empty string is not null, so it should become a list.
    test('should convert an empty string to a list', () {
      const String text = '';
      expect(text.toListIfNotNull(), <String>['']);
    });

    // Test 7: The number zero is not null, so it should become a list.
    test('should convert the number 0 to a list', () {
      const int number = 0;
      expect(number.toListIfNotNull(), <int>[0]);
    });

    // Test 8: A nullable variable that actually holds a value.
    test('should convert a non-null nullable variable to a list', () {
      const String text = 'world'; // The variable *can* be null, but isn't.
      expect(text.toListIfNotNull(), <String>['world']);
    });

    // Test 9: A list should become a list containing that list.
    test('should wrap an existing list inside a new list', () {
      final List<int> originalList = <int>[1, 2];
      expect(originalList.toListIfNotNull(), <List<int>>[
        <int>[1, 2],
      ]);
    });

    // Test 10: A variable holding a null String value.
    test('should return null for a String variable set to null', () {
      const String? name = null;
      expect(name.toListIfNotNull(), isNull);
    });
  });
}
