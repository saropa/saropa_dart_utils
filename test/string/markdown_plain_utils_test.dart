import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/markdown_plain_utils.dart';

void main() {
  // cspell: disable
  group('markdownToPlainText', () {
    test('should strip heading markers', () {
      expect(markdownToPlainText('# Title'), 'Title');
    });

    test('should strip multi-level heading markers', () {
      expect(markdownToPlainText('### Sub heading'), 'Sub heading');
    });

    test('should remove bold and italic markup', () {
      expect(markdownToPlainText('**bold** and *italic*'), 'bold and italic');
    });

    test('should remove underscore emphasis and inline code ticks', () {
      expect(markdownToPlainText('__under__ and `code`'), 'under and code');
    });

    test('should remove strikethrough markup', () {
      expect(markdownToPlainText('~~gone~~'), 'gone');
    });

    test('should keep link text and drop the URL', () {
      expect(markdownToPlainText('See [docs](https://example.com)'), 'See docs');
    });

    test('should convert unordered list items to bullets', () {
      expect(markdownToPlainText('- one\n- two'), '• one\n• two');
    });

    test('should strip ordered list numbering', () {
      expect(markdownToPlainText('1. first\n2. second'), 'first\nsecond');
    });

    test('should collapse 3+ blank lines into a single blank line', () {
      expect(markdownToPlainText('a\n\n\n\nb'), 'a\n\nb');
    });

    test('should return empty string for empty input', () {
      expect(markdownToPlainText(''), '');
    });

    test('drops image syntax without leaving a stray leading bang', () {
      // ![alt](url) is an image; the old code rewrote the link part and left '!'.
      expect(markdownToPlainText('![logo](x.png)'), '');
      expect(markdownToPlainText('see ![logo](x.png) here'), 'see  here');
    });
  });
}
