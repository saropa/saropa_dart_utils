import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

final RegExp _apostropheRegex = RegExp('[\u2018\u2019]');

final RegExp _latinRegex = RegExp(r'^[a-zA-Z]+$');

final RegExp _anyDigitsRegex = RegExp(r'\d');

final RegExp _curlyBracesRegex = RegExp(r'\{.+?\}');

/// Extensions on [String] for validation, comparison, and analysis.
extension StringAnalysisExtensions on String {
  /// Returns `true` if this string contains only Latin alphabet characters
  /// (a-z, A-Z).
  @useResult
  bool isLatin() => _latinRegex.hasMatch(this);

  /// Returns `true` if this string equals [other], with options for
  /// case-insensitivity via [ignoreCase] and apostrophe normalization via
  /// [normalizeApostrophe].
  @useResult
  bool isEquals(
    String? other, {
    bool ignoreCase = true,
    bool normalizeApostrophe = true,
  }) {
    if (other == null) {
      return false;
    }

    String first = this;
    String second = other;

    if (ignoreCase) {
      first = first.toLowerCase();
      second = second.toLowerCase();
    }

    if (normalizeApostrophe) {
      first = first.replaceAll(_apostropheRegex, "'");
      second = second.replaceAll(_apostropheRegex, "'");
    }

    return first == second;
  }

  /// Returns `true` if this string contains [other] in a case-insensitive
  /// manner.
  ///
  /// An empty string is considered to be contained in any string. Returns
  /// `false` only when [other] is `null`.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World'.containsIgnoreCase('world'); // true
  /// 'Hello World'.containsIgnoreCase('HELLO'); // true
  /// 'Hello World'.containsIgnoreCase(null); // false
  /// ```
  @useResult
  bool containsIgnoreCase(String? other) {
    if (other == null) {
      return false;
    }

    if (other.isEmpty) {
      return true;
    }

    return toLowerCase().contains(other.toLowerCase());
  }

  /// Returns the first character where this string and [other] differ, or an
  /// empty string if they are identical.
  @useResult
  String getFirstDiffChar(String other) {
    final int minLength = length < other.length ? length : other.length;

    for (int i = 0; i < minLength; i++) {
      if (this[i] != other[i]) {
        return other[i];
      }
    }

    if (length > other.length) {
      return this[minLength];
    }

    if (other.length > length) {
      return other[minLength];
    }

    return '';
  }

  /// The Unicode replacement character code point for invalid sequences.
  static const int _invalidUnicodeReplacementRuneCode = 56327;

  /// Returns true if this string contains invalid Unicode characters.
  @useResult
  bool get hasInvalidUnicode {
    if (isEmpty) {
      return false;
    }

    return runes.any((int r) => r == _invalidUnicodeReplacementRuneCode);
  }

  /// Returns a new string with all invalid Unicode replacement characters
  /// removed.
  @useResult
  String removeInvalidUnicode() {
    if (isEmpty) {
      return this;
    }

    final StringBuffer buffer = StringBuffer();
    for (int r in runes.where((int e) => e != _invalidUnicodeReplacementRuneCode)) {
      buffer.write(String.fromCharCode(r));
    }

    return buffer.toString();
  }

  /// Returns true if this single-character string is a vowel.
  @useResult
  bool isVowel() {
    if (isEmpty || length != 1) {
      return false;
    }

    return switch (toLowerCase()) {
      'a' || 'e' || 'i' || 'o' || 'u' => true,
      _ => false,
    };
  }

  /// Returns true if this string contains any digit characters.
  @useResult
  bool hasAnyDigits() => contains(_anyDigitsRegex);

  /// Returns the number of non-overlapping occurrences of [find] in this
  /// string.
  ///
  /// **Example:**
  /// ```dart
  /// 'hello'.count('l'); // 2
  /// 'aaa'.count('aa'); // 1 (non-overlapping)
  /// 'test'.count('x'); // 0
  /// 'hello'.count(''); // 0
  /// ```
  @useResult
  int count(String find) {
    if (find.isEmpty) {
      return 0;
    }

    return split(find).length - 1;
  }

  /// Returns the index of the second occurrence of [char], or `-1` if not
  /// found.
  @useResult
  int secondIndex(String char) {
    if (char.isEmpty || isEmpty) {
      return -1;
    }

    final int firstIdx = indexOf(char);
    if (firstIdx == -1) {
      return -1;
    }

    return indexOf(char, firstIdx + 1);
  }

  /// Extracts all text within curly braces from this string.
  ///
  /// Uses a non-greedy regex to match multiple brace-enclosed groups
  /// in the order they appear.
  ///
  /// **Returns:**
  /// A list of matched strings (including braces), or null if no matches.
  ///
  /// **Example:**
  /// ```dart
  /// '{start} middle {end}'.extractCurlyBraces(); // ['{start}', '{end}']
  /// '{a}{b}{c}'.extractCurlyBraces(); // ['{a}', '{b}', '{c}']
  /// 'no braces'.extractCurlyBraces(); // null
  /// ```
  @useResult
  List<String>? extractCurlyBraces() {
    final List<String> matches = _curlyBracesRegex
        .allMatches(this)
        .map((Match m) => m[0])
        .whereType<String>()
        .toList();

    return matches.isEmpty ? null : matches;
  }

  /// Returns an obscured version of this string using [char] repeated, or
  /// `null` if empty.
  ///
  /// The output length varies by ±[obscureLength] characters using a
  /// time-based jitter to prevent guessing the original string length.
  ///
  /// **Example:**
  /// ```dart
  /// 'password'.obscureText(); // '••••••••••' (length varies)
  /// 'secret'.obscureText(char: '*'); // '******' (length varies)
  /// ''.obscureText(); // null
  /// ```
  @useResult
  String? obscureText({String char = '•', int obscureLength = 3}) {
    if (isEmpty) {
      return null;
    }

    final int seed = DateTime.now().microsecondsSinceEpoch;
    final int extraLength = (seed % (2 * obscureLength + 1)) - obscureLength;
    final int finalLength = length + extraLength;

    return char * (finalLength > 0 ? finalLength : 1);
  }

  /// Returns `true` if this string ends with any character in [find].
  @useResult
  bool endsWithAny(List<String> find) {
    if (isEmpty || find.isEmpty) {
      return false;
    }

    final String lastChar = last(1);

    return find.any((String e) => e == lastChar);
  }

  /// Returns `true` if this string ends with punctuation (`.`, `?`, or `!`).
  @useResult
  bool endsWithPunctuation() => endsWithAny(const <String>['.', '?', '!']);

  /// Returns `true` if this string equals any item in [list].
  @useResult
  bool isAny(List<String> list) {
    if (isEmpty || list.isEmpty) {
      return false;
    }

    return list.any((String e) => e == this);
  }
}
