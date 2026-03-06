import 'package:meta/meta.dart';

/// Safe division (avoid division by zero). Roadmap #140.
extension NumSafeDivisionExtensions on num {
  /// Divides by [divisor]. Returns [defaultValue] if [divisor] is 0 or null.
  @useResult
  double divideSafe(num divisor, [double defaultValue = 0]) {
    if (divisor == 0) return defaultValue;
    return this / divisor;
  }
}

/// Divides [a] by [b]; returns null if [b] is 0.
double? safeDivide(num a, num b) {
  if (b == 0) return null;
  return a / b;
}
