import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/json/json_utils.dart';

void main() {
  group('JsonUtils.isJson', () {
    test('1. Valid JSON object', () => expect(JsonUtils.isJson('{"a":1}'), isTrue));
    test('2. Valid JSON array', () => expect(JsonUtils.isJson('[1,2,3]'), isTrue));
    test('3. Null input', () => expect(JsonUtils.isJson(null), isFalse));
    test('4. Empty string', () => expect(JsonUtils.isJson(''), isFalse));
    test('5. Single char', () => expect(JsonUtils.isJson('a'), isFalse));
    test('6. Plain text', () => expect(JsonUtils.isJson('not json'), isFalse));
    test('7. Empty object without allowEmpty', () => expect(JsonUtils.isJson('{}'), isFalse));
    test(
      '8. Empty object with allowEmpty=true',
      () => expect(JsonUtils.isJson('{}', allowEmpty: true), isTrue),
    );
    test('9. Empty array (valid - no colon check for arrays)', () {
      expect(JsonUtils.isJson('[]'), isTrue);
    });
    test('10. Whitespace around object', () => expect(JsonUtils.isJson('  {"a":1}  '), isTrue));
    test('11. Whitespace around empty object', () {
      expect(JsonUtils.isJson('  {}  '), isFalse);
      expect(JsonUtils.isJson('  {}  ', allowEmpty: true), isTrue);
    });
    test('12. Nested object', () => expect(JsonUtils.isJson('{"a":{"b":1}}'), isTrue));
    test('13. Array of objects', () => expect(JsonUtils.isJson('[{"a":1},{"b":2}]'), isTrue));
    test('14. testDecode with valid JSON', () {
      expect(JsonUtils.isJson('{"a":1}', testDecode: true), isTrue);
    });
    test('15. testDecode with invalid JSON structure', () {
      expect(JsonUtils.isJson('{a:1}', testDecode: true), isFalse);
    });
    test('16. Object missing colon', () => expect(JsonUtils.isJson('{abc}'), isFalse));
  });

  group('JsonUtils.jsonDecodeSafe/jsonDecodeToMap', () {
    test('decode valid object', () {
      final dynamic d = JsonUtils.jsonDecodeSafe('{"a":1,"b":"x"}');
      expect(d, isA<Map<String, dynamic>>());
      final Map<String, dynamic>? m = JsonUtils.jsonDecodeToMap('{"a":1,"b":"x"}');
      expect(m, isNotNull);
      expect(m?['a'], 1);
      expect(m?['b'], 'x');
    });
    test('decode invalid returns null', () {
      expect(JsonUtils.jsonDecodeSafe('not json'), isNull);
    });
    test(
      '4. Null input',
      () => expect(JsonUtils.toDateTimeEpochJson(null, JsonEpochScale.seconds), isNull),
    );
    test('5. Zero seconds', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(0, JsonEpochScale.seconds);
      expect(result, isNotNull);
      // In local time, epoch 0 can be 1969 or 1970 depending on timezone
      expect(result?.year, anyOf(equals(1969), equals(1970)));
    });
    test('6. Zero milliseconds', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(0, JsonEpochScale.milliseconds);
      expect(result, isNotNull);
      // In local time, epoch 0 can be 1969 or 1970 depending on timezone
      expect(result?.year, anyOf(equals(1969), equals(1970)));
    });
    test('7. Negative seconds', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(-1, JsonEpochScale.seconds);
      expect(result, isNotNull);
      expect(result?.year, 1969);
    });
    test('8. Large timestamp', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(2000000000, JsonEpochScale.seconds);
      expect(result, isNotNull);
    });
    test('9. Milliseconds precision', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(
        1705276800123,
        JsonEpochScale.milliseconds,
      );
      expect(result, isNotNull);
      expect(result?.millisecond, 123);
    });
    test('10. Microseconds precision', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(
        1705276800000123,
        JsonEpochScale.microseconds,
      );
      expect(result, isNotNull);
      expect(result?.microsecond, 123);
    });
  });

  group('JsonUtils.toStringListJson', () {
    test(
      '1. List of strings',
      () => expect(JsonUtils.toStringListJson(<String>['a', 'b']), <String>['a', 'b']),
    );
    test('2. Null input', () => expect(JsonUtils.toStringListJson(null), isNull));
    test(
      '3. Dynamic list',
      () => expect(JsonUtils.toStringListJson(<dynamic>['a', 'b']), <String>['a', 'b']),
    );
    test(
      '4. Iterable',
      () => expect(JsonUtils.toStringListJson(<String>{'a', 'b'}), <String>['a', 'b']),
    );
    test(
      '5. Comma string',
      () => expect(JsonUtils.toStringListJson('a,b,c'), <String>['a', 'b', 'c']),
    );
    test('6. Empty list', () => expect(JsonUtils.toStringListJson(<String>[]), <String>[]));
    test(
      '7. String with spaces',
      () => expect(JsonUtils.toStringListJson('a , b , c'), <String>['a', 'b', 'c']),
    );
    test(
      '8. Custom separator',
      () => expect(JsonUtils.toStringListJson('a;b;c', separator: ';'), <String>['a', 'b', 'c']),
    );
    test(
      '9. Single item',
      () => expect(JsonUtils.toStringListJson(<String>['only']), <String>['only']),
    );
    test(
      '10. Mixed types fail',
      () => expect(JsonUtils.toStringListJson(<dynamic>['a', 1]), isNull),
    );
  });

  group('JsonUtils.toIntListJson', () {
    test('1. List of ints', () => expect(JsonUtils.toIntListJson(<int>[1, 2, 3]), <int>[1, 2, 3]));
    test('2. Null input', () => expect(JsonUtils.toIntListJson(null), isNull));
    test(
      '3. Dynamic list',
      () => expect(JsonUtils.toIntListJson(<dynamic>[1, 2, 3]), <int>[1, 2, 3]),
    );
    test(
      '4. String list parseable',
      () => expect(JsonUtils.toIntListJson(<dynamic>['1', '2']), <int>[1, 2]),
    );
    test('5. Comma string', () => expect(JsonUtils.toIntListJson('1,2,3'), <int>[1, 2, 3]));
    test('6. Empty list', () => expect(JsonUtils.toIntListJson(<int>[]), <int>[]));
    test('7. With spaces', () => expect(JsonUtils.toIntListJson('1 , 2 , 3'), <int>[1, 2, 3]));
    test('8. Single item', () => expect(JsonUtils.toIntListJson(<int>[42]), <int>[42]));
    test(
      '9. Doubles converted',
      () => expect(JsonUtils.toIntListJson(<dynamic>[1.5, 2.7]), <int>[1, 2]),
    );
    test(
      '10. Invalid filtered',
      () => expect(JsonUtils.toIntListJson(<dynamic>[1, 'a', 2]), <int>[1, 2]),
    );
  });

  group('JsonUtils.toDoubleListJson', () {
    test(
      '1. List of doubles',
      () => expect(JsonUtils.toDoubleListJson(<double>[1.1, 2.2]), <double>[1.1, 2.2]),
    );
    test('2. Null input', () => expect(JsonUtils.toDoubleListJson(null), isNull));
    test(
      '3. Dynamic list',
      () => expect(JsonUtils.toDoubleListJson(<dynamic>[1.1, 2.2]), <double>[1.1, 2.2]),
    );
    test(
      '4. String list parseable',
      () => expect(JsonUtils.toDoubleListJson(<dynamic>['1.5', '2.5']), <double>[1.5, 2.5]),
    );
    test(
      '5. Comma string',
      () => expect(JsonUtils.toDoubleListJson('1.1,2.2,3.3'), <double>[1.1, 2.2, 3.3]),
    );
    test('6. Empty list', () => expect(JsonUtils.toDoubleListJson(<double>[]), <double>[]));
    test(
      '7. With spaces',
      () => expect(JsonUtils.toDoubleListJson('1.1 , 2.2'), <double>[1.1, 2.2]),
    );
    test(
      '8. Single item',
      () => expect(JsonUtils.toDoubleListJson(<double>[3.14]), <double>[3.14]),
    );
    test(
      '9. Ints as doubles',
      () => expect(JsonUtils.toDoubleListJson(<dynamic>[1, 2]), <double>[1.0, 2.0]),
    );
    test(
      '10. Invalid filtered',
      () => expect(JsonUtils.toDoubleListJson(<dynamic>[1.1, 'a', 2.2]), <double>[1.1, 2.2]),
    );
  });

  group('JsonUtils.countIterableJson', () {
    test('1. List count', () => expect(JsonUtils.countIterableJson(<int>[1, 2, 3]), 3));
    test('2. Null input', () => expect(JsonUtils.countIterableJson(null), 0));
    test('3. Empty list', () => expect(JsonUtils.countIterableJson(<int>[]), 0));
    test('4. Comma string', () => expect(JsonUtils.countIterableJson('a,b,c'), 3));
    test('5. String with empty parts', () => expect(JsonUtils.countIterableJson('a,,b'), 2));
    test(
      '6. Custom separator',
      () => expect(JsonUtils.countIterableJson('a;b;c', separator: ';'), 3),
    );
    test('7. Set iterable', () => expect(JsonUtils.countIterableJson(<int>{1, 2, 3}), 3));
    test('8. Single item string', () => expect(JsonUtils.countIterableJson('single'), 1));
    test('9. Only separator', () => expect(JsonUtils.countIterableJson(',,,'), 0));
    test('10. Non-iterable non-string', () => expect(JsonUtils.countIterableJson(42), 0));
  });

  group('JsonUtils.toListDynamic', () {
    test('1. List input', () => expect(JsonUtils.toListDynamic(<int>[1, 2, 3]), <int>[1, 2, 3]));
    test('2. Null input', () => expect(JsonUtils.toListDynamic(null), isNull));
    test('3. Non-list input', () => expect(JsonUtils.toListDynamic('string'), isNull));
    test('4. Empty list', () => expect(JsonUtils.toListDynamic(<dynamic>[]), <dynamic>[]));
    test('5. Map input', () => expect(JsonUtils.toListDynamic(<String, int>{'a': 1}), isNull));
    test('6. Int input', () => expect(JsonUtils.toListDynamic(42), isNull));
    test('7. Nested lists', () {
      final List<dynamic>? result = JsonUtils.toListDynamic(<dynamic>[
        <int>[1, 2],
        <int>[3, 4],
      ]);
      expect(result, isNotNull);
      expect(result, hasLength(2));
    });
    test('8. Mixed types list', () {
      final List<dynamic>? result = JsonUtils.toListDynamic(<dynamic>[1, 'a', true]);
      expect(result, isNotNull);
      expect(result, hasLength(3));
    });
    test('9. Single item', () => expect(JsonUtils.toListDynamic(<dynamic>[42]), <dynamic>[42]));
    test(
      '10. String list',
      () => expect(JsonUtils.toListDynamic(<String>['a', 'b']), <String>['a', 'b']),
    );
  });

  group('JsonIterablesUtils.jsonEncode', () {
    test(
      '1. List of strings',
      () => expect(JsonIterablesUtils.jsonEncode(<String>['a', 'b']), '["a","b"]'),
    );
    test('2. List of ints', () => expect(JsonIterablesUtils.jsonEncode(<int>[1, 2, 3]), '[1,2,3]'));
    test('3. Empty list', () => expect(JsonIterablesUtils.jsonEncode(<String>[]), '[]'));
    test('4. Set input', () => expect(JsonIterablesUtils.jsonEncode(<int>{1, 2, 3}), '[1,2,3]'));
    test(
      '5. Single item',
      () => expect(JsonIterablesUtils.jsonEncode(<String>['only']), '["only"]'),
    );
    test(
      '6. Unicode content',
      () => expect(JsonIterablesUtils.jsonEncode(<String>['你好']), '["你好"]'),
    );
    test(
      '7. Mixed types',
      () => expect(JsonIterablesUtils.jsonEncode(<dynamic>[1, 'a', true]), '[1,"a",true]'),
    );
    test(
      '8. Nested list',
      () => expect(
        JsonIterablesUtils.jsonEncode(<dynamic>[
          <int>[1, 2],
        ]),
        '[[1,2]]',
      ),
    );
    test(
      '9. Null in list',
      () => expect(JsonIterablesUtils.jsonEncode(<int?>[1, null]), '[1,null]'),
    );
    test(
      '10. Bools',
      () => expect(JsonIterablesUtils.jsonEncode(<bool>[true, false]), '[true,false]'),
    );
  });
}
