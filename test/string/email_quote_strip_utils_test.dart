import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/email_quote_strip_utils.dart';

void main() {
  // cspell: disable
  group('stripEmailReplyQuotes', () {
    test('should remove lines starting with >', () {
      const String body = 'My reply\n> quoted line\n> another quote';
      expect(stripEmailReplyQuotes(body), 'My reply');
    });

    test('should remove lines starting with |', () {
      const String body = 'My reply\n| piped quote';
      expect(stripEmailReplyQuotes(body), 'My reply');
    });

    test('should drop the "On ... wrote:" marker line itself', () {
      // The heuristic skips the marker line (and any blank lines that follow)
      // but does not swallow subsequent non-blank body lines, so the original
      // text after the marker is retained.
      const String body = 'Thanks!\nOn Monday, Bob wrote:\nthe original text';
      expect(stripEmailReplyQuotes(body), 'Thanks!\nthe original text');
    });

    test('should drop the Original Message divider line itself', () {
      // Only the divider line is removed; the line after it is kept because the
      // marker only suppresses the marker line plus trailing blanks.
      const String body = 'Reply text\n----- Original Message -----\nold body';
      expect(stripEmailReplyQuotes(body), 'Reply text\nold body');
    });

    test('should drop blank lines that immediately follow a marker', () {
      const String body = 'Hi\nOn Tue, A wrote:\n\n\nmore';
      expect(stripEmailReplyQuotes(body), 'Hi\nmore');
    });

    test('should keep ordinary multiline reply text', () {
      const String body = 'Line one\nLine two';
      expect(stripEmailReplyQuotes(body), 'Line one\nLine two');
    });

    test('should trim surrounding whitespace from result', () {
      const String body = '\n\nHello\n\n';
      expect(stripEmailReplyQuotes(body), 'Hello');
    });

    test('should return empty string for empty body', () {
      expect(stripEmailReplyQuotes(''), '');
    });

    test('should handle leading whitespace before quote marker', () {
      const String body = 'Reply\n   > indented quote';
      expect(stripEmailReplyQuotes(body), 'Reply');
    });
  });
}
