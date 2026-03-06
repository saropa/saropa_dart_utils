import 'package:meta/meta.dart';

/// Clamp to int (round then clamp). Roadmap #118.
extension NumClampToIntExtensions on num {
  /// Rounds to nearest int then clamps to [min]..[max].
  @useResult
  int clampToInt(int min, int max) {
    final int n = round();
    if (n < min) return min;
    if (n > max) return max;
    return n;
  }
}
