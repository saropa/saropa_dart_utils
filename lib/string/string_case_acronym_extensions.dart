import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Case conversion that preserves acronyms (e.g. HTTP → http in camelCase).
extension StringCaseAcronymExtensions on String {
  /// Converts to camelCase, lowercasing acronyms (e.g. HTTPResponse → httpResponse).
  ///
  /// Splits on non-alpha, then capitalizes each word except the first (lowercase).
  /// Consecutive uppercase letters are treated as one acronym and lowercased as a unit.
  ///
  /// Returns the camelCase string.
  ///
  /// Example:
  /// ```dart
  /// 'HTTP response'.toCamelCaseAcronyms();  // 'httpResponse'
  /// ```
  @useResult
  String toCamelCaseAcronyms() {
    if (isEmpty) return this;
    final List<String> words = split(
      RegExp(r'[^a-zA-Z]+'),
    ).where((String word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '';
    final StringBuffer sb = StringBuffer(words[0].toLowerCase());
    for (int i = 1; i < words.length; i++) {
      final String word = words[i];
      if (word.length > 1) {
        final String rest = word.substringSafe(1);
        // A fully-uppercase word is treated as a single acronym and lowercased
        // whole (HTTP -> http), instead of title-casing it to "Http".
        final bool allUpper = word.toUpperCase() == word;
        if (allUpper) {
          sb.write(word.toLowerCase());
        } else {
          const int firstCharIndex = 0;
          final String firstChar = word[firstCharIndex];
          sb
            ..write(firstChar.toUpperCase())
            ..write(rest.toLowerCase());
        }
      } else {
        sb.write(word.toUpperCase());
      }
    }
    return sb.toString();
  }

  /// Converts to snake_case, lowercasing acronyms (e.g. HTTPResponse → http_response).
  ///
  /// Returns the snake_case string.
  ///
  /// Example:
  /// ```dart
  /// 'HTTPResponse'.toSnakeCaseAcronyms();  // 'http_response'
  /// ```
  @useResult
  String toSnakeCaseAcronyms() {
    if (isEmpty) return this;
    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < length; i++) {
      final String c = this[i];
      if (c == ' ' || c == '-') {
        sb.write('_');
      } else {
        // Only cased uppercase letters start a word boundary. Checking that the
        // upper-cased form equals the character is not enough on its own, because
        // caseless characters such as digits and symbols also equal their own
        // upper-cased form. Also requiring the lower-cased form to differ excludes
        // those caseless characters.
        final bool upper = c.toUpperCase() == c && c.toLowerCase() != c;
        if (upper && i > 0) {
          final String prev = this[i - 1];
          final bool prevLower = prev.toUpperCase() != prev || prev.toLowerCase() == prev;
          final bool nextLower = i + 1 < length && this[i + 1].toLowerCase() == this[i + 1];
          // Insert "_" in two cases. First, a lower-then-Upper transition, e.g.
          // fooBar becomes foo_bar. Second, the last capital of an acronym that
          // begins a new word, detected by Upper-then-lower: in HTTPResponse the
          // boundary falls before the R, not inside the HTTP run.
          if (prevLower || (prev.toUpperCase() == prev && nextLower)) sb.write('_');
        }
        sb.write(c.toLowerCase());
      }
    }
    return sb.toString().replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
  }
}
