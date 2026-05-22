import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/html_sanitizer_utils.dart';

void main() {
  // cspell: disable
  group('stripHtmlTags', () {
    test('should remove tags and keep collapsed text', () {
      expect(stripHtmlTags('<p>Hello <b>world</b></p>'), 'Hello world');
    });

    test('should collapse whitespace introduced by tag removal', () {
      expect(stripHtmlTags('<div>a</div><div>b</div>'), 'a b');
    });

    test('should return empty string for tags-only input', () {
      expect(stripHtmlTags('<br><hr>'), '');
    });

    test('should leave plain text unchanged', () {
      expect(stripHtmlTags('just text'), 'just text');
    });

    test('should return empty string for empty input', () {
      expect(stripHtmlTags(''), '');
    });
  });

  group('sanitizeHtml', () {
    test('should remove script tag and its contents', () {
      expect(
        sanitizeHtml('<p>Safe</p><script>alert(1)</script>'),
        'Safe',
      );
    });

    test('should remove style tag and its contents', () {
      expect(
        sanitizeHtml('<style>.x{color:red}</style><p>Body</p>'),
        'Body',
      );
    });

    test('should be case-insensitive for script tags', () {
      expect(sanitizeHtml('<SCRIPT>bad()</SCRIPT>text'), 'text');
    });

    test('should strip remaining benign tags after removing scripts', () {
      expect(
        sanitizeHtml('<div><span>keep</span><script>evil()</script></div>'),
        'keep',
      );
    });

    test('should return empty string for empty input', () {
      expect(sanitizeHtml(''), '');
    });
  });
}
