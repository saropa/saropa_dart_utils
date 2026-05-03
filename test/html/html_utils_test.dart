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
        expect(
          HtmlUtils.unescape('Hello&nbsp;World'),
          equals('Hello\u00A0World'),
        );
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
        expect(HtmlUtils.unescape('&#8364;'), equals('\u20AC'));
      });

      test('unescapes hex numeric entities', () {
        expect(HtmlUtils.unescape('&#x41;'), equals('A'));
        expect(HtmlUtils.unescape('&#x61;'), equals('a'));
        expect(HtmlUtils.unescape('&#x20AC;'), equals('\u20AC'));
      });

      test('unescapes hex entities case-insensitively', () {
        expect(HtmlUtils.unescape('&#x3c;'), equals('<'));
        expect(HtmlUtils.unescape('&#x3C;'), equals('<'));
        expect(HtmlUtils.unescape('&#X3c;'), equals('<'));
      });

      test('handles mixed content', () {
        expect(
          HtmlUtils.unescape('Hello &amp; &lt;World&gt;'),
          equals('Hello & <World>'),
        );
      });

      test('handles multiple entities in sequence', () {
        expect(HtmlUtils.unescape('&lt;&amp;&gt;'), equals('<&>'));
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
        expect(
          HtmlUtils.unescape('&#999999999999;'),
          equals('&#999999999999;'),
        );
        expect(HtmlUtils.unescape('&#xZZZ;'), equals('&#xZZZ;'));
      });

      test('preserves surrogate range entities', () {
        expect(HtmlUtils.unescape('&#xD800;'), equals('&#xD800;'));
        expect(HtmlUtils.unescape('&#55296;'), equals('&#55296;'));
      });

      test('preserves decimal without semicolon', () {
        expect(HtmlUtils.unescape('Hello &#345'), equals('Hello &#345'));
      });

      test('preserves hex without semicolon', () {
        expect(
          HtmlUtils.unescape('Hello &#x3cworld'),
          equals('Hello &#x3cworld'),
        );
      });

      // -- Expanded entity coverage (internalized html_unescape) --

      test('unescapes Latin accented characters', () {
        expect(HtmlUtils.unescape('&Agrave;'), equals('\u00C0'));
        expect(HtmlUtils.unescape('&eacute;'), equals('\u00E9'));
        expect(HtmlUtils.unescape('&ntilde;'), equals('\u00F1'));
        expect(HtmlUtils.unescape('&ouml;'), equals('\u00F6'));
        expect(HtmlUtils.unescape('&uuml;'), equals('\u00FC'));
        expect(HtmlUtils.unescape('&ccedil;'), equals('\u00E7'));
      });

      test('unescapes math and symbol entities', () {
        expect(HtmlUtils.unescape('&plusmn;'), equals('\u00B1'));
        expect(HtmlUtils.unescape('&times;'), equals('\u00D7'));
        expect(HtmlUtils.unescape('&divide;'), equals('\u00F7'));
        expect(HtmlUtils.unescape('&frac12;'), equals('\u00BD'));
        expect(HtmlUtils.unescape('&frac14;'), equals('\u00BC'));
        expect(HtmlUtils.unescape('&frac34;'), equals('\u00BE'));
        expect(HtmlUtils.unescape('&micro;'), equals('\u00B5'));
        expect(HtmlUtils.unescape('&deg;'), equals('\u00B0'));
      });

      test('unescapes long entity names', () {
        expect(HtmlUtils.unescape('&DiacriticalGrave;'), equals('`'));
        expect(
          HtmlUtils.unescape('&NonBreakingSpace;'),
          equals('\u00A0'),
        );
        expect(
          HtmlUtils.unescape('&DiacriticalAcute;'),
          equals('\u00B4'),
        );
      });

      test('unescapes case-sensitive entity names', () {
        expect(HtmlUtils.unescape('&AMP;'), equals('&'));
        expect(HtmlUtils.unescape('&amp;'), equals('&'));
        expect(HtmlUtils.unescape('&GT;'), equals('>'));
        expect(HtmlUtils.unescape('&gt;'), equals('>'));
        expect(HtmlUtils.unescape('&COPY;'), equals('\u00A9'));
        expect(HtmlUtils.unescape('&copy;'), equals('\u00A9'));
      });

      test('unescapes legacy entities without semicolons', () {
        expect(HtmlUtils.unescape('&amp test'), equals('& test'));
        expect(HtmlUtils.unescape('&lt test'), equals('< test'));
        expect(HtmlUtils.unescape('&gt test'), equals('> test'));
        expect(
          HtmlUtils.unescape('&divide test'),
          equals('\u00F7 test'),
        );
      });

      test('prefers semicolon form over legacy form', () {
        expect(HtmlUtils.unescape('&lt;'), equals('<'));
        expect(HtmlUtils.unescape('&amp;'), equals('&'));
      });

      test('handles complete &lt; vs incomplete &lt', () {
        expect(
          HtmlUtils.unescape('Look &lt;a&gt;here&lt;/a&gt;'),
          equals('Look <a>here</a>'),
        );
      });

      test('preserves unknown named entities', () {
        expect(
          HtmlUtils.unescape('&nonexistent;'),
          equals('&nonexistent;'),
        );
      });

      test('handles ampersand at end of string', () {
        expect(HtmlUtils.unescape('test&'), equals('test&'));
      });

      test('handles lone ampersand', () {
        expect(HtmlUtils.unescape('&'), equals('&'));
      });

      test('handles consecutive ampersands', () {
        expect(HtmlUtils.unescape('&&'), equals('&&'));
      });

      test('decodes entities in realistic contact name', () {
        expect(
          HtmlUtils.unescape('Ren&eacute;e Fran&ccedil;ois'),
          equals('Ren\u00E9e Fran\u00E7ois'),
        );
      });

      test('unescapes QUOT variants', () {
        expect(HtmlUtils.unescape('&QUOT;'), equals('"'));
        expect(HtmlUtils.unescape('&quot;'), equals('"'));
      });

      test('unescapes structural characters', () {
        expect(HtmlUtils.unescape('&lbrace;'), equals('{'));
        expect(HtmlUtils.unescape('&rbrace;'), equals('}'));
        expect(HtmlUtils.unescape('&lbrack;'), equals('['));
        expect(HtmlUtils.unescape('&rbrack;'), equals(']'));
        expect(HtmlUtils.unescape('&lpar;'), equals('('));
        expect(HtmlUtils.unescape('&rpar;'), equals(')'));
      });
    });

    group('removeHtmlTags', () {
      test('removes simple tags', () {
        expect(HtmlUtils.removeHtmlTags('<p>Hello</p>'), equals('Hello'));
        expect(HtmlUtils.removeHtmlTags('<div>World</div>'), equals('World'));
      });

      test('removes nested tags', () {
        expect(
          HtmlUtils.removeHtmlTags(
            '<div><span>Hello</span> <b>World</b></div>',
          ),
          equals('Hello World'),
        );
      });

      test('removes self-closing tags', () {
        expect(
          HtmlUtils.removeHtmlTags('Hello<br/>World'),
          equals('Hello World'),
        );
        expect(
          HtmlUtils.removeHtmlTags('Hello<br />World'),
          equals('Hello World'),
        );
      });

      test('removes tags with attributes', () {
        expect(
          HtmlUtils.removeHtmlTags('<a href="http://example.com">Link</a>'),
          equals('Link'),
        );
        expect(
          HtmlUtils.removeHtmlTags(
            '<div class="test" id="main">Content</div>',
          ),
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
        expect(
          HtmlUtils.removeHtmlTags('<div><span></span></div>'),
          isNull,
        );
      });

      test('returns original for no tags', () {
        expect(
          HtmlUtils.removeHtmlTags('Hello World'),
          equals('Hello World'),
        );
      });

      test('removes script tags (regex limitation: keeps inner text)', () {
        expect(
          HtmlUtils.removeHtmlTags('<script>alert("x")</script>Text'),
          equals('alert("x") Text'),
        );
      });

      test('removes style tags (regex limitation: keeps inner text)', () {
        expect(
          HtmlUtils.removeHtmlTags(
            '<style>.class{color:red}</style>Content',
          ),
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
          HtmlUtils.toPlainText(
            '<div>&lt;script&gt; is &quot;dangerous&quot;</div>',
          ),
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
