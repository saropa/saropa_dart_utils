import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/json/json_epoch_scale.dart';
import 'package:saropa_dart_utils/json/json_type_utils.dart';

void main() {
  group('JsonTypeUtils.toDateTimeEpochJson', () {
    test(
      '4. Null input',
      () => expect(JsonTypeUtils.toDateTimeEpochJson(null, JsonEpochScale.seconds), isNull),
    );
    test('5. Zero seconds', () {
      final DateTime? result = JsonTypeUtils.toDateTimeEpochJson(0, JsonEpochScale.seconds);
      expect(result, isNotNull);
      // In local time, epoch 0 can be 1969 or 1970 depending on timezone
      expect(result?.year, anyOf(equals(1969), equals(1970)));
    });
    test('6. Zero milliseconds', () {
      final DateTime? result = JsonTypeUtils.toDateTimeEpochJson(0, JsonEpochScale.milliseconds);
      expect(result, isNotNull);
      // In local time, epoch 0 can be 1969 or 1970 depending on timezone
      expect(result?.year, anyOf(equals(1969), equals(1970)));
    });
    test('7. Negative seconds', () {
      final DateTime? result = JsonTypeUtils.toDateTimeEpochJson(-1, JsonEpochScale.seconds);
      expect(result, isNotNull);
      expect(result?.year, 1969);
    });
    test('8. Large timestamp', () {
      final DateTime? result = JsonTypeUtils.toDateTimeEpochJson(2000000000, JsonEpochScale.seconds);
      expect(result, isNotNull);
    });
    test('9. Milliseconds precision', () {
      final DateTime? result = JsonTypeUtils.toDateTimeEpochJson(
        1705276800123,
        JsonEpochScale.milliseconds,
      );
      expect(result, isNotNull);
      expect(result?.millisecond, 123);
    });
    test('10. Microseconds precision', () {
      final DateTime? result = JsonTypeUtils.toDateTimeEpochJson(
        1705276800000123,
        JsonEpochScale.microseconds,
      );
      expect(result, isNotNull);
      expect(result?.microsecond, 123);
    });
  });

  group('JsonTypeUtils.toStringListJson', () {
    test(
      '1. List of strings',
      () => expect(JsonTypeUtils.toStringListJson(<String>['a', 'b']), <String>['a', 'b']),
    );
    test('2. Null input', () => expect(JsonTypeUtils.toStringListJson(null), isNull));
    test(
      '3. Dynamic list',
      () => expect(JsonTypeUtils.toStringListJson(<dynamic>['a', 'b']), <String>['a', 'b']),
    );
    test(
      '4. Iterable',
      () => expect(JsonTypeUtils.toStringListJson(<String>{'a', 'b'}), <String>['a', 'b']),
    );
    test(
      '5. Comma string',
      () => expect(JsonTypeUtils.toStringListJson('a,b,c'), <String>['a', 'b', 'c']),
    );
    test('6. Empty list', () => expect(JsonTypeUtils.toStringListJson(<String>[]), <String>[]));
    test(
      '7. String with spaces',
      () => expect(JsonTypeUtils.toStringListJson('a , b , c'), <String>['a', 'b', 'c']),
    );
    test(
      '8. Custom separator',
      () => expect(JsonTypeUtils.toStringListJson('a;b;c', separator: ';'), <String>['a', 'b', 'c']),
    );
    test(
      '9. Single item',
      () => expect(JsonTypeUtils.toStringListJson(<String>['only']), <String>['only']),
    );
    test(
      '10. Mixed types fail',
      () => expect(JsonTypeUtils.toStringListJson(<dynamic>['a', 1]), isNull),
    );
  });

  group('JsonTypeUtils.toIntListJson', () {
    test('1. List of ints', () => expect(JsonTypeUtils.toIntListJson(<int>[1, 2, 3]), <int>[1, 2, 3]));
    test('2. Null input', () => expect(JsonTypeUtils.toIntListJson(null), isNull));
    test(
      '3. Dynamic list',
      () => expect(JsonTypeUtils.toIntListJson(<dynamic>[1, 2, 3]), <int>[1, 2, 3]),
    );
    test(
      '4. String list parseable',
      () => expect(JsonTypeUtils.toIntListJson(<dynamic>['1', '2']), <int>[1, 2]),
    );
    test('5. Comma string', () => expect(JsonTypeUtils.toIntListJson('1,2,3'), <int>[1, 2, 3]));
    test('6. Empty list', () => expect(JsonTypeUtils.toIntListJson(<int>[]), <int>[]));
    test('7. With spaces', () => expect(JsonTypeUtils.toIntListJson('1 , 2 , 3'), <int>[1, 2, 3]));
    test('8. Single item', () => expect(JsonTypeUtils.toIntListJson(<int>[42]), <int>[42]));
    test(
      '9. Doubles converted',
      () => expect(JsonTypeUtils.toIntListJson(<dynamic>[1.5, 2.7]), <int>[1, 2]),
    );
    test(
      '10. Invalid filtered',
      () => expect(JsonTypeUtils.toIntListJson(<dynamic>[1, 'a', 2]), <int>[1, 2]),
    );
  });

  group('JsonTypeUtils.toDoubleListJson', () {
    test(
      '1. List of doubles',
      () => expect(JsonTypeUtils.toDoubleListJson(<double>[1.1, 2.2]), <double>[1.1, 2.2]),
    );
    test('2. Null input', () => expect(JsonTypeUtils.toDoubleListJson(null), isNull));
    test(
      '3. Dynamic list',
      () => expect(JsonTypeUtils.toDoubleListJson(<dynamic>[1.1, 2.2]), <double>[1.1, 2.2]),
    );
    test(
      '4. String list parseable',
      () => expect(JsonTypeUtils.toDoubleListJson(<dynamic>['1.5', '2.5']), <double>[1.5, 2.5]),
    );
    test(
      '5. Comma string',
      () => expect(JsonTypeUtils.toDoubleListJson('1.1,2.2,3.3'), <double>[1.1, 2.2, 3.3]),
    );
    test('6. Empty list', () => expect(JsonTypeUtils.toDoubleListJson(<double>[]), <double>[]));
    test(
      '7. With spaces',
      () => expect(JsonTypeUtils.toDoubleListJson('1.1 , 2.2'), <double>[1.1, 2.2]),
    );
    test(
      '8. Single item',
      () => expect(JsonTypeUtils.toDoubleListJson(<double>[3.14]), <double>[3.14]),
    );
    test(
      '9. Ints as doubles',
      () => expect(JsonTypeUtils.toDoubleListJson(<dynamic>[1, 2]), <double>[1.0, 2.0]),
    );
    test(
      '10. Invalid filtered',
      () => expect(JsonTypeUtils.toDoubleListJson(<dynamic>[1.1, 'a', 2.2]), <double>[1.1, 2.2]),
    );
  });

  group('JsonTypeUtils.countIterableJson', () {
    test('1. List count', () => expect(JsonTypeUtils.countIterableJson(<int>[1, 2, 3]), 3));
    test('2. Null input', () => expect(JsonTypeUtils.countIterableJson(null), 0));
    test('3. Empty list', () => expect(JsonTypeUtils.countIterableJson(<int>[]), 0));
    test('4. Comma string', () => expect(JsonTypeUtils.countIterableJson('a,b,c'), 3));
    test('5. String with empty parts', () => expect(JsonTypeUtils.countIterableJson('a,,b'), 2));
    test(
      '6. Custom separator',
      () => expect(JsonTypeUtils.countIterableJson('a;b;c', separator: ';'), 3),
    );
    test('7. Set iterable', () => expect(JsonTypeUtils.countIterableJson(<int>{1, 2, 3}), 3));
    test('8. Single item string', () => expect(JsonTypeUtils.countIterableJson('single'), 1));
    test('9. Only separator', () => expect(JsonTypeUtils.countIterableJson(',,,'), 0));
    test('10. Non-iterable non-string', () => expect(JsonTypeUtils.countIterableJson(42), 0));
  });

  group('JsonTypeUtils.toListDynamic', () {
    test('1. List input', () => expect(JsonTypeUtils.toListDynamic(<int>[1, 2, 3]), <int>[1, 2, 3]));
    test('2. Null input', () => expect(JsonTypeUtils.toListDynamic(null), isNull));
    test('3. Non-list input', () => expect(JsonTypeUtils.toListDynamic('string'), isNull));
    test('4. Empty list', () => expect(JsonTypeUtils.toListDynamic(<dynamic>[]), <dynamic>[]));
    test('5. Map input', () => expect(JsonTypeUtils.toListDynamic(<String, int>{'a': 1}), isNull));
    test('6. Int input', () => expect(JsonTypeUtils.toListDynamic(42), isNull));
    test('7. Nested lists', () {
      final List<dynamic>? result = JsonTypeUtils.toListDynamic(<dynamic>[
        <int>[1, 2],
        <int>[3, 4],
      ]);
      expect(result, isNotNull);
      expect(result, hasLength(2));
    });
    test('8. Mixed types list', () {
      final List<dynamic>? result = JsonTypeUtils.toListDynamic(<dynamic>[1, 'a', true]);
      expect(result, isNotNull);
      expect(result, hasLength(3));
    });
    test('9. Single item', () => expect(JsonTypeUtils.toListDynamic(<dynamic>[42]), <dynamic>[42]));
    test(
      '10. String list',
      () => expect(JsonTypeUtils.toListDynamic(<String>['a', 'b']), <String>['a', 'b']),
    );
  });
}
