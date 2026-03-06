/// Soundex phonetic encoding for English names.
///
/// Tree-shakeable: import only this file if you need Soundex.
library;

/// Soundex encoding: words that sound similar produce the same code.
abstract final class SoundexUtils {
  static const String _zero = '0';

  static const int _soundexCodeLength = 4;

  static const Map<String, int> _soundexCode = <String, int>{
    'B': 1,
    'F': 1,
    'P': 1,
    'V': 1,
    'C': 2,
    'G': 2,
    'J': 2,
    'K': 2,
    'Q': 2,
    'S': 2,
    'X': 2,
    'Z': 2,
    'D': 3,
    'T': 3,
    'L': 4,
    'M': 5,
    'N': 5,
    'R': 6,
  };

  /// Encodes this string using Soundex (first letter + 3 digits).
  ///
  /// Non-alpha characters are ignored. Returns 4-char string (letter + 3 digits),
  /// or empty string if no letters.
  ///
  /// Example:
  /// ```dart
  /// SoundexUtils.encode('Robert');  // 'R163'
  /// SoundexUtils.encode('Rupert');   // 'R163'
  /// ```
  static String encode(String s) {
    if (s.isEmpty) return '';
    final String letters = s.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (letters.isEmpty) return '';
    final StringBuffer out = StringBuffer(letters[0]);
    int prev = _code(letters[0]);
    int count = 1;
    for (int i = 1; i < letters.length && count < _soundexCodeLength; i++) {
      final int c = _code(letters[i]);
      if (c != 0 && c != prev) {
        prev = c;
        out.write(c);
        count++;
      }
    }
    while (count < _soundexCodeLength) {
      out.write(_zero);
      count++;
    }
    return out.toString();
  }

  static int _code(String char) {
    if (char.isEmpty) return 0;
    return _soundexCode[char[0]] ?? 0;
  }

  /// Returns true if [a] and [b] have the same Soundex code.
  static bool soundsLike(String a, String b) => encode(a) == encode(b);

  SoundexUtils._();
}
