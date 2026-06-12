import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/url_extract_utils.dart';

void main() {
  // cspell: disable
  group('UrlExtractUtils', () {
    test('should expose url, label, and snippet', () {
      const UrlExtractUtils link = UrlExtractUtils(
        'https://x.com',
        label: 'X',
        snippet: 'visit https://x.com today',
      );
      expect(link.url, 'https://x.com');
      expect(link.label, 'X');
      expect(link.snippet, 'visit https://x.com today');
    });

    test('should default label and snippet to null', () {
      const UrlExtractUtils link = UrlExtractUtils('https://x.com');
      expect(link.label, isNull);
      expect(link.snippet, isNull);
    });

    test('toString should render fields', () {
      expect(
        const UrlExtractUtils('https://x.com', label: 'X', snippet: 'ctx').toString(),
        'UrlExtractUtils(url: https://x.com, label: X, snippet: ctx)',
      );
    });
  });

  group('extractUrlsWithContext', () {
    test('should extract a single http(s) URL', () {
      final List<UrlExtractUtils> links = extractUrlsWithContext('see https://x.com end');
      expect(links, hasLength(1));
      expect(links.single.url, 'https://x.com');
    });

    test('should extract multiple URLs in order', () {
      final List<UrlExtractUtils> links = extractUrlsWithContext(
        'a http://one.com b https://two.com c',
      );
      expect(
        links.map((UrlExtractUtils l) => l.url).toList(),
        <String>['http://one.com', 'https://two.com'],
      );
    });

    test('should include surrounding context in the snippet', () {
      final List<UrlExtractUtils> links = extractUrlsWithContext('please visit https://x.com soon');
      expect(links.single.snippet, contains('https://x.com'));
      expect(links.single.snippet, contains('visit'));
    });

    test('should return empty list when no URL is present', () {
      expect(extractUrlsWithContext('no links here'), isEmpty);
    });

    test('should return empty list for empty input', () {
      expect(extractUrlsWithContext(''), isEmpty);
    });

    test('should stop the URL at whitespace', () {
      final List<UrlExtractUtils> links = extractUrlsWithContext('https://x.com/path more text');
      expect(links.single.url, 'https://x.com/path');
    });

    test('should match URLs case-insensitively on the scheme', () {
      final List<UrlExtractUtils> links = extractUrlsWithContext('go HTTPS://x.com now');
      expect(links.single.url, 'HTTPS://x.com');
    });

    test('trims trailing sentence punctuation the greedy match swallowed', () {
      expect(extractUrlsWithContext('visit https://a.com.').single.url, 'https://a.com');
      expect(extractUrlsWithContext('see https://a.com, then').single.url, 'https://a.com');
    });
  });
}
