import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/url_canonicalize_utils.dart';

void main() {
  group('canonicalizeUrl', () {
    test('lower-cases scheme/host, drops default port, sorts query', () {
      expect(
        canonicalizeUrl(Uri.parse('HTTP://Example.com:80/a?b=2&a=1')).toString(),
        'http://example.com/a?a=1&b=2',
      );
    });

    test('preserves a non-default port', () {
      expect(
        canonicalizeUrl(Uri.parse('http://h:8080/p')).toString(),
        'http://h:8080/p',
      );
    });

    test('sorts repeated query keys by value', () {
      expect(
        canonicalizeUrl(Uri.parse('http://h/p?x=2&x=1')).toString(),
        'http://h/p?x=1&x=2',
      );
    });

    test('keeps the fragment by default', () {
      expect(
        canonicalizeUrl(Uri.parse('http://h/p#sec')).toString(),
        'http://h/p#sec',
      );
    });

    test('removes the fragment when asked (no dangling hash)', () {
      expect(
        canonicalizeUrl(Uri.parse('http://h/p#sec'), removeFragment: true).toString(),
        'http://h/p',
      );
    });

    test('drops the https default port 443', () {
      expect(
        canonicalizeUrl(Uri.parse('https://h:443/p')).toString(),
        'https://h/p',
      );
    });

    test('a query-less URL stays query-less', () {
      expect(canonicalizeUrl(Uri.parse('http://h/p')).toString(), 'http://h/p');
    });
  });
}
