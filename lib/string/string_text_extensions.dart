import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/list/list_extensions.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

final RegExp _consecutiveSpacesRegex = RegExp(r'\s+');

final RegExp _splitCapitalizedUnicodeRegex = RegExp(r'(?<=\p{Ll})(?=\p{Lu}|\p{Lt})', unicode: true);

final RegExp _splitCapitalizedUnicodeWithNumbersRegex = RegExp(
  r'(?<=\p{Ll})(?=\p{Lu}|\p{Lt}|\p{Nd})|(?<=\p{Nd})(?=\p{L})',
  unicode: true,
);

final RegExp _singleCharWordRegex = RegExp(r'(?<=^|\s)[\p{L}\p{N}](?=\s|$)', unicode: true);

const List<String> _silentHPrefixes = <String>[
  'hour',
  'honest',
  'honor',
  'heir',
];
const List<String> _youSoundPrefixes = <String>[
  'uni',
  'use',
  'user',
  'union',
  'university',
];
const String _wunSoundPrefix = 'one';

/// Extensions on [String] for words, grammar, lines, and text display.
extension StringTextExtensions on String {
  /// Returns a new string with consecutive whitespace collapsed into a single
  /// space, or `null` if the result is empty.
  ///
  /// When [trim] is `true` (default), the result is also trimmed.
  @useResult
  String? removeConsecutiveSpaces({bool trim = true}) {
    if (isEmpty) {
      return null;
    }
    final String replaced = replaceAll(_consecutiveSpacesRegex, ' ');

    return replaced.nullIfEmpty(trimFirst: trim);
  }

  /// Returns the result of collapsing consecutive whitespace, or `null` if
  /// empty. Alias for `removeConsecutiveSpaces`.
  @useResult
  String? compressSpaces({bool trim = true}) => removeConsecutiveSpaces(trim: trim);

  /// Returns a list of segments split at capitalized letters (Unicode-aware).
  ///
  /// When [splitNumbers] is `true`, also splits before digits. When
  /// [splitBySpace] is `true`, further splits each segment by whitespace.
  /// Adjacent segments shorter than [minLength] are merged together.
  @useResult
  List<String> splitCapitalizedUnicode({
    bool splitNumbers = false,
    bool splitBySpace = false,
    int minLength = 1,
  }) {
    if (isEmpty) {
      return <String>[];
    }

    final RegExp capitalizationPattern = splitNumbers
        ? _splitCapitalizedUnicodeWithNumbersRegex
        : _splitCapitalizedUnicodeRegex;
    List<String> intermediateSplit = split(capitalizationPattern);

    if (minLength > 1 && intermediateSplit.length > 1) {
      final List<String> mergedResult = <String>[];
      String currentBuffer = intermediateSplit[0];
      for (int i = 1; i < intermediateSplit.length; i++) {
        final String nextPart = intermediateSplit[i];
        if (currentBuffer.length < minLength || nextPart.length < minLength) {
          currentBuffer = '$currentBuffer$nextPart';
        } else {
          mergedResult.add(currentBuffer);
          currentBuffer = nextPart;
        }
      }
      mergedResult.add(currentBuffer);
      intermediateSplit = mergedResult;
    }

    if (!splitBySpace) {
      return intermediateSplit;
    }

    return intermediateSplit
        .expand((String part) => part.split(_consecutiveSpacesRegex))
        .where((String s) => s.isNotEmpty)
        .toList();
  }

  /// Returns this string split into a list of words, or `null` if empty.
  ///
  /// Uses space as the delimiter and filters out empty words.
  @useResult
  List<String>? words() {
    if (isEmpty) {
      return null;
    }

    return split(
      ' ',
    ).map((String word) => word.nullIfEmpty()).whereType<String>().toList().nullIfEmpty();
  }

  /// Returns the first word of this string, or `null` if empty.
  @useResult
  String? firstWord() {
    if (isEmpty) {
      return null;
    }

    return words()?.firstOrNull;
  }

  /// Returns the second word of this string, or `null` if fewer than two
  /// words.
  @useResult
  String? secondWord() {
    if (isEmpty) {
      return null;
    }

    final List<String>? wordList = words();
    if (wordList == null || wordList.length < 2) {
      return null;
    }

    return wordList[1];
  }

  /// Returns a new string with single-character words removed, or `null` if
  /// the result is empty.
  ///
  /// When [trim] is `true` (default), the result is trimmed. When
  /// [removeMultipleSpaces] is `true` (default), consecutive spaces are
  /// collapsed.
  ///
  /// **Example:**
  /// ```dart
  /// 'a hello world'.removeSingleCharacterWords(); // 'hello world'
  /// 'I am 5 years old'.removeSingleCharacterWords(); // 'am years old'
  /// 'x y z'.removeSingleCharacterWords(); // null (all removed)
  /// ```
  @useResult
  String? removeSingleCharacterWords({
    bool trim = true,
    bool removeMultipleSpaces = true,
  }) {
    if (isEmpty) {
      return this;
    }

    String result = removeAll(_singleCharWordRegex);
    if (removeMultipleSpaces) {
      result = result.replaceAll(_consecutiveSpacesRegex, ' ');
    }

    if (trim) {
      result = result.trim();
    }

    return result.isEmpty ? null : result;
  }

  /// Returns the first [limit] lines of this string.
  @useResult
  String firstLines(int limit) {
    if (isEmpty || limit <= 0) {
      return '';
    }

    final List<String> lines = split(StringExtensions.newLine);

    return lines.take(limit).join(StringExtensions.newLine);
  }

  /// Returns a new string with each line trimmed and empty lines removed.
  @useResult
  String trimLines() => split(StringExtensions.newLine)
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .join(StringExtensions.newLine);

  /// Returns a new string with [insertText] prepended to every line.
  ///
  /// When [prefixEmptyStrings] is `true`, empty strings also receive the
  /// prefix.
  @useResult
  String multiLinePrefix(
    String insertText, {
    bool prefixEmptyStrings = false,
  }) {
    if (insertText.isEmpty) {
      return this;
    }

    if (isEmpty) {
      return prefixEmptyStrings ? insertText : '';
    }

    return insertText +
        replaceAll(
          StringExtensions.newLine,
          StringExtensions.newLine + insertText,
        );
  }

  /// Returns the appropriate indefinite article (`'a'` or `'an'`) for this
  /// word, or an empty string if input is empty.
  ///
  /// Uses English grammar heuristics for silent 'h', "you"-sound words,
  /// and vowel/consonant detection.
  ///
  /// **Example:**
  /// ```dart
  /// 'apple'.grammarArticle(); // 'an'
  /// 'hour'.grammarArticle(); // 'an' (silent h)
  /// 'user'.grammarArticle(); // 'a' (you-sound)
  /// 'university'.grammarArticle(); // 'a'
  /// 'one-time'.grammarArticle(); // 'a'
  /// ```
  @useResult
  String grammarArticle() {
    if (isEmpty) {
      return '';
    }

    final String word = trim();
    if (word.isEmpty) {
      return '';
    }

    final String lower = word.toLowerCase();

    if (_silentHPrefixes.any(lower.startsWith)) {
      return 'an';
    }

    if (_youSoundPrefixes.any(lower.startsWith)) {
      return 'a';
    }

    if (lower.startsWith(_wunSoundPrefix)) {
      return 'a';
    }

    return switch (lower[0]) {
      'a' || 'e' || 'i' || 'o' || 'u' => 'an',
      _ => 'a',
    };
  }

  /// Returns the possessive form of this string (e.g., "John's", "boss'").
  ///
  /// When [isLocaleUS] is `true` (default), words ending in 's' get only an
  /// apostrophe ("boss'"). When `false`, they get apostrophe-s ("boss's").
  ///
  /// **Example:**
  /// ```dart
  /// 'John'.possess(); // "John's"
  /// 'boss'.possess(); // "boss'" (US style)
  /// 'boss'.possess(isLocaleUS: false); // "boss's" (non-US)
  /// ```
  @useResult
  String possess({bool isLocaleUS = true}) {
    if (isEmpty) {
      return this;
    }

    final String base = trim();
    if (base.isEmpty) {
      return base;
    }

    final String lastChar = base.lastChars(1).toLowerCase();
    if (lastChar == 's') {
      return isLocaleUS ? '$base\'' : '$base\'s';
    }

    return '$base\'s';
  }

  /// Returns the plural form of this string based on [count].
  ///
  /// When [simple] is `true`, just appends 's'. Otherwise, applies English
  /// pluralization rules (e.g., -es, -ies).
  @useResult
  String pluralize(num? count, {bool simple = false}) {
    if (isEmpty || count == 1) {
      return this;
    }

    if (simple) {
      return '${this}s';
    }

    final String lastChar = lastChars(1);
    switch (lastChar) {
      case 's':
      case 'x':
      case 'z':
        return '${this}es';
      case 'y':
        if (length > 2 && this[length - 2].isVowel()) {
          return '${this}s';
        }

        return '${substringSafe(0, length - 1)}ies';
    }

    final String lastTwo = lastChars(2);
    if (lastTwo == 'sh' || lastTwo == 'ch') {
      return '${this}es';
    }

    return '${this}s';
  }

  /// Returns a truncated version of this string with ellipsis, keeping the
  /// first and last [minLength] characters.
  @useResult
  String trimWithEllipsis({int minLength = 5}) {
    if (length < minLength) {
      return StringExtensions.ellipsis;
    }

    if (length < (minLength * 2) + 2) {
      return substringSafe(0, minLength) + StringExtensions.ellipsis;
    }

    return substringSafe(0, minLength) +
        StringExtensions.ellipsis +
        substringSafe(length - minLength);
  }

  /// Returns this multiline string collapsed into a single line, truncated to
  /// [cropLength] characters.
  ///
  /// When [appendEllipsis] is `true` (default), an ellipsis is appended if
  /// truncated.
  @useResult
  String collapseMultilineString({
    required int cropLength,
    bool appendEllipsis = true,
  }) {
    if (isEmpty) {
      return this;
    }

    final String collapsed = replaceAll(StringExtensions.newLine, ' ').replaceAll('  ', ' ');
    if (collapsed.length <= cropLength) {
      return collapsed.trim();
    }

    String cropped = collapsed.substringSafe(0, cropLength + 1);
    while (cropped.isNotEmpty && !cropped.endsWithAny(StringExtensions.commonWordEndings)) {
      cropped = cropped.substringSafe(0, cropped.length - 1);
    }

    if (cropped.isNotEmpty) {
      cropped = cropped.substringSafe(0, cropped.length - 1).trim();
    }

    return appendEllipsis ? cropped + StringExtensions.ellipsis : cropped;
  }
}
