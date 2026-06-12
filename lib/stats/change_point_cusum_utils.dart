/// Two-sided CUSUM change-point detection (roadmap #568).
///
/// CUSUM (cumulative sum) accumulates deviations of each sample from a
/// reference level and flags a change when the running sum crosses a
/// threshold. It detects sustained shifts in the mean far earlier than
/// comparing raw values, because small persistent deviations add up.
library;

import 'dart:math' show max;

/// Detect indices where the series mean shifts, via a two-sided CUSUM scan.
///
/// Maintains two running sums against the overall series mean as the
/// reference level:
/// - [threshold] — the decision limit; a larger value needs a bigger or
///   longer-lasting shift before a change is reported, so it trades
///   sensitivity for fewer false alarms.
/// - [drift] — a slack (allowance) subtracted each step so ordinary noise
///   does not accumulate; only deviations beyond [drift] build the sums.
///
/// On each crossing the triggering index is recorded and both sums reset
/// to zero, so a long run can produce several change points.
///
/// Returns the detected indices in ascending order; empty when the series
/// is shorter than two samples (no mean shift is definable).
///
/// Example:
/// ```dart
/// // Step from 0 to 10 around the middle; the low run and the high run are
/// // both flagged relative to the series mean.
/// cusumChangePoints(<num>[0, 0, 0, 10, 10, 10], threshold: 5); // [1, 4]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> cusumChangePoints(
  List<num> series, {
  required double threshold,
  double drift = 0,
}) {
  // Fewer than two points has no definable mean shift to detect.
  if (series.length < 2) return <int>[];
  final double mean = _mean(series);
  final List<int> changePoints = <int>[];
  // sHigh tracks upward shifts, sLow tracks downward shifts; both are
  // clamped at zero so accumulation only ever moves toward the threshold.
  double sHigh = 0;
  double sLow = 0;
  for (int i = 0; i < series.length; i++) {
    final double deviation = series[i].toDouble() - mean;
    // Subtracting drift on the high side and adding it on the low side
    // means deviations within +/- drift cannot grow either sum.
    sHigh = max(0, sHigh + deviation - drift);
    sLow = max(0, sLow - deviation - drift);
    // A crossing on either side signals a shift; record and reset so the
    // next shift is detected independently rather than re-triggering.
    if (sHigh > threshold || sLow > threshold) {
      changePoints.add(i);
      sHigh = 0;
      sLow = 0;
    }
  }
  return changePoints;
}

/// Arithmetic mean of [values]; caller guarantees non-empty.
/// Audited: 2026-06-12 11:26 EDT
double _mean(List<num> values) {
  double sum = 0;
  for (int i = 0; i < values.length; i++) {
    sum += values[i].toDouble();
  }
  return sum / values.length;
}
