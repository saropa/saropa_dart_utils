import 'package:meta/meta.dart';

/// Extensions for wildcard matching (`*` = any sequence, `?` = single character).
extension StringWildcardExtensions on String {
  /// Returns true if this string matches the [pattern] with wildcards.
  ///
  /// [pattern] may contain:
  /// - `*` matches zero or more characters
  /// - `?` matches exactly one character
  /// - Other characters match literally. Matching is case-sensitive.
  ///
  /// [pattern] must not be null. Empty pattern matches only empty string.
  ///
  /// Example:
  /// ```dart
  /// 'hello.txt'.wildcardMatch('*.txt');   // true
  /// 'file'.wildcardMatch('f?le');         // true
  /// 'ab'.wildcardMatch('a*b');            // true
  /// ```
  @useResult
  bool wildcardMatch(String pattern) {
    if (pattern.isEmpty) return isEmpty;
    return _wildcardMatchImpl(
      string: this,
      stringIndex: 0,
      pattern: pattern,
      patternIndex: 0,
    );
  }

  static bool _wildcardMatchImpl({
    required String string,
    required int stringIndex,
    required String pattern,
    required int patternIndex,
  }) {
    // Walk pattern and string in lockstep from the given offsets.
    int si = stringIndex;
    int pi = patternIndex;
    while (pi < pattern.length) {
      final String pc = pattern[pi];
      if (pc == '*') {
        // '*' matches any run (including empty). A trailing '*' matches the rest
        // outright; otherwise try to match the remaining pattern at every split
        // point of the remaining string (this is the backtracking branch).
        pi++;
        if (pi >= pattern.length) return true;
        while (si <= string.length) {
          if (_wildcardMatchImpl(
            string: string,
            stringIndex: si,
            pattern: pattern,
            patternIndex: pi,
          )) {
            return true;
          }
          si++;
        }
        return false;
      }
      // Past '*', any non-'*' token needs a character to consume.
      if (si >= string.length) return false;
      if (pc == '?') {
        // '?' matches exactly one arbitrary character.
        si++;
        pi++;
      } else {
        // Literal: must match the current character exactly.
        if (string[si] != pc) return false;
        si++;
        pi++;
      }
    }
    // Pattern consumed: it matches only if the string is also fully consumed.
    return si >= string.length;
  }
}
