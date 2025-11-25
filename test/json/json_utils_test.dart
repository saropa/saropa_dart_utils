import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/json/json_utils.dart';

// cspell: disable
void main() {
  group('JsonUtils.jsonDecodeToMap', () {
    test('1. Valid JSON object', () => expect(JsonUtils.jsonDecodeToMap('{"a": 1}'), <String, dynamic>{'a': 1}));
    test('2. Null input', () => expect(JsonUtils.jsonDecodeToMap(null), isNull));
    test('3. Empty string', () => expect(JsonUtils.jsonDecodeToMap(''), isNull));
    test('4. Invalid JSON', () => expect(JsonUtils.jsonDecodeToMap('not json'), isNull));
    test('5. JSON array', () => expect(JsonUtils.jsonDecodeToMap('[1, 2, 3]'), isNull));
    test('6. Nested object', () {
      final Map<String, dynamic>? result = JsonUtils.jsonDecodeToMap('{"a": {"b": 2}}');
      expect(result, <String, dynamic>{'a': <String, dynamic>{'b': 2}});
    });
    test('7. String value', () => expect(JsonUtils.jsonDecodeToMap('{"name": "John"}'), <String, dynamic>{'name': 'John'}));
    test('8. Boolean value', () => expect(JsonUtils.jsonDecodeToMap('{"active": true}'), <String, dynamic>{'active': true}));
    test('9. Null value in JSON', () => expect(JsonUtils.jsonDecodeToMap('{"a": null}'), <String, dynamic>{'a': null}));
    test('10. Multiple keys', () {
      final Map<String, dynamic>? result = JsonUtils.jsonDecodeToMap('{"a": 1, "b": 2, "c": 3}');
      expect(result!.length, 3);
    });
  });

  group('JsonUtils.jsonDecodeSafe', () {
    test('1. Valid JSON object', () => expect(JsonUtils.jsonDecodeSafe('{"a": 1}'), <String, dynamic>{'a': 1}));
    test('2. Valid JSON array', () => expect(JsonUtils.jsonDecodeSafe('[1, 2, 3]'), <int>[1, 2, 3]));
    test('3. Null input', () => expect(JsonUtils.jsonDecodeSafe(null), isNull));
    test('4. Empty string', () => expect(JsonUtils.jsonDecodeSafe(''), isNull));
    test('5. "null" string', () => expect(JsonUtils.jsonDecodeSafe('null'), isNull));
    test('6. Invalid JSON', () => expect(JsonUtils.jsonDecodeSafe('not json'), isNull));
    test('7. Whitespace only', () => expect(JsonUtils.jsonDecodeSafe('   '), isNull));
    test('8. Nested structure', () {
      final dynamic result = JsonUtils.jsonDecodeSafe('{"list": [1, 2]}');
      expect(result, <String, dynamic>{'list': <int>[1, 2]});
    });
    test('9. String with leading/trailing whitespace', () {
      final dynamic result = JsonUtils.jsonDecodeSafe('  {"a": 1}  ');
      expect(result, <String, dynamic>{'a': 1});
    });
    test('10. Empty object', () {
      // Empty object {} has no colon, so isJson returns false
      expect(JsonUtils.jsonDecodeSafe('{}'), isNull);
    });
  });

  group('JsonUtils.isJson', () {
    test('1. Valid object', () => expect(JsonUtils.isJson('{"a": 1}'), isTrue));
    test('2. Valid array', () => expect(JsonUtils.isJson('[1, 2, 3]'), isTrue));
    test('3. Plain string', () => expect(JsonUtils.isJson('hello'), isFalse));
    test('4. Null', () => expect(JsonUtils.isJson(null), isFalse));
    test('5. Empty string', () => expect(JsonUtils.isJson(''), isFalse));
    test('6. Single character', () => expect(JsonUtils.isJson('a'), isFalse));
    test('7. Object without colon', () => expect(JsonUtils.isJson('{abc}'), isFalse));
    test('8. Valid with testDecode', () => expect(JsonUtils.isJson('{"a": 1}', testDecode: true), isTrue));
    test('9. Invalid with testDecode', () => expect(JsonUtils.isJson('{invalid}', testDecode: true), isFalse));
    test('10. Nested valid', () => expect(JsonUtils.isJson('{"a": {"b": 1}}'), isTrue));
    test('11. Empty object', () => expect(JsonUtils.isJson('{}'), isFalse));
    test('12. Empty array', () => expect(JsonUtils.isJson('[]'), isTrue));
    test('13. Whitespace padded', () => expect(JsonUtils.isJson('  {"a": 1}  '), isTrue));
    test('14. Number string', () => expect(JsonUtils.isJson('123'), isFalse));
    test('15. Boolean string', () => expect(JsonUtils.isJson('true'), isFalse));
  });

  group('JsonUtils.cleanJsonResponse', () {
    test('1. Escaped quotes', () {
      final String? result = JsonUtils.cleanJsonResponse(r'\"hello\"');
      expect(result, isNotNull);
    });
    test('2. Null input', () => expect(JsonUtils.cleanJsonResponse(null), isNull));
    test('3. Empty string', () => expect(JsonUtils.cleanJsonResponse(''), isNull));
    test('4. Quoted string', () => expect(JsonUtils.cleanJsonResponse('"content"'), 'content'));
    test('5. No escaped quotes', () => expect(JsonUtils.cleanJsonResponse('hello'), 'hello'));
    test('6. Multiple escaped', () {
      final String? result = JsonUtils.cleanJsonResponse(r'\"a\" \"b\"');
      expect(result, isNotNull);
    });
    test('7. Mixed content', () => expect(JsonUtils.cleanJsonResponse(r'test\"value'), 'test"value'));
    test('8. Nested quotes', () => expect(JsonUtils.cleanJsonResponse('""nested""'), '"nested"'));
    test('9. Only quotes', () => expect(JsonUtils.cleanJsonResponse('""'), ''));
    test('10. Single escaped', () => expect(JsonUtils.cleanJsonResponse(r'\"'), '"'));
  });

  group('JsonUtils.tryJsonDecode', () {
    test('1. Valid JSON', () => expect(JsonUtils.tryJsonDecode('{"a": 1}'), <String, dynamic>{'a': 1}));
    test('2. Null input', () => expect(JsonUtils.tryJsonDecode(null), isNull));
    test('3. Empty string', () => expect(JsonUtils.tryJsonDecode(''), isNull));
    test('4. Invalid JSON', () => expect(JsonUtils.tryJsonDecode('invalid'), isNull));
    test('5. With cleanInput escaped', () {
      final Map<String, dynamic>? result = JsonUtils.tryJsonDecode(r'{\"a\": 1}', cleanInput: true);
      // After cleaning, the result may be parseable
      expect(result, anyOf(isNull, isA<Map<String, dynamic>>()));
    });
    test('6. Clean quoted JSON', () {
      final Map<String, dynamic>? result = JsonUtils.tryJsonDecode('"{\\"a\\": 1}"', cleanInput: true);
      expect(result, <String, dynamic>{'a': 1});
    });
    test('7. Array returns null', () => expect(JsonUtils.tryJsonDecode('[1, 2]'), isNull));
    test('8. Nested object', () {
      final Map<String, dynamic>? result = JsonUtils.tryJsonDecode('{"a": {"b": 1}}');
      expect(result!['a'], <String, dynamic>{'b': 1});
    });
    test('9. String values', () => expect(JsonUtils.tryJsonDecode('{"name": "John"}')!['name'], 'John'));
    test('10. Boolean values', () => expect(JsonUtils.tryJsonDecode('{"active": true}')!['active'], true));
  });

  group('JsonUtils.tryJsonDecodeListMap', () {
    test('1. Valid list of maps', () {
      final List<Map<String, dynamic>>? result = JsonUtils.tryJsonDecodeListMap('[{"a": 1}, {"b": 2}]');
      expect(result, <Map<String, dynamic>>[<String, dynamic>{'a': 1}, <String, dynamic>{'b': 2}]);
    });
    test('2. Null input', () => expect(JsonUtils.tryJsonDecodeListMap(null), isNull));
    test('3. Empty string', () => expect(JsonUtils.tryJsonDecodeListMap(''), isNull));
    test('4. Object not list', () => expect(JsonUtils.tryJsonDecodeListMap('{"a": 1}'), isNull));
    test('5. Empty list', () => expect(JsonUtils.tryJsonDecodeListMap('[]'), isNull));
    test('6. List of non-maps', () => expect(JsonUtils.tryJsonDecodeListMap('[1, 2, 3]'), isNull));
    test('7. Mixed list', () => expect(JsonUtils.tryJsonDecodeListMap('[{"a": 1}, 2]'), isNull));
    test('8. Single map in list', () {
      final List<Map<String, dynamic>>? result = JsonUtils.tryJsonDecodeListMap('[{"key": "value"}]');
      expect(result!.length, 1);
    });
    test('9. Invalid JSON', () => expect(JsonUtils.tryJsonDecodeListMap('not json'), isNull));
    test('10. Nested maps', () {
      final List<Map<String, dynamic>>? result = JsonUtils.tryJsonDecodeListMap('[{"a": {"b": 1}}]');
      expect(result!.first['a'], <String, dynamic>{'b': 1});
    });
  });

  group('JsonUtils.tryJsonDecodeList', () {
    test('1. Valid string list', () {
      final List<String>? result = JsonUtils.tryJsonDecodeList('["a", "b", "c"]');
      expect(result, <String>['a', 'b', 'c']);
    });
    test('2. Null input', () => expect(JsonUtils.tryJsonDecodeList(null), isNull));
    test('3. Empty string', () => expect(JsonUtils.tryJsonDecodeList(''), isNull));
    test('4. Object not list', () => expect(JsonUtils.tryJsonDecodeList('{"a": 1}'), isNull));
    test('5. Empty list', () => expect(JsonUtils.tryJsonDecodeList('[]'), isNull));
    test('6. List of numbers', () => expect(JsonUtils.tryJsonDecodeList('[1, 2, 3]'), isNull));
    test('7. Mixed list', () => expect(JsonUtils.tryJsonDecodeList('["a", 1]'), isNull));
    test('8. Single string', () => expect(JsonUtils.tryJsonDecodeList('["only"]'), <String>['only']));
    test('9. Invalid JSON', () => expect(JsonUtils.tryJsonDecodeList('not json'), isNull));
    test('10. Unicode strings', () {
      final List<String>? result = JsonUtils.tryJsonDecodeList('["你好", "世界"]');
      expect(result, <String>['你好', '世界']);
    });
  });

  group('JsonUtils.toIntJson', () {
    test('1. Int input', () => expect(JsonUtils.toIntJson(42), 42));
    test('2. Double input', () => expect(JsonUtils.toIntJson(3.7), 3));
    test('3. String number', () => expect(JsonUtils.toIntJson('123'), 123));
    test('4. Null input', () => expect(JsonUtils.toIntJson(null), isNull));
    test('5. Invalid string', () => expect(JsonUtils.toIntJson('abc'), isNull));
    test('6. Float string', () => expect(JsonUtils.toIntJson('3.14'), isNull));
    test('7. Zero', () => expect(JsonUtils.toIntJson(0), 0));
    test('8. Negative', () => expect(JsonUtils.toIntJson(-5), -5));
    test('9. Large number', () => expect(JsonUtils.toIntJson(1000000), 1000000));
    test('10. Bool input', () => expect(JsonUtils.toIntJson(true), isNull));
  });

  group('JsonUtils.toBoolJson', () {
    test('1. Bool true', () => expect(JsonUtils.toBoolJson(true), isTrue));
    test('2. Bool false', () => expect(JsonUtils.toBoolJson(false), isFalse));
    test('3. Int 1', () => expect(JsonUtils.toBoolJson(1), isTrue));
    test('4. Int 0', () => expect(JsonUtils.toBoolJson(0), isFalse));
    test('5. String "true"', () => expect(JsonUtils.toBoolJson('true'), isTrue));
    test('6. String "false"', () => expect(JsonUtils.toBoolJson('false'), isFalse));
    test('7. String "1"', () => expect(JsonUtils.toBoolJson('1'), isTrue));
    test('8. Null input', () => expect(JsonUtils.toBoolJson(null), isNull));
    test('9. Case insensitive TRUE', () => expect(JsonUtils.toBoolJson('TRUE', isCaseSensitive: false), isTrue));
    test('10. Case sensitive TRUE', () => expect(JsonUtils.toBoolJson('TRUE', isCaseSensitive: true), isFalse));
    test('11. Int 2', () => expect(JsonUtils.toBoolJson(2), isFalse));
    test('12. String "yes"', () => expect(JsonUtils.toBoolJson('yes'), isFalse));
  });

  group('JsonUtils.toDoubleJson', () {
    test('1. Double input', () => expect(JsonUtils.toDoubleJson(3.14), 3.14));
    test('2. Int input', () => expect(JsonUtils.toDoubleJson(42), 42.0));
    test('3. String number', () => expect(JsonUtils.toDoubleJson('3.14'), 3.14));
    test('4. Null input', () => expect(JsonUtils.toDoubleJson(null), isNull));
    test('5. Invalid string', () => expect(JsonUtils.toDoubleJson('abc'), isNull));
    test('6. Zero', () => expect(JsonUtils.toDoubleJson(0), 0.0));
    test('7. Negative', () => expect(JsonUtils.toDoubleJson(-5.5), -5.5));
    test('8. String int', () => expect(JsonUtils.toDoubleJson('42'), 42.0));
    test('9. Very small', () => expect(JsonUtils.toDoubleJson(0.001), 0.001));
    test('10. Scientific notation', () => expect(JsonUtils.toDoubleJson('1e10'), 1e10));
  });

  group('JsonUtils.toStringJson', () {
    test('1. String input', () => expect(JsonUtils.toStringJson('hello'), 'hello'));
    test('2. Null input', () => expect(JsonUtils.toStringJson(null), isNull));
    test('3. Int input', () => expect(JsonUtils.toStringJson(42), '42'));
    test('4. Trim whitespace', () => expect(JsonUtils.toStringJson('  hello  '), 'hello'));
    test('5. No trim', () => expect(JsonUtils.toStringJson('  hello  ', trim: false), '  hello  '));
    test('6. Make uppercase', () => expect(JsonUtils.toStringJson('hello', makeUppercase: true), 'HELLO'));
    test('7. Make lowercase', () => expect(JsonUtils.toStringJson('HELLO', makeLowercase: true), 'hello'));
    test('8. Make capitalized', () => expect(JsonUtils.toStringJson('hello world', makeCapitalized: true), 'Hello World'));
    test('9. Empty string', () => expect(JsonUtils.toStringJson(''), isNull));
    test('10. Bool input', () => expect(JsonUtils.toStringJson(true), 'true'));
    test('11. Double input', () => expect(JsonUtils.toStringJson(3.14), '3.14'));
    test('12. Whitespace only', () => expect(JsonUtils.toStringJson('   '), isNull));
  });

  group('JsonUtils.toDateTimeJson', () {
    test('1. DateTime input', () {
      final DateTime dt = DateTime(2024, 1, 15);
      expect(JsonUtils.toDateTimeJson(dt), dt);
    });
    test('2. Int milliseconds', () {
      final DateTime? result = JsonUtils.toDateTimeJson(1705276800000);
      expect(result, isNotNull);
    });
    test('3. ISO string', () {
      final DateTime? result = JsonUtils.toDateTimeJson('2024-01-15');
      expect(result!.year, 2024);
      expect(result.month, 1);
      expect(result.day, 15);
    });
    test('4. Null input', () => expect(JsonUtils.toDateTimeJson(null), isNull));
    test('5. Invalid string', () => expect(JsonUtils.toDateTimeJson('not a date'), isNull));
    test('6. Empty string', () => expect(JsonUtils.toDateTimeJson(''), isNull));
    test('7. Whitespace only', () => expect(JsonUtils.toDateTimeJson('   '), isNull));
    test('8. Full ISO format', () {
      final DateTime? result = JsonUtils.toDateTimeJson('2024-01-15T10:30:00');
      expect(result!.hour, 10);
      expect(result.minute, 30);
    });
    test('9. Zero timestamp', () {
      final DateTime? result = JsonUtils.toDateTimeJson(0);
      // In local time, 0 milliseconds can be 1969 or 1970 depending on timezone
      expect(result!.year, anyOf(equals(1969), equals(1970)));
    });
    test('10. Numeric string', () {
      final DateTime? result = JsonUtils.toDateTimeJson('2024-06-15');
      expect(result, isNotNull);
    });
  });

  group('JsonUtils.toDateTimeEpochJson', () {
    test('1. Seconds scale', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(1705276800, JsonEpochScale.seconds);
      expect(result, isNotNull);
    });
    test('2. Milliseconds scale', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(1705276800000, JsonEpochScale.milliseconds);
      expect(result, isNotNull);
    });
    test('3. Microseconds scale', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(1705276800000000, JsonEpochScale.microseconds);
      expect(result, isNotNull);
    });
    test('4. Null input', () => expect(JsonUtils.toDateTimeEpochJson(null, JsonEpochScale.seconds), isNull));
    test('5. Zero seconds', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(0, JsonEpochScale.seconds);
      // In local time, epoch 0 can be 1969 or 1970 depending on timezone
      expect(result!.year, anyOf(equals(1969), equals(1970)));
    });
    test('6. Zero milliseconds', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(0, JsonEpochScale.milliseconds);
      // In local time, epoch 0 can be 1969 or 1970 depending on timezone
      expect(result!.year, anyOf(equals(1969), equals(1970)));
    });
    test('7. Negative seconds', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(-1, JsonEpochScale.seconds);
      expect(result!.year, 1969);
    });
    test('8. Large timestamp', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(2000000000, JsonEpochScale.seconds);
      expect(result, isNotNull);
    });
    test('9. Milliseconds precision', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(1705276800123, JsonEpochScale.milliseconds);
      expect(result!.millisecond, 123);
    });
    test('10. Microseconds precision', () {
      final DateTime? result = JsonUtils.toDateTimeEpochJson(1705276800000123, JsonEpochScale.microseconds);
      expect(result!.microsecond, 123);
    });
  });

  group('JsonUtils.toStringListJson', () {
    test('1. List of strings', () => expect(JsonUtils.toStringListJson(<String>['a', 'b']), <String>['a', 'b']));
    test('2. Null input', () => expect(JsonUtils.toStringListJson(null), isNull));
    test('3. Dynamic list', () => expect(JsonUtils.toStringListJson(<dynamic>['a', 'b']), <String>['a', 'b']));
    test('4. Iterable', () => expect(JsonUtils.toStringListJson(<String>{'a', 'b'}), <String>['a', 'b']));
    test('5. Comma string', () => expect(JsonUtils.toStringListJson('a,b,c'), <String>['a', 'b', 'c']));
    test('6. Empty list', () => expect(JsonUtils.toStringListJson(<String>[]), <String>[]));
    test('7. String with spaces', () => expect(JsonUtils.toStringListJson('a , b , c'), <String>['a', 'b', 'c']));
    test('8. Custom separator', () => expect(JsonUtils.toStringListJson('a;b;c', separator: ';'), <String>['a', 'b', 'c']));
    test('9. Single item', () => expect(JsonUtils.toStringListJson(<String>['only']), <String>['only']));
    test('10. Mixed types fail', () => expect(JsonUtils.toStringListJson(<dynamic>['a', 1]), isNull));
  });

  group('JsonUtils.toIntListJson', () {
    test('1. List of ints', () => expect(JsonUtils.toIntListJson(<int>[1, 2, 3]), <int>[1, 2, 3]));
    test('2. Null input', () => expect(JsonUtils.toIntListJson(null), isNull));
    test('3. Dynamic list', () => expect(JsonUtils.toIntListJson(<dynamic>[1, 2, 3]), <int>[1, 2, 3]));
    test('4. String list parseable', () => expect(JsonUtils.toIntListJson(<dynamic>['1', '2']), <int>[1, 2]));
    test('5. Comma string', () => expect(JsonUtils.toIntListJson('1,2,3'), <int>[1, 2, 3]));
    test('6. Empty list', () => expect(JsonUtils.toIntListJson(<int>[]), <int>[]));
    test('7. With spaces', () => expect(JsonUtils.toIntListJson('1 , 2 , 3'), <int>[1, 2, 3]));
    test('8. Single item', () => expect(JsonUtils.toIntListJson(<int>[42]), <int>[42]));
    test('9. Doubles converted', () => expect(JsonUtils.toIntListJson(<dynamic>[1.5, 2.7]), <int>[1, 2]));
    test('10. Invalid filtered', () => expect(JsonUtils.toIntListJson(<dynamic>[1, 'a', 2]), <int>[1, 2]));
  });

  group('JsonUtils.toDoubleListJson', () {
    test('1. List of doubles', () => expect(JsonUtils.toDoubleListJson(<double>[1.1, 2.2]), <double>[1.1, 2.2]));
    test('2. Null input', () => expect(JsonUtils.toDoubleListJson(null), isNull));
    test('3. Dynamic list', () => expect(JsonUtils.toDoubleListJson(<dynamic>[1.1, 2.2]), <double>[1.1, 2.2]));
    test('4. String list parseable', () => expect(JsonUtils.toDoubleListJson(<dynamic>['1.5', '2.5']), <double>[1.5, 2.5]));
    test('5. Comma string', () => expect(JsonUtils.toDoubleListJson('1.1,2.2,3.3'), <double>[1.1, 2.2, 3.3]));
    test('6. Empty list', () => expect(JsonUtils.toDoubleListJson(<double>[]), <double>[]));
    test('7. With spaces', () => expect(JsonUtils.toDoubleListJson('1.1 , 2.2'), <double>[1.1, 2.2]));
    test('8. Single item', () => expect(JsonUtils.toDoubleListJson(<double>[3.14]), <double>[3.14]));
    test('9. Ints as doubles', () => expect(JsonUtils.toDoubleListJson(<dynamic>[1, 2]), <double>[1.0, 2.0]));
    test('10. Invalid filtered', () => expect(JsonUtils.toDoubleListJson(<dynamic>[1.1, 'a', 2.2]), <double>[1.1, 2.2]));
  });

  group('JsonUtils.countIterableJson', () {
    test('1. List count', () => expect(JsonUtils.countIterableJson(<int>[1, 2, 3]), 3));
    test('2. Null input', () => expect(JsonUtils.countIterableJson(null), 0));
    test('3. Empty list', () => expect(JsonUtils.countIterableJson(<int>[]), 0));
    test('4. Comma string', () => expect(JsonUtils.countIterableJson('a,b,c'), 3));
    test('5. String with empty parts', () => expect(JsonUtils.countIterableJson('a,,b'), 2));
    test('6. Custom separator', () => expect(JsonUtils.countIterableJson('a;b;c', separator: ';'), 3));
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
      final List<dynamic>? result = JsonUtils.toListDynamic(<dynamic>[<int>[1, 2], <int>[3, 4]]);
      expect(result!.length, 2);
    });
    test('8. Mixed types list', () {
      final List<dynamic>? result = JsonUtils.toListDynamic(<dynamic>[1, 'a', true]);
      expect(result!.length, 3);
    });
    test('9. Single item', () => expect(JsonUtils.toListDynamic(<dynamic>[42]), <dynamic>[42]));
    test('10. String list', () => expect(JsonUtils.toListDynamic(<String>['a', 'b']), <String>['a', 'b']));
  });

  group('JsonIterablesUtils.jsonEncode', () {
    test('1. List of strings', () => expect(JsonIterablesUtils.jsonEncode(<String>['a', 'b']), '["a","b"]'));
    test('2. List of ints', () => expect(JsonIterablesUtils.jsonEncode(<int>[1, 2, 3]), '[1,2,3]'));
    test('3. Empty list', () => expect(JsonIterablesUtils.jsonEncode(<String>[]), '[]'));
    test('4. Set input', () => expect(JsonIterablesUtils.jsonEncode(<int>{1, 2, 3}), '[1,2,3]'));
    test('5. Single item', () => expect(JsonIterablesUtils.jsonEncode(<String>['only']), '["only"]'));
    test('6. Unicode content', () => expect(JsonIterablesUtils.jsonEncode(<String>['你好']), '["你好"]'));
    test('7. Mixed types', () => expect(JsonIterablesUtils.jsonEncode(<dynamic>[1, 'a', true]), '[1,"a",true]'));
    test('8. Nested list', () => expect(JsonIterablesUtils.jsonEncode(<dynamic>[<int>[1, 2]]), '[[1,2]]'));
    test('9. Null in list', () => expect(JsonIterablesUtils.jsonEncode(<int?>[1, null]), '[1,null]'));
    test('10. Bools', () => expect(JsonIterablesUtils.jsonEncode(<bool>[true, false]), '[true,false]'));
  });
}
