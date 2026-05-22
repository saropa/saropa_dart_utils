// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/url_encode_utils.dart';

void main() {
  group('urlEncodeComponent', () {
    test('encodes spaces and reserved characters', () {
      expect(urlEncodeComponent('a b&c'), 'a%20b%26c');
    });

    test('encodes equals, question mark, and slash', () {
      expect(urlEncodeComponent('a=b?c/d'), 'a%3Db%3Fc%2Fd');
    });

    test('leaves unreserved characters untouched', () {
      expect(urlEncodeComponent('abc-123_~.'), 'abc-123_~.');
    });

    test('empty string encodes to empty', () {
      expect(urlEncodeComponent(''), '');
    });
  });

  group('urlDecodeComponent', () {
    test('decodes a percent-encoded value', () {
      expect(urlDecodeComponent('a%20b%26c'), 'a b&c');
    });

    test('round-trips with urlEncodeComponent', () {
      const String original = 'name=John Doe & Co/2';
      expect(urlDecodeComponent(urlEncodeComponent(original)), original);
    });

    test('throws on a malformed escape', () {
      expect(() => urlDecodeComponent('%'), throwsA(isA<ArgumentError>()));
    });
  });

  group('safeDecodeUri', () {
    test('decodes a valid percent-encoded value', () {
      expect(safeDecodeUri('a%20b'), 'a b');
    });

    test('returns null on a malformed escape rather than throwing', () {
      expect(safeDecodeUri('%'), isNull);
    });

    test('returns null on an incomplete escape sequence', () {
      expect(safeDecodeUri('%2'), isNull);
    });

    test('passes through plain text unchanged', () {
      expect(safeDecodeUri('plain'), 'plain');
    });
  });
}
