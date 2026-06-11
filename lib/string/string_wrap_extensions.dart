import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

const String _kErrColumnWidthPositive = 'columnWidth must be positive';
const String _kParamColumnWidth = 'columnWidth';
const String _kSpace = ' ';
// Non-breaking space (U+00A0) as a Dart escape ON PURPOSE: a raw U+00A0 in
// source flattens to an ASCII space in transit and silently breaks the
// preventOrphans contract. Keep the escape.
const String _kNonBreakingSpace = '\u{00A0}';
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
      // Only try a word-boundary break when this segment isn't the final tail;
      // the last segment is taken whole so no trailing content is dropped.
      if (lineEnd < chars.length) {
        final int lastSpace = segment.lastIndexOf(_kSpace);
        // Back the line up to the last space so words aren't split mid-word.
        // Re-measure in graphemes because lastIndexOf returns a code-unit offset,
        // which can't be used directly to slice the grapheme-indexed source.
        // No space at all means one unbreakable run, so fall through to a hard
        // cut at columnWidth.
        if (lastSpace >= 0) {
          lineGraphemeCount = segment.replaceRange(lastSpace, segment.length, '').characters.length;
        }
      }
      final String lineContent = lineGraphemeCount <= 0
          ? ''
          : chars.getRange(i, i + lineGraphemeCount).string;
      lines[lineIndex++] = lineContent;
      i += lineContent.characters.length;
      // Consume the single break space so it doesn't lead the next line.
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

  /// Replaces a breaking space with a non-breaking space (`\u{00A0}`) wherever a
  /// line wrap at that space would strand a token shorter than [minWrapChars] on
  /// its own line.
  ///
  /// Prevents an "orphan" — a lone `…`, `I`, `(5)`, or `the` — at the end or
  /// middle of a wrapped heading. The rule is symmetric and position-agnostic:
  /// a space is fused when EITHER adjacent token is shorter than [minWrapChars],
  /// because an orphan is unwanted whether it is left behind or pulled forward.
  /// This beats the common "last-space + short-tail" heuristic.
  ///
  /// Splitting is on a single ASCII space (`' '`) only — tabs, newlines, and
  /// existing non-breaking spaces are NOT split. As a result, a run of two or
  /// more spaces and any leading/trailing space yields an empty edge token
  /// (length 0, always below the minimum) whose adjoining space therefore fuses.
  /// [minWrapChars] `<= 0` fuses nothing (no token can be shorter than 0); a
  /// value larger than the longest token fuses everything.
  ///
  /// Token length is measured in UTF-16 code units, not graphemes, so a short
  /// run of wide emoji or combining marks may still count as "short". Idempotent:
  /// once fused, a short token is absorbed into a longer non-breaking-joined
  /// token, so re-applying changes nothing.
  ///
  /// Example:
  /// ```dart
  /// 'Results (5)'.preventOrphans();     // 'Results\u{00A0}(5)'
  /// 'Importing Demo'.preventOrphans();  // 'Importing Demo'  (both long)
  /// ```
  @useResult
  String preventOrphans({int minWrapChars = 4}) {
    if (length < 2) return this;
    final List<String> parts = split(_kSpace);
    if (parts.length < 2) return this;
    final StringBuffer buf = StringBuffer(parts.first);
    for (int i = 1; i < parts.length; i++) {
      // Fuse when EITHER adjacent token fails the minimum (symmetric: an orphan
      // is bad whether it is left behind or pulled forward).
      final bool fuse = parts[i - 1].length < minWrapChars || parts[i].length < minWrapChars;
      buf
        ..write(fuse ? _kNonBreakingSpace : _kSpace)
        ..write(parts[i]);
    }
    return buf.toString();
  }
}
