import 'dart:math' show min;

import 'package:meta/meta.dart';

import 'html_entity_data.dart';

/// Character code for `#` — detects numeric entities (`&#`).
const int _poundCode = 0x23;

/// Character codes for `x`/`X` — detects hex entities (`&#x`).
const int _xLowerCode = 0x78;
const int _xUpperCode = 0x58;

/// Maximum valid Unicode scalar value (U+10FFFF).
const int _maxUnicodeCodePoint = 0x10FFFF;

/// Surrogate codepoint range (U+D800–U+DFFF) — not valid scalar values.
const int _surrogateMin = 0xD800;
const int _surrogateMax = 0xDFFF;

/// Max chars in a numeric entity (`&#x10FFFF;` = 10, padded to 12).
const int _maxNumericEntityLength = 12;

// Regex for stripping HTML tags.
final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true);

// Regex for collapsing multiple whitespace characters.
final RegExp _multiSpaceRegex = RegExp(r'\s+');

/// Utility class for HTML text processing.
///
/// Provides single-pass decoding of HTML entities (278 named + all numeric)
/// and tag stripping. Entity data sourced from the html_unescape package's
/// basic set, plus commonly-used entities beyond Latin-1.
///
/// Example:
/// ```dart
/// HtmlUtils.unescape('&lt;Hello&gt;'); // '<Hello>'
/// HtmlUtils.removeHtmlTags('<p>Hello <b>World</b></p>'); // 'Hello World'
/// ```
abstract final class HtmlUtils {
  /// Converts HTML entities to their corresponding characters.
  ///
  /// Uses a single-pass scan with O(1) Map lookup for named entities and
  /// inline decoding for numeric entities (decimal `&#65;` and hex `&#x41;`).
  /// Recognizes legacy entities without trailing semicolons per HTML5 spec.
  ///
  /// Returns `null` if the input is null or empty.
  ///
  /// Example:
  /// ```dart
  /// HtmlUtils.unescape('&lt;div&gt;'); // '<div>'
  /// HtmlUtils.unescape('&#65;'); // 'A'
  /// HtmlUtils.unescape('&#x41;'); // 'A'
  /// HtmlUtils.unescape('Hello&nbsp;World'); // 'Hello\u00A0World'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  static String? unescape(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return null;

    // Fast path: no ampersand means no entities to decode
    if (!htmlText.contains('&')) return htmlText;

    return _scanAndDecode(htmlText);
  }

  /// Single-pass scanner that finds each `&` and resolves the entity.
  /// Audited: 2026-06-12 11:26 EDT
  static String _scanAndDecode(String text) {
    final StringBuffer buffer = StringBuffer();
    int offset = 0;
    final int length = text.length;

    while (offset < length) {
      final int ampIndex = text.indexOf('&', offset);
      if (ampIndex == -1) {
        // ignore: avoid_string_substring -- offset is always ≤ length (while-loop guard above), so substring is in bounds
        buffer.write(text.substring(offset));
        break;
      }
      if (ampIndex > offset) {
        // ignore: avoid_string_substring -- offset < ampIndex (guarded by the ampIndex > offset check), so both indices are in bounds
        buffer.write(text.substring(offset, ampIndex));
      }
      // Decode the entity at ampIndex, advance past it
      offset = _resolveEntity(text, ampIndex, buffer);
    }

    return buffer.toString();
  }

  /// Tries numeric then named entity at [offset]. Writes decoded char
  /// to [buffer] and returns the new offset past the consumed entity.
  /// Audited: 2026-06-12 11:26 EDT
  static int _resolveEntity(
    String text,
    int offset,
    StringBuffer buffer,
  ) {
    final ({String char, int consumed})? numeric = _tryNumericEntity(text, offset);
    if (numeric != null) {
      buffer.write(numeric.char);
      return offset + numeric.consumed;
    }

    final ({String value, int consumed})? named = _tryNamedEntity(text, offset);
    if (named != null) {
      buffer.write(named.value);
      return offset + named.consumed;
    }

    // Not a recognized entity — emit literal ampersand
    buffer.write('&');
    return offset + 1;
  }

  /// Decodes a numeric entity at [offset] (`&#123;` or `&#xff;`).
  ///
  /// Returns decoded character and length consumed, or null if invalid.
  /// Bounds the semicolon search to [_maxNumericEntityLength] characters
  /// to avoid scanning arbitrarily far on malformed input.
  /// Audited: 2026-06-12 11:26 EDT
  static ({String char, int consumed})? _tryNumericEntity(
    String text,
    int offset,
  ) {
    // Minimum numeric entity length is 4 characters (the shortest is the null
    // reference: ampersand, hash, a single digit, then semicolon).
    if (offset + 3 >= text.length) return null;
    if (text.codeUnitAt(offset + 1) != _poundCode) return null;

    // Bound acceptance to prevent matching a far-away semicolon
    final int searchEnd = min(text.length, offset + _maxNumericEntityLength);
    final int semiIndex = text.indexOf(';', offset + 2);
    if (semiIndex == -1 || semiIndex >= searchEnd) return null;

    // Determine hex (&#x...) vs decimal (&#...)
    final int charAfterHash = text.codeUnitAt(offset + 2);
    final bool isHex = charAfterHash == _xLowerCode || charAfterHash == _xUpperCode;
    final int digitStart = offset + (isHex ? 3 : 2);
    if (digitStart >= semiIndex) return null;

    // Parse digits and validate as a Unicode scalar value
    // ignore: avoid_string_substring -- digitStart < semiIndex (guarded above) and semiIndex < length (indexOf result bounded), so both indices are in bounds
    final String digits = text.substring(digitStart, semiIndex);
    final int? codePoint = int.tryParse(digits, radix: isHex ? 16 : 10);
    if (codePoint == null || !_isValidScalarValue(codePoint)) return null;

    final int consumed = semiIndex - offset + 1;
    return (char: String.fromCharCode(codePoint), consumed: consumed);
  }

  /// Returns true if [codePoint] is a valid Unicode scalar value:
  /// in range 1..U+10FFFF and not in the surrogate pair range.
  /// Audited: 2026-06-12 11:26 EDT
  static bool _isValidScalarValue(int codePoint) {
    if (codePoint <= 0 || codePoint > _maxUnicodeCodePoint) return false;
    // Surrogate codepoints (U+D800–U+DFFF) are not valid scalar values
    return codePoint < _surrogateMin || codePoint > _surrogateMax;
  }

  /// Decodes a named entity at [offset] via Map lookup.
  ///
  /// Fast path: semicolon-terminated form resolved in a single Map lookup.
  /// Fallback: legacy entities without semicolons, longest match first.
  /// Audited: 2026-06-12 11:26 EDT
  static ({String value, int consumed})? _tryNamedEntity(
    String text,
    int offset,
  ) {
    // Need at least 3 chars for shortest entity (e.g., &lt)
    if (offset + 2 >= text.length) return null;

    // Fast path: find semicolon and do a single direct Map lookup
    final int searchBound = min(text.length, offset + htmlEntityMaxKeyLength);
    final int semiIndex = text.indexOf(';', offset + 2);
    if (semiIndex > 0 && semiIndex < searchBound) {
      // ignore: avoid_string_substring -- indexOf found ';' so offset < semiIndex+1 ≤ length, making both indices in bounds
      final String candidate = text.substring(offset, semiIndex + 1);
      final String? value = htmlNamedEntities[candidate];
      if (value != null) {
        return (value: value, consumed: candidate.length);
      }
    }

    // Fallback: legacy entities without semicolons (e.g., &amp, &lt)
    return _tryLegacyEntity(text, offset);
  }

  /// Tries legacy (no-semicolon) entity forms, longest match first.
  /// Audited: 2026-06-12 11:26 EDT
  static ({String value, int consumed})? _tryLegacyEntity(
    String text,
    int offset,
  ) {
    final int legacyBound = min(text.length, offset + htmlEntityMaxLegacyLength);
    for (int end = legacyBound; end >= offset + 3; end--) {
      // ignore: avoid_string_substring -- loop invariant offset+3 ≤ end ≤ legacyBound ≤ length keeps both indices in bounds
      final String candidate = text.substring(offset, end);
      final String? value = htmlNamedEntities[candidate];
      if (value != null) {
        return (value: value, consumed: candidate.length);
      }
    }
    return null;
  }

  /// Removes all HTML tags from a string, leaving only the text content.
  ///
  /// Strips tags via regex, collapses whitespace, and trims. Returns `null`
  /// if the input is null, empty, or becomes empty after stripping.
  ///
  /// **Note**: Simple regex-based approach. For malformed markup or
  /// security-sensitive contexts, use a proper HTML parser.
  ///
  /// Example:
  /// ```dart
  /// HtmlUtils.removeHtmlTags('<p>Hello</p>'); // 'Hello'
  /// HtmlUtils.removeHtmlTags('<div>Hello <b>World</b></div>');
  /// // 'Hello World'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  static String? removeHtmlTags(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return null;

    // Strip all HTML tags, then collapse whitespace
    String result = htmlText.replaceAll(_htmlTagRegex, ' ');
    result = result.replaceAll(_multiSpaceRegex, ' ').trim();

    return result.isEmpty ? null : result;
  }

  /// Strips HTML tags and unescapes HTML entities in one operation.
  ///
  /// Returns `null` if the input is null, empty, or tags-only.
  ///
  /// Example:
  /// ```dart
  /// HtmlUtils.toPlainText('<p>Hello &amp; World</p>');
  /// // 'Hello & World'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  static String? toPlainText(String? htmlText) {
    final String? stripped = removeHtmlTags(htmlText);
    return stripped == null ? null : unescape(stripped);
  }
}
