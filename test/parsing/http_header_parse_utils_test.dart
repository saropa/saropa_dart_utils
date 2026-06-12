import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/http_header_parse_utils.dart';

void main() {
  group('parseCacheControl', () {
    test('should map a bare flag directive to a null value', () {
      expect(parseCacheControl('no-cache'), equals(<String, String?>{'no-cache': null}));
    });

    test('should map a key=value directive to its value', () {
      expect(parseCacheControl('max-age=600'), equals(<String, String?>{'max-age': '600'}));
    });

    test('should parse multiple directives, lower-casing keys', () {
      expect(
        parseCacheControl('No-Cache, Max-Age=600, must-revalidate'),
        equals(<String, String?>{
          'no-cache': null,
          'max-age': '600',
          'must-revalidate': null,
        }),
      );
    });

    test('should strip surrounding quotes from a quoted value', () {
      expect(
        parseCacheControl('private="field"'),
        equals(<String, String?>{'private': 'field'}),
      );
    });

    test('should skip empty directives from trailing commas', () {
      expect(parseCacheControl('no-store, '), equals(<String, String?>{'no-store': null}));
    });

    test('should return empty for an empty header', () {
      expect(parseCacheControl(''), isEmpty);
    });
  });

  group('parseMaxAge', () {
    test('should extract the max-age seconds', () {
      expect(parseMaxAge('no-cache, max-age=600'), equals(600));
    });

    test('should return null when max-age is absent', () {
      expect(parseMaxAge('no-cache'), isNull);
    });

    test('should return null for a non-numeric value', () {
      expect(parseMaxAge('max-age=soon'), isNull);
    });

    test('should return null for a negative value', () {
      expect(parseMaxAge('max-age=-5'), isNull);
    });

    test('should accept a zero value', () {
      expect(parseMaxAge('max-age=0'), equals(0));
    });
  });

  group('parseETag', () {
    test('should parse a strong tag', () {
      expect(parseETag('"abc"'), equals((weak: false, value: 'abc')));
    });

    test('should parse a weak tag', () {
      expect(parseETag('W/"abc"'), equals((weak: true, value: 'abc')));
    });

    test('should trim surrounding whitespace', () {
      expect(parseETag('  "xyz" '), equals((weak: false, value: 'xyz')));
    });

    test('should return null for an unquoted tag', () {
      expect(parseETag('abc'), isNull);
    });

    test('should return null for a half-quoted tag', () {
      expect(parseETag('"abc'), isNull);
    });

    test('should return null for an empty header', () {
      expect(parseETag(''), isNull);
    });

    test('should parse an empty quoted tag value', () {
      expect(parseETag('""'), equals((weak: false, value: '')));
    });
  });

  group('parseRetryAfterSeconds', () {
    test('should parse the numeric seconds form', () {
      expect(parseRetryAfterSeconds('120'), equals(const Duration(seconds: 120)));
    });

    test('should accept zero', () {
      expect(parseRetryAfterSeconds('0'), equals(Duration.zero));
    });

    test('should return null for the HTTP-date form', () {
      expect(parseRetryAfterSeconds('Wed, 21 Oct 2015 07:28:00 GMT'), isNull);
    });

    test('should return null for a negative value', () {
      expect(parseRetryAfterSeconds('-10'), isNull);
    });

    test('should return null for an empty header', () {
      expect(parseRetryAfterSeconds(''), isNull);
    });
  });
}
