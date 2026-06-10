import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/json/json_utils.dart';

void main() {
  group('cleanJsonResponse', () {
    test('strips outer double-quotes', () {
      expect(JsonUtils.cleanJsonResponse('"hello"'), 'hello');
    });

    test('unescapes inner escaped quotes', () {
      expect(JsonUtils.cleanJsonResponse(r'"a \"b\""'), 'a "b"');
    });

    test('null for null or empty', () {
      expect(JsonUtils.cleanJsonResponse(null), isNull);
      expect(JsonUtils.cleanJsonResponse('   '), isNull);
    });
  });

  group('tryJsonDecodeList', () {
    test('decodes a JSON array of strings', () {
      expect(JsonUtils.tryJsonDecodeList('["a","b"]'), <String>['a', 'b']);
    });

    test('null when elements are not all strings', () {
      expect(JsonUtils.tryJsonDecodeList('[1,2]'), isNull);
    });

    test('null for invalid JSON', () {
      expect(JsonUtils.tryJsonDecodeList('not json'), isNull);
      expect(JsonUtils.tryJsonDecodeList(null), isNull);
    });
  });

  group('tryJsonDecodeListMap', () {
    test('decodes a JSON array of objects', () {
      final List<Map<String, dynamic>>? result = JsonUtils.tryJsonDecodeListMap(
        '[{"a":1},{"b":2}]',
      );
      expect(result, hasLength(2));
      expect(result!.first['a'], 1);
    });

    test('null for a non-object array', () {
      expect(JsonUtils.tryJsonDecodeListMap('[1,2]'), isNull);
    });

    test('null for invalid JSON', () {
      expect(JsonUtils.tryJsonDecodeListMap('nope'), isNull);
      expect(JsonUtils.tryJsonDecodeListMap(null), isNull);
    });
  });
}
