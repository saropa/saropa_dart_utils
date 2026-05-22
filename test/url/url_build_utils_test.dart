// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/url_build_utils.dart';

void main() {
  // NOTE on the trailing '#': both buildUri and stripFragment call
  // Uri.replace(fragment: ''). Dart's Uri treats an empty-but-present fragment
  // as "has a fragment", so toString() renders a trailing '#'. The fragment
  // CONTENT is correctly removed (uri.fragment == ''); only the rendered
  // separator remains. Assertions below pin the real toString() output.
  group('buildUri', () {
    test('returns base (with empty-fragment marker) when no path or query', () {
      final Uri uri = buildUri('https://example.com/a');
      expect(uri.toString(), 'https://example.com/a#');
      expect(uri.fragment, '');
    });

    test('resolves a path against the base', () {
      expect(
        buildUri('https://example.com/base/', path: 'sub/page').toString(),
        'https://example.com/base/sub/page#',
      );
    });

    test('appends a query string', () {
      final Uri uri = buildUri('https://example.com/a', query: <String, String>{'q': 'hello'});
      expect(uri.queryParameters, <String, String>{'q': 'hello'});
    });

    test('component-encodes query values with spaces', () {
      final Uri uri = buildUri('https://example.com/a', query: <String, String>{'q': 'a b'});
      expect(uri.query, 'q=a%20b');
      expect(uri.queryParameters['q'], 'a b');
    });

    test('strips fragment content from the base', () {
      final Uri uri = buildUri('https://example.com/a#top');
      expect(uri.fragment, '');
      expect(uri.toString(), 'https://example.com/a#');
    });

    test('accepts an http scheme', () {
      expect(buildUri('http://example.com').toString(), 'http://example.com#');
    });

    test('accepts scheme case-insensitively', () {
      expect(buildUri('HTTPS://example.com/a').toString(), 'https://example.com/a#');
    });

    test('empty query map produces no query string', () {
      expect(buildUri('https://example.com/a', query: <String, String>{}).query, '');
    });

    test('throws FormatException for a base without a scheme', () {
      expect(() => buildUri('example.com/a'), throwsFormatException);
    });

    test('throws FormatException for a non-http(s) scheme (SSRF safety)', () {
      expect(() => buildUri('ftp://example.com/file'), throwsFormatException);
    });

    test('throws FormatException for a file scheme', () {
      expect(() => buildUri('file:///etc/passwd'), throwsFormatException);
    });
  });

  group('stripFragment', () {
    test('removes the fragment content (leaving the empty-fragment marker)', () {
      final Uri uri = stripFragment(Uri.parse('https://x.com/a#top'));
      expect(uri.fragment, '');
      expect(uri.toString(), 'https://x.com/a#');
    });

    test('a fragment-free uri gains the empty-fragment marker', () {
      final Uri uri = stripFragment(Uri.parse('https://x.com/a'));
      expect(uri.fragment, '');
      expect(uri.toString(), 'https://x.com/a#');
    });
  });
}
