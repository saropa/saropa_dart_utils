import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/jwt_structure_utils.dart';

void main() {
  // Standard jwt.io HS256 example token.
  // Payload decodes to {"sub":"1234567890","name":"John Doe","iat":1516239022}.
  const String header = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
  const String payload =
      'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ';
  const String sig = 'SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
  const String token = '$header.$payload.$sig';

  group('isJwtStructure', () {
    test('valid three-part token', () => expect(isJwtStructure(token), isTrue));
    test('two parts invalid', () => expect(isJwtStructure('$header.$payload'), isFalse));
    test('four parts invalid', () => expect(isJwtStructure('$token.extra'), isFalse));
    test('empty middle part invalid', () => expect(isJwtStructure('$header..$sig'), isFalse));
    test('empty string invalid', () => expect(isJwtStructure(''), isFalse));
    test('part with disallowed character invalid', () {
      expect(isJwtStructure('aaa.b+b.ccc'), isFalse);
    });
    test('base64url chars (dash, underscore) allowed', () {
      expect(isJwtStructure('a-a.b_b.c-c'), isTrue);
    });
    test('no dots invalid', () => expect(isJwtStructure('justonepart'), isFalse));
  });

  group('jwtPayload', () {
    test('decodes payload to map', () {
      final Map<String, Object?>? p = jwtPayload(token);
      expect(p, isNotNull);
      expect(p!['sub'], '1234567890');
      expect(p['name'], 'John Doe');
      expect(p['iat'], 1516239022);
    });
    test('non-JWT structure returns null', () {
      expect(jwtPayload('not.a.jwt with spaces'), isNull);
    });
    test('two-part token returns null', () {
      expect(jwtPayload('$header.$payload'), isNull);
    });
    test('payload that is not a JSON object returns null', () {
      // base64url of the JSON string "hello" (a string, not an object).
      const String stringPayload = 'ImhlbGxvIg';
      expect(jwtPayload('$header.$stringPayload.$sig'), isNull);
    });
    test('payload that is not valid base64/JSON returns null', () {
      // 'zzzz' decodes to bytes that are not valid JSON.
      expect(jwtPayload('$header.zzzz.$sig'), isNull);
    });
    test('empty string returns null', () => expect(jwtPayload(''), isNull));
  });
}
