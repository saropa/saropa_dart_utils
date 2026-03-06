/// Levenshtein (edit) distance and similarity ratio for strings.
///
/// Tree-shakeable: import only this file if you need edit distance.
library;

import 'string_extensions.dart';

/// Utilities for Levenshtein edit distance and derived metrics.
abstract final class LevenshteinUtils {
  LevenshteinUtils._();

  /// Returns the Levenshtein (edit) distance between [a] and [b].
  ///
  /// The distance is the minimum number of single-character edits
  /// (insertions, deletions, substitutions) required to change [a] into [b].
  /// Uses O(length(a)*length(b)) time and O(min(length(a),length(b))) space.
  ///
  /// Example:
  /// ```dart
  /// LevenshteinUtils.distance('kitten', 'sitting'); // 3
  /// LevenshteinUtils.distance('', 'abc');           // 3
  /// LevenshteinUtils.distance('same', 'same');      // 0
  /// ```
  static int distance(String a, String b) {
    final int aLen = a.length;
    final int bLen = b.length;
    if (aLen == 0) {
      return bLen;
    }
    if (bLen == 0) {
      return aLen;
    }
    // Two rows only for space efficiency.
    List<int> prevRow = List<int>.filled(bLen + 1, 0);
    List<int> currRow = List<int>.filled(bLen + 1, 0);
    for (int j = 0; j <= bLen; j++) {
      prevRow[j] = j;
    }
    const int firstCol = 0;
    for (int i = 1; i <= aLen; i++) {
      // First column of current row: cost = i (i deletions from a).
      currRow[firstCol] = i;
      for (int j = 1; j <= bLen; j++) {
        final int cost = a[i - 1] == b[j - 1] ? 0 : 1;
        currRow[j] = _min3(
          currRow[j - 1] + 1,
          prevRow[j] + 1,
          prevRow[j - 1] + cost,
        );
      }
      final List<int> swap = prevRow;
      prevRow = currRow;
      currRow = swap;
    }
    return prevRow[bLen];
  }

  static int _min3(int a, int b, int c) {
    if (a <= b && a <= c) return a;
    if (b <= c) return b;
    return c;
  }

  /// Returns a similarity ratio in the range 0.0 (no similarity) to 1.0 (identical).
  ///
  /// Defined as `1 - (distance / length of longer string)`. Empty strings yield 1.0 (treated as identical).
  ///
  /// Example:
  /// ```dart
  /// LevenshteinUtils.ratio('kitten', 'sitting'); // ~0.57
  /// LevenshteinUtils.ratio('', '');             // 1.0
  /// LevenshteinUtils.ratio('abc', 'abc');      // 1.0
  /// ```
  static double ratio(String a, String b) {
    final int lengthA = a.length;
    final int lengthB = b.length;
    if (lengthA == 0 && lengthB == 0) {
      return 1.0;
    }
    final int maxLen = lengthA > lengthB ? lengthA : lengthB;
    if (maxLen == 0) {
      return 1.0;
    }
    final int d = distance(a, b);
    return 1.0 - (d / maxLen);
  }

  /// Returns true if [source] contains a substring that matches [target]
  /// within a maximum edit distance of [maxDistance].
  ///
  /// Uses a sliding window over [source] and returns true on first match.
  /// [maxDistance] must be non-negative.
  ///
  /// Throws [ArgumentError] if [maxDistance] is negative.
  ///
  /// Example:
  /// ```dart
  /// LevenshteinUtils.fuzzyContains('hello world', 'worls', 1); // true (1 edit)
  /// LevenshteinUtils.fuzzyContains('hello', 'xyz', 2);         // false
  /// ```
  static const String _kErrMaxDistanceNonNegative = 'maxDistance must be non-negative';
  static const String _kParamMaxDistance = 'maxDistance';

  static bool fuzzyContains(String source, String target, int maxDistance) {
    if (maxDistance < 0) {
      throw ArgumentError(_kErrMaxDistanceNonNegative, _kParamMaxDistance);
    }
    if (target.length == 0) {
      return true;
    }
    if (source.length < target.length) {
      return false;
    }
    final int windowSize = target.length;
    for (int i = 0; i <= source.length - windowSize; i++) {
      final int end = (i + windowSize).clamp(0, source.length);
      final String slice = source.substringSafe(i, end);
      if (distance(slice, target) <= maxDistance) return true;
    }
    return false;
  }
}
