/// Radix for hexadecimal number system (base 16) used in hex HTML entities.
const int _hexRadix = 16;

/// Maximum valid Unicode code point (U+10FFFF).
const int _maxUnicodeCodePoint = 0x10FFFF;

/// Common HTML entity mappings for unescaping.
const Map<String, String> _htmlEntities = <String, String>{
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
  '&apos;': "'",
  '&nbsp;': ' ',
  '&copy;': '\u00A9',
  '&reg;': '\u00AE',
  '&trade;': '\u2122',
  '&euro;': '\u20AC',
  '&pound;': '\u00A3',
  '&yen;': '\u00A5',
  '&cent;': '\u00A2',
  '&deg;': '\u00B0',
  '&plusmn;': '\u00B1',
  '&para;': '\u00B6',
  '&sect;': '\u00A7',
  '&bull;': '\u2022',
  '&hellip;': '\u2026',
  '&ndash;': '\u2013',
  '&mdash;': '\u2014',
  '&lsquo;': '\u2018',
  '&rsquo;': '\u2019',
  '&ldquo;': '\u201C',
  '&rdquo;': '\u201D',
  '&laquo;': '\u00AB',
  '&raquo;': '\u00BB',
  '&times;': '\u00D7',
  '&divide;': '\u00F7',
  '&frac12;': '\u00BD',
  '&frac14;': '\u00BC',
  '&frac34;': '\u00BE',
};

// Regex for numeric HTML entities (&#123; or &#x1F;)
final RegExp _numericEntityRegex = RegExp(r'&#(\d+);|&#x([0-9a-fA-F]+);');

// Regex for HTML tags
final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true);

// Regex for multiple whitespace
final RegExp _multipleWhitespaceRegex = RegExp(r'\s+');

/// Utility class for HTML text processing.
///
/// Provides methods to unescape HTML entities and strip HTML tags from strings.
/// Useful for sanitizing HTML content for display as plain text.
///
/// Example usage:
/// ```dart
/// HtmlUtils.unescape('&lt;Hello&gt;'); // '<Hello>'
/// HtmlUtils.removeHtmlTags('<p>Hello <b>World</b></p>'); // 'Hello World'
/// ```
class HtmlUtils {
  const HtmlUtils._(); // Private constructor to prevent instantiation

  /// Converts HTML entities to their corresponding characters.
  ///
  /// Handles both named entities (e.g., `&amp;`, `&lt;`, `&nbsp;`) and
  /// numeric entities (e.g., `&#65;`, `&#x41;`).
  ///
  /// Returns `null` if the input is null or empty.
  ///
  /// Supported named entities include:
  /// - Basic: `&amp;`, `&lt;`, `&gt;`, `&quot;`, `&#39;`, `&apos;`
  /// - Whitespace: `&nbsp;`
  /// - Symbols: `&copy;`, `&reg;`, `&trade;`, `&bull;`, `&hellip;`
  /// - Currency: `&euro;`, `&pound;`, `&yen;`, `&cent;`
  /// - Punctuation: `&ndash;`, `&mdash;`, `&lsquo;`, `&rsquo;`, `&ldquo;`, `&rdquo;`
  /// - Math: `&times;`, `&divide;`, `&plusmn;`, `&frac12;`, `&frac14;`, `&frac34;`
  /// - And more...
  ///
  /// Example:
  /// ```dart
  /// HtmlUtils.unescape('&lt;div&gt;'); // '<div>'
  /// HtmlUtils.unescape('&amp;amp;'); // '&amp;'
  /// HtmlUtils.unescape('&#65;'); // 'A'
  /// HtmlUtils.unescape('&#x41;'); // 'A'
  /// HtmlUtils.unescape('Hello&nbsp;World'); // 'Hello World'
  /// HtmlUtils.unescape('&copy; 2024'); // '© 2024'
  /// ```
  static String? unescape(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) {
      return null;
    }

    String result = htmlText;

    // Replace named entities
    _htmlEntities.forEach((String entity, String char) {
      result = result.replaceAll(entity, char);
    });

    // Replace numeric entities (decimal and hex)
    result = result.replaceAllMapped(_numericEntityRegex, (Match match) {
      final String? decimal = match.group(1);
      final String? hex = match.group(2);

      int? codePoint;
      if (decimal != null) {
        codePoint = int.tryParse(decimal);
      } else if (hex != null) {
        codePoint = int.tryParse(hex, radix: _hexRadix);
      }

      if (codePoint != null && codePoint > 0 && codePoint <= _maxUnicodeCodePoint) {
        return String.fromCharCode(codePoint);
      }
      return match.group(0) ?? ''; // Return original if invalid
    });

    return result;
  }

  /// Removes all HTML tags from a string, leaving only the text content.
  ///
  /// This method strips all HTML tags using a regex pattern. It also:
  /// - Collapses multiple whitespace characters into single spaces
  /// - Trims leading and trailing whitespace
  ///
  /// Returns `null` if:
  /// - The input is null or empty
  /// - The result after stripping tags is empty
  ///
  /// **Note**: This is a simple regex-based implementation suitable for basic
  /// HTML stripping. For complex HTML with nested tags, malformed markup, or
  /// security-sensitive applications, consider using a proper HTML parser.
  ///
  /// Example:
  /// ```dart
  /// HtmlUtils.removeHtmlTags('<p>Hello</p>'); // 'Hello'
  /// HtmlUtils.removeHtmlTags('<div><span>Hello</span> <b>World</b></div>'); // 'Hello World'
  /// HtmlUtils.removeHtmlTags('<script>alert("x")</script>Text'); // 'Text'
  /// HtmlUtils.removeHtmlTags('No tags here'); // 'No tags here'
  /// HtmlUtils.removeHtmlTags('<p></p>'); // null (empty result)
  /// ```
  static String? removeHtmlTags(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) {
      return null;
    }

    // Remove all HTML tags
    String result = htmlText.replaceAll(_htmlTagRegex, ' ');

    // Collapse multiple whitespace into single space and trim
    result = result.replaceAll(_multipleWhitespaceRegex, ' ').trim();

    return result.isEmpty ? null : result;
  }

  /// Strips HTML tags and unescapes HTML entities in one operation.
  ///
  /// Combines [removeHtmlTags] and [unescape] for convenience when you need
  /// to convert HTML content to plain text.
  ///
  /// Returns `null` if:
  /// - The input is null or empty
  /// - The result after processing is empty
  ///
  /// Example:
  /// ```dart
  /// HtmlUtils.toPlainText('<p>Hello &amp; World</p>'); // 'Hello & World'
  /// HtmlUtils.toPlainText('&lt;script&gt;'); // '<script>'
  /// ```
  static String? toPlainText(String? htmlText) {
    final String? stripped = removeHtmlTags(htmlText);
    if (stripped == null) {
      return null;
    }
    return unescape(stripped);
  }
}
