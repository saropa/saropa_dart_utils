import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/json/json_iterables_utils.dart';
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
      () => expect(JsonUtils.isJson('{}', shouldAllowEmpty: true), isTrue),
    );
    test('9. Empty array returns false without allowEmpty', () {
      expect(JsonUtils.isJson('[]'), isFalse);
      expect(JsonUtils.isJson('[]', shouldAllowEmpty: true), isTrue);
    });
    test('10. Whitespace around object', () => expect(JsonUtils.isJson('  {"a":1}  '), isTrue));
    test('11. Whitespace around empty object', () {
      expect(JsonUtils.isJson('  {}  '), isFalse);
      expect(JsonUtils.isJson('  {}  ', shouldAllowEmpty: true), isTrue);
    });
    test('12. Nested object', () => expect(JsonUtils.isJson('{"a":{"b":1}}'), isTrue));
    test('13. Array of objects', () => expect(JsonUtils.isJson('[{"a":1},{"b":2}]'), isTrue));
    test('14. testDecode with valid JSON', () {
      expect(JsonUtils.isJson('{"a":1}', shouldTestDecode: true), isTrue);
    });
    test('15. testDecode with invalid JSON structure', () {
      expect(JsonUtils.isJson('{a:1}', shouldTestDecode: true), isFalse);
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
