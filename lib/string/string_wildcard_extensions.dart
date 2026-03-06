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
    int si = stringIndex;
    int pi = patternIndex;
    while (pi < pattern.length) {
      final String pc = pattern[pi];
      if (pc == '*') {
        pi++;
        if (pi >= pattern.length) return true;
        while (si <= string.length) {
          if (_wildcardMatchImpl(
            string: string,
            stringIndex: si,
            pattern: pattern,
            patternIndex: pi,
          ))
            return true;
          si++;
        }
        return false;
      }
      if (si >= string.length) return false;
      if (pc == '?') {
        si++;
        pi++;
      } else {
        if (string[si] != pc) return false;
        si++;
        pi++;
      }
    }
    return si >= string.length;
  }
}
