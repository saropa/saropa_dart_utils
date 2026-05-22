import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/safe_html_excerpt_utils.dart';

void main() {
  // cspell: disable
  group('safeHtmlExcerpt', () {
    test('should return input unchanged when shorter than maxLength', () {
      expect(safeHtmlExcerpt('<p>hi</p>', 100), '<p>hi</p>');
    });

    test('should return input unchanged when equal to maxLength', () {
      const String html = '<p>hi</p>';
      expect(safeHtmlExcerpt(html, html.length), html);
    });

    test('should close an open tag left dangling by truncation', () {
      // 18-char input truncated to 10 chars: '<p>Hello w' then closed.
      expect(safeHtmlExcerpt('<p>Hello world</p>', 10), '<p>Hello w</p>');
    });

    test('should close nested tags innermost-first', () {
      // '<p><b>abcd' (10 chars) -> close </b></p>.
      expect(safeHtmlExcerpt('<p><b>abcdefghij</b></p>', 10), '<p><b>abcd</b></p>');
    });

    test('should not emit a closer for void elements like br', () {
      // '<p>a<br>bc' (10 chars): br is void, only </p> appended.
      expect(safeHtmlExcerpt('<p>a<br>bcdefgh</p>', 10), '<p>a<br>bc</p>');
    });

    test('should append nothing extra when no tags are open at the cut', () {
      // First 5 chars 'plain' contain no tags.
      expect(safeHtmlExcerpt('plain text with no early tags here', 5), 'plain');
    });
  });
}
