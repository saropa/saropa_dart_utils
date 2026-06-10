import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

/// Truncate the middle of a string, keeping both ends visible.
extension StringTruncateMiddleExtensions on String {
  /// Returns this string shortened to [maxLength] by replacing the middle with
  /// [ellipsis], keeping the start and end visible.
  ///
  /// Useful where the distinguishing parts of a value sit at both ends — file
  /// paths (`/Users/…/report.pdf`), hashes, wallet addresses, long IDs — and
  /// plain end-truncation (`truncateWithEllipsis`) would hide the part that
  /// tells two values apart.
  ///
  /// Length is measured in grapheme clusters and the cut lands on cluster
  /// boundaries, so emoji and combining marks are never split. [maxLength] is
  /// the total visible length including [ellipsis]; the returned string is at
  /// most [maxLength] clusters long.
  ///
  /// Returns the original string unchanged when it already fits, when
  /// [maxLength] is `null` or non-positive. When [maxLength] is too small to
  /// hold the ellipsis plus at least one cluster from each side, it degrades to
  /// the leading [maxLength] clusters (with no ellipsis) rather than returning
  /// something longer than requested.
  ///
  /// Example:
  /// ```dart
  /// '/Users/craig/projects/report.pdf'.truncateMiddle(20); // '/Users/cr…report.pdf'
  /// 'abcdef'.truncateMiddle(10); // 'abcdef' (already fits)
  /// ```
  @useResult
  String truncateMiddle(int? maxLength, {String ellipsis = '…'}) {
    if (maxLength == null || maxLength <= 0) {
      return this;
    }

    final Characters chars = characters;
    final int length = chars.length;
    if (length <= maxLength) {
      return this;
    }

    // Below this, there is no room for the ellipsis plus one cluster per side,
    // so a middle elision is impossible — fall back to a hard leading cut that
    // still respects maxLength rather than overflowing it.
    final int ellipsisLength = ellipsis.characters.length;
    final int keep = maxLength - ellipsisLength;
    if (keep < 2) {
      return chars.take(maxLength).toString();
    }

    // Bias the extra cluster (when keep is odd) to the front, matching how
    // readers scan paths/IDs left-to-right.
    final int frontCount = keep - keep ~/ 2;
    final int backCount = keep ~/ 2;

    final String front = chars.take(frontCount).toString();
    final String back = chars.takeLast(backCount).toString();
    return '$front$ellipsis$back';
  }
}
