import 'package:meta/meta.dart';

import 'string_extensions.dart';

final RegExp _wordBoundary = RegExp(r'\s+');

const String _kErrCharCountPositive = 'charCount must be positive';
const String _kParamCharCount = 'charCount';

/// Word count and break long words.
extension StringWordsExtensions on String {
  /// Counts words using whitespace as delimiters.
  ///
  /// Leading/trailing whitespace is trimmed. Empty string returns 0.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.wordCount();  // 2
  /// '  a  b  '.wordCount();    // 2
  /// ```
  @useResult
  int wordCount() {
    if (isEmpty) return 0;
    final String trimmed = trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(_wordBoundary).where((String s) => s.isNotEmpty).length;
  }

  /// Inserts [separator] (e.g. soft hyphen) every [charCount] graphemes within long words.
  ///
  /// Only inserts inside "words" (runs of non-whitespace). [charCount] must be positive.
  /// Uses character length, not grapheme; for grapheme-safe behavior use with ASCII or normalize.
  /// Returns the string with separators inserted in long words.
  ///
  /// Throws [ArgumentError] if [charCount] is not positive.
  ///
  /// Example:
  /// ```dart
  /// 'hello'.breakLongWords(2, '\u00ad');  // 'hel\u00adlo'
  /// ```
  @useResult
  String breakLongWords(int charCount, String separator) {
    if (charCount < 1) {
      throw ArgumentError(_kErrCharCountPositive, _kParamCharCount);
    }
    if (isEmpty) return this;
    final List<String> wordsList = split(RegExp(r'\s+')).toList();
    if (wordsList.isEmpty) return this;
    final List<String> result = List<String>.filled(wordsList.length, '');
    final StringBuffer sb = StringBuffer();
    int idx = 0;
    for (final String word in wordsList) {
      if (word.length <= charCount) {
        result[idx++] = word;
      } else {
        sb.clear();
        for (int i = 0; i < word.length; i += charCount) {
          if (i > 0) sb.write(separator);
          final int end = (i + charCount).clamp(0, word.length);
          final int start = i.clamp(0, word.length);
          sb.write(word.substringSafe(start, end));
        }
        result[idx++] = sb.toString();
      }
    }
    return result.sublist(0, idx).join(' ');
  }
}
