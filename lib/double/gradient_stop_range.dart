import 'package:meta/meta.dart';

/// Named easing categories mapped to normalized gradient stop pairs (0..1).
///
/// Each variant returns a two-element [List] of `double` stops suitable for any
/// gradient API that accepts a `stops` list (Flutter `Gradient.stops`, a CSS
/// gradient-string builder, an SVG `<stop>` generator, or a custom shader).
///
/// The values are fixed constants:
///
/// - [StopRange.easeIn]    => `[0, 0.5]`     (front-loaded transition)
/// - [StopRange.easeOut]   => `[0.5, 1]`     (back-loaded transition)
/// - [StopRange.easeInOut] => `[0.25, 0.75]` (centered transition)
/// - [StopRange.linear]    => `[0, 1]`       (full-range, even transition)
///
/// Every pair is ascending, strictly increasing (no degenerate zero-width
/// pair that would produce a hard color edge), finite, and inside the inclusive
/// `0..1` normalized range — see the test suite for the enforced invariants.
///
/// Example:
/// ```dart
/// StopRange.easeInOut.stops; // [0.25, 0.75]
/// // Feed straight into any stops-accepting gradient API:
/// // LinearGradient(colors: [a, b], stops: StopRange.easeIn.stops);
/// ```
enum StopRange {
  /// Front-loaded transition: stops at `[0, 0.5]`.
  easeIn,

  /// Back-loaded transition: stops at `[0.5, 1]`.
  easeOut,

  /// Centered transition: stops at `[0.25, 0.75]`.
  easeInOut,

  /// Full-range, even transition: stops at `[0, 1]`.
  linear;

  /// The two normalized gradient stops (0..1) for this easing category.
  ///
  /// Returns a fresh two-element list on every call. A new literal is built
  /// each time rather than a cached shared instance so a caller that mutates
  /// the result (e.g. `..add(2)`) cannot corrupt the value seen by a later
  /// `.stops` read on the same variant — the values must stay constant.
  ///
  /// The `switch` is exhaustive over [StopRange], so adding a future variant
  /// without giving it stops is a compile-time error rather than a silent gap.
  ///
  /// Example:
  /// ```dart
  /// StopRange.easeIn.stops;    // [0, 0.5]
  /// StopRange.easeOut.stops;   // [0.5, 1]
  /// StopRange.easeInOut.stops; // [0.25, 0.75]
  /// StopRange.linear.stops;    // [0, 1]
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  List<double> get stops => switch (this) {
    StopRange.easeIn => <double>[0, 0.5],
    StopRange.easeOut => <double>[0.5, 1],
    StopRange.easeInOut => <double>[0.25, 0.75],
    StopRange.linear => <double>[0, 1],
  };
}
