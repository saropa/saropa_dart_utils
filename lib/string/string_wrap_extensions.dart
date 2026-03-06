import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

const String _kErrColumnWidthPositive = 'columnWidth must be positive';
const String _kParamColumnWidth = 'columnWidth';
const String _kSpace = ' ';
const String _kErrMaxGraphemesNonNegative = 'maxGraphemes must be non-negative';
const String _kParamMaxGraphemes = 'maxGraphemes';

/// Word wrap and grapheme-safe truncation.
extension StringWrapExtensions on String {
  /// Wraps this string at [columnWidth], breaking at word boundaries when possible.
  ///
  /// Uses grapheme length for column count. [columnWidth] must be positive.
  /// Returns a list of lines (no trailing newline in each).
  ///
  /// Throws [ArgumentError] if [columnWidth] is not positive.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.wordWrap(5);  // ['hello', 'world']
  /// 'hi'.wordWrap(10);          // ['hi']
  /// ```
  @useResult
  List<String> wordWrap(int columnWidth) {
    if (columnWidth < 1) {
      throw ArgumentError(_kErrColumnWidthPositive, _kParamColumnWidth);
    }
    if (isEmpty) return <String>[];
    final Characters chars = characters;
    final int estimatedLines = (chars.length / columnWidth).ceil() + 1;
    final List<String> lines = List<String>.filled(estimatedLines, '');
    int lineIndex = 0;
    int i = 0;
    while (i < chars.length) {
      int lineEnd = i + columnWidth;
      if (lineEnd > chars.length) lineEnd = chars.length;
      final String segment = chars.getRange(i, lineEnd).string;
      int lineGraphemeCount = segment.characters.length;
      if (lineEnd < chars.length) {
        final int lastSpace = segment.lastIndexOf(_kSpace);
        if (lastSpace >= 0) {
          lineGraphemeCount = segment.replaceRange(lastSpace, segment.length, '').characters.length;
        }
      }
      final String lineContent = lineGraphemeCount <= 0
          ? ''
          : chars.getRange(i, i + lineGraphemeCount).string;
      lines[lineIndex++] = lineContent;
      i += lineContent.characters.length;
      if (i < chars.length && chars.elementAt(i) == _kSpace) i++;
    }
    return lines.sublist(0, lineIndex);
  }

  /// Truncates at grapheme boundary so no emoji or extended grapheme is cut.
  ///
  /// Returns at most [maxGraphemes] graphemes. [maxGraphemes] must be non-negative.
  ///
  /// Throws [ArgumentError] if [maxGraphemes] is negative.
  ///
  /// Example:
  /// ```dart
  /// 'hello👋world'.truncateAtGrapheme(5);  // 'hello'
  /// 'ab'.truncateAtGrapheme(10);           // 'ab'
  /// ```
  @useResult
  String truncateAtGrapheme(int maxGraphemes) {
    if (maxGraphemes < 0) {
      throw ArgumentError(_kErrMaxGraphemesNonNegative, _kParamMaxGraphemes);
    }
    if (isEmpty) return this;
    final Characters chars = characters;
    if (maxGraphemes >= chars.length) return this;
    return chars.take(maxGraphemes).string;
  }
}
