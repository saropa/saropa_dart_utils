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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
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

  /// Replaces the FINAL breaking space in this string with a non-breaking space
  /// (`\u{00A0}`) when that wrap point would strand a short token — either the
  /// last word or the one before it — on its own line.
  ///
  /// Prevents an "orphan" — a lone `…`, `I`, `(5)`, or `the` — stranded at the
  /// END of a wrapped heading, which is the only place Flutter stable actually
  /// wraps text (there is no hyphenation; see upstream Flutter issue 18443).
  /// Only the last space in the string is ever a candidate: every earlier space
  /// is left as an ordinary breaking space, because a middle word going short
  /// is not an orphan — only the trailing one is.
  ///
  /// The candidate gap fuses when EITHER of the last two tokens (the one
  /// before the final space, or the one after it) is shorter than
  /// [minWrapChars]. [minWrapChars] `<= 0` fuses nothing (no token can be
  /// shorter than 0).
  ///
  /// Token length is measured in UTF-16 code units, not graphemes, so a short
  /// run of wide emoji or combining marks may still count as "short".
  /// Idempotent: if the final gap is already a non-breaking space, the string
  /// is returned unchanged.
  ///
  /// Example:
  /// ```dart
  /// 'Marked as Out of Date'.preventOrphans();
  /// // 'Marked as Out of\u{00A0}Date' — only the final gap ("of Date") fuses.
  /// 'Results (5)'.preventOrphans();     // 'Results\u{00A0}(5)'
  /// 'Importing Demo'.preventOrphans();  // 'Importing Demo'  (both long)
  /// ```
  /// Audited: 2026-09-26
  @useResult
  String preventOrphans({int minWrapChars = 4}) {
    if (length < 2) return this;

    // Only the final space/gap in the string is ever a fuse candidate; scan
    // from the end so every earlier gap is left untouched.
    int lastGap = -1;
    for (int i = length - 1; i >= 0; i--) {
      final String char = this[i];
      if (char == _kSpace || char == _kNonBreakingSpace) {
        lastGap = i;
        break;
      }
    }
    if (lastGap < 0) return this;
    // Idempotent: the final gap was already fused by a previous call.
    if (this[lastGap] == _kNonBreakingSpace) return this;

    // Walk back to the gap before that one (if any) to bound the token that
    // precedes the final space; everything before it is left untouched.
    int prevGap = -1;
    for (int i = lastGap - 1; i >= 0; i--) {
      final String char = this[i];
      if (char == _kSpace || char == _kNonBreakingSpace) {
        prevGap = i;
        break;
      }
    }

    final String tokenBefore = substring(prevGap + 1, lastGap);
    final String tokenAfter = substring(lastGap + 1);
    // Fuse when EITHER of the last two tokens fails the minimum (symmetric: an
    // orphan is bad whether it is the last word or the one before it).
    final bool fuse = tokenBefore.length < minWrapChars || tokenAfter.length < minWrapChars;
    if (!fuse) return this;

    return replaceRange(lastGap, lastGap + 1, _kNonBreakingSpace);
  }
}
