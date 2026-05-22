/// Lerp, inverse lerp, map value from one range to another. Roadmap #130–132.
double lerp(double a, double b, double t) => a + (b - a) * t;

/// Returns where [value] falls between [a] and [b] as a fraction in `0.0`–`1.0`.
///
/// The result is clamped to `[0, 1]`, so values outside the `[a, b]` range
/// return the nearest endpoint. Returns `0` when [a] equals [b] to avoid
/// division by zero.
///
/// Example:
/// ```dart
/// inverseLerp(0, 10, 5); // 0.5
/// inverseLerp(0, 10, 20); // 1.0 (clamped)
/// ```
double inverseLerp(double a, double b, double value) {
  if (a == b) return 0;
  return ((value - a) / (b - a)).clamp(0.0, 1.0);
}

/// Remaps [value] from the input range `[fromMin, fromMax]` to the output
/// range `[toMin, toMax]`.
///
/// The input fraction is clamped to `[0, 1]` via [inverseLerp], so [value]
/// outside the input range maps to the nearest output endpoint.
///
/// Example:
/// ```dart
/// mapRange(5, 0, 10, 0, 100); // 50.0
/// ```
double mapRange(double value, double fromMin, double fromMax, double toMin, double toMax) {
  final double t = inverseLerp(fromMin, fromMax, value);
  return lerp(toMin, toMax, t);
}
