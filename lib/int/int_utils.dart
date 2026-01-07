/// `IntUtils` is a utility class in Dart that provides static methods
/// for performing operations on integers. This class cannot be instantiated.
///
/// The methods in this class include, but are not limited to, methods for
/// finding the greatest common denominator (GCD) of two integers using the
/// Euclidean algorithm.
///
/// Example usage:
/// ```dart
/// int gcd = IntUtils.findGCD(48, 18);  // returns 6
/// ```
///
/// Note: All methods in this class are null-safe, meaning they will not throw
/// an exception if the input integers are not within the expected range.
/// Instead, they will return a reasonable default value (usually null).
///
class IntUtils {
  /// This method finds the greatest common denominator of two integers.
  /// It uses the Euclidean algorithm, which is based on the principle that the
  /// greatest common denominator of two numbers does not change if the larger
  /// number is replaced by its difference with the smaller number.
  ///
  /// [depth] is used to track the recursion depth, and [maxDepth] is used to
  /// prevent the recursion from going too deep.
  ///
  /// Both [a] and [b] must be non-negative.
  ///
  static int? findGreatestCommonDenominator(int a, int b, {int depth = 0, int maxDepth = 500}) {
    // Both numbers must be non-negative.
    if (a < 0 || b < 0) {
      return null;
    }

    // If the recursion depth exceeds the maximum depth, return -1.
    if (depth > maxDepth) {
      return null;
    }

    // If [a] and [b] are both zero, return null as GCD is undefined.
    if (a == 0 && b == 0) {
      return null;
    }

    // If [b] is 0, then [a] is the greatest common denominator.
    if (b == 0) {
      return a;
    }

    /*** NOTE: RECURSION ***/

    // Otherwise, recursively call this method with [b] and the remainder of
    // [a] divided by [b].
    return findGreatestCommonDenominator(b, a % b, depth: depth + 1, maxDepth: maxDepth);
  }
}
