import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/html/html_utils.dart';

void main() {
  group('HtmlUtils', () {
    group('unescape', () {
      test('unescapes basic HTML entities', () {
        expect(HtmlUtils.unescape('&lt;'), equals('<'));
        expect(HtmlUtils.unescape('&gt;'), equals('>'));
        expect(HtmlUtils.unescape('&amp;'), equals('&'));
        expect(HtmlUtils.unescape('&quot;'), equals('"'));
        expect(HtmlUtils.unescape('&#39;'), equals("'"));
        expect(HtmlUtils.unescape('&apos;'), equals("'"));
      });

      test('unescapes nbsp', () {
        expect(HtmlUtils.unescape('Hello&nbsp;World'), equals('Hello World'));
      });

      test('unescapes symbol entities', () {
        expect(HtmlUtils.unescape('&copy;'), equals('\u00A9'));
        expect(HtmlUtils.unescape('&reg;'), equals('\u00AE'));
        expect(HtmlUtils.unescape('&trade;'), equals('\u2122'));
      });

      test('unescapes currency entities', () {
        expect(HtmlUtils.unescape('&euro;'), equals('\u20AC'));
        expect(HtmlUtils.unescape('&pound;'), equals('\u00A3'));
        expect(HtmlUtils.unescape('&yen;'), equals('\u00A5'));
        expect(HtmlUtils.unescape('&cent;'), equals('\u00A2'));
      });

      test('unescapes punctuation entities', () {
        expect(HtmlUtils.unescape('&ndash;'), equals('\u2013'));
        expect(HtmlUtils.unescape('&mdash;'), equals('\u2014'));
        expect(HtmlUtils.unescape('&hellip;'), equals('\u2026'));
        expect(HtmlUtils.unescape('&bull;'), equals('\u2022'));
      });

      test('unescapes quote entities', () {
        expect(HtmlUtils.unescape('&lsquo;'), equals('\u2018'));
        expect(HtmlUtils.unescape('&rsquo;'), equals('\u2019'));
        expect(HtmlUtils.unescape('&ldquo;'), equals('\u201C'));
        expect(HtmlUtils.unescape('&rdquo;'), equals('\u201D'));
      });

      test('unescapes decimal numeric entities', () {
        expect(HtmlUtils.unescape('&#65;'), equals('A'));
        expect(HtmlUtils.unescape('&#97;'), equals('a'));
        expect(HtmlUtils.unescape('&#8364;'), equals('\u20AC')); // Euro sign
      });

      test('unescapes hex numeric entities', () {
        expect(HtmlUtils.unescape('&#x41;'), equals('A'));
        expect(HtmlUtils.unescape('&#x61;'), equals('a'));
        expect(HtmlUtils.unescape('&#x20AC;'), equals('\u20AC')); // Euro sign
      });

      test('handles mixed content', () {
        expect(
          HtmlUtils.unescape('Hello &amp; &lt;World&gt;'),
          equals('Hello & <World>'),
        );
      });

      test('returns null for null input', () {
        expect(HtmlUtils.unescape(null), isNull);
      });

      test('returns null for empty string', () {
        expect(HtmlUtils.unescape(''), isNull);
      });

      test('returns original for no entities', () {
        expect(HtmlUtils.unescape('Hello World'), equals('Hello World'));
      });

      test('handles invalid numeric entities gracefully', () {
        expect(HtmlUtils.unescape('&#999999999999;'), equals('&#999999999999;'));
        expect(HtmlUtils.unescape('&#xZZZ;'), equals('&#xZZZ;'));
      });
    });

    group('removeHtmlTags', () {
      test('removes simple tags', () {
        expect(HtmlUtils.removeHtmlTags('<p>Hello</p>'), equals('Hello'));
        expect(HtmlUtils.removeHtmlTags('<div>World</div>'), equals('World'));
      });

      test('removes nested tags', () {
        expect(
          HtmlUtils.removeHtmlTags('<div><span>Hello</span> <b>World</b></div>'),
          equals('Hello World'),
        );
      });

      test('removes self-closing tags', () {
        expect(HtmlUtils.removeHtmlTags('Hello<br/>World'), equals('Hello World'));
        expect(HtmlUtils.removeHtmlTags('Hello<br />World'), equals('Hello World'));
      });

      test('removes tags with attributes', () {
        expect(
          HtmlUtils.removeHtmlTags('<a href="http://example.com">Link</a>'),
          equals('Link'),
        );
        expect(
          HtmlUtils.removeHtmlTags('<div class="test" id="main">Content</div>'),
          equals('Content'),
        );
      });

      test('collapses multiple whitespace', () {
        expect(
          HtmlUtils.removeHtmlTags('<p>Hello</p>   <p>World</p>'),
          equals('Hello World'),
        );
      });

      test('returns null for null input', () {
        expect(HtmlUtils.removeHtmlTags(null), isNull);
      });

      test('returns null for empty string', () {
        expect(HtmlUtils.removeHtmlTags(''), isNull);
      });

      test('returns null for tags-only content', () {
        expect(HtmlUtils.removeHtmlTags('<p></p>'), isNull);
        expect(HtmlUtils.removeHtmlTags('<div><span></span></div>'), isNull);
      });

      test('returns original for no tags', () {
        expect(HtmlUtils.removeHtmlTags('Hello World'), equals('Hello World'));
      });

      test('removes script tags but keeps inner text (simple regex limitation)', () {
        // Note: A simple regex approach cannot distinguish script/style content.
        // For security-sensitive applications, use a proper HTML parser.
        expect(
          HtmlUtils.removeHtmlTags('<script>alert("x")</script>Text'),
          equals('alert("x") Text'),
        );
      });

      test('removes style tags but keeps inner text (simple regex limitation)', () {
        // Note: A simple regex approach cannot distinguish script/style content.
        // For security-sensitive applications, use a proper HTML parser.
        expect(
          HtmlUtils.removeHtmlTags('<style>.class{color:red}</style>Content'),
          equals('.class{color:red} Content'),
        );
      });

      test('handles multiline HTML', () {
        const String html = '''
<html>
  <body>
    <p>Hello</p>
    <p>World</p>
  </body>
</html>
''';
        expect(HtmlUtils.removeHtmlTags(html), equals('Hello World'));
      });
    });

    group('toPlainText', () {
      test('removes tags and unescapes entities', () {
        expect(
          HtmlUtils.toPlainText('<p>Hello &amp; World</p>'),
          equals('Hello & World'),
        );
      });

      test('handles complex HTML', () {
        expect(
          HtmlUtils.toPlainText('<div>&lt;script&gt; is &quot;dangerous&quot;</div>'),
          equals('<script> is "dangerous"'),
        );
      });

      test('returns null for null input', () {
        expect(HtmlUtils.toPlainText(null), isNull);
      });

      test('returns null for empty string', () {
        expect(HtmlUtils.toPlainText(''), isNull);
      });

      test('returns null for tags-only content', () {
        expect(HtmlUtils.toPlainText('<p></p>'), isNull);
      });
    });
  });
}
