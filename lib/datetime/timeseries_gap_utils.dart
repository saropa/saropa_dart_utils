/// Gap detection and grid filling for roughly-regular time series — roadmap #606.
///
/// For a series of samples that SHOULD arrive at a fixed cadence (a sensor every
/// minute, a heartbeat every 30s), these helpers find where samples went
/// missing, reconstruct the ideal regular grid so callers can see which slots
/// were empty, and forward-fill a parallel value list across the holes.
///
/// Inputs are sorted defensively (the caller need not pre-sort). A "gap" is a
/// delta between consecutive samples larger than the expected interval by more
/// than [tolerance] (a fraction): with the default 0.5, a delta over 1.5x the
/// expected interval is a gap, absorbing normal jitter without false positives.
library;

import 'package:collection/collection.dart';

/// Gaps `[start, end]` (the inclusive bounding sample pair) where consecutive
/// [timestamps] are spaced more than `expectedInterval * (1 + tolerance)` apart.
///
/// [timestamps] is copied and sorted, so order in does not matter. [tolerance]
/// is a non-negative fraction of slack on top of the expected interval. With
/// fewer than two samples there are no pairs, so the result is empty.
///
/// Example:
/// ```dart
/// findGaps(
///   <DateTime>[DateTime(2026, 1, 1, 0), DateTime(2026, 1, 1, 3)],
///   const Duration(hours: 1),
/// ); // one gap from 00:00 to 03:00 (3h delta > 1.5h threshold)
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<({DateTime start, DateTime end})> findGaps(
  List<DateTime> timestamps,
  Duration expectedInterval, {
  double tolerance = 0.5,
}) {
  // Copy before sorting so the caller's list is never mutated as a side effect.
  final List<DateTime> sorted = List<DateTime>.of(timestamps)
    ..sort((DateTime a, DateTime b) => a.compareTo(b));

  // A delta beyond this many microseconds between neighbors is a gap; computing
  // it once in microseconds avoids per-pair Duration allocation.
  final int thresholdMicros = (expectedInterval.inMicroseconds * (1 + tolerance)).round();

  final List<({DateTime start, DateTime end})> gaps = <({DateTime start, DateTime end})>[];
  for (int i = 1; i < sorted.length; i++) {
    final DateTime prev = sorted[i - 1];
    final DateTime curr = sorted[i];
    if (curr.difference(prev).inMicroseconds > thresholdMicros) {
      gaps.add((start: prev, end: curr));
    }
  }
  return gaps;
}

/// The complete regular grid of timestamps from the earliest to the latest of
/// [timestamps], stepping by [interval]; callers compare it against the input to
/// see which slots were missing.
///
/// [timestamps] is copied and sorted first. With 0 or 1 samples there is nothing
/// to fill, so the input is returned sorted as-is. The last emitted grid point is
/// the final tick that does not pass the max timestamp.
///
/// Example:
/// ```dart
/// fillMissing(
///   <DateTime>[DateTime(2026, 1, 1, 0), DateTime(2026, 1, 1, 3)],
///   const Duration(hours: 1),
/// ); // [00:00, 01:00, 02:00, 03:00]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<DateTime> fillMissing(List<DateTime> timestamps, Duration interval) {
  // A non-positive interval would never advance `current` past `last`, so the
  // fill loop would spin forever and grow `grid` until OOM. There is no grid to
  // build without a positive step; return the input sorted as-is.
  if (interval <= Duration.zero) {
    return List<DateTime>.of(timestamps)..sort((DateTime a, DateTime b) => a.compareTo(b));
  }
  // Fewer than two points can't define a grid span; return them sorted as-is.
  if (timestamps.length < 2) {
    return List<DateTime>.of(timestamps)..sort((DateTime a, DateTime b) => a.compareTo(b));
  }
  final List<DateTime> sorted = List<DateTime>.of(timestamps)
    ..sort((DateTime a, DateTime b) => a.compareTo(b));

  // sorted has >= 2 entries (guarded above), so firstOrNull/lastOrNull are
  // non-null; the early return keeps flow analysis honest without an unsafe .first.
  final DateTime? first = sorted.firstOrNull;
  final DateTime? last = sorted.lastOrNull;
  if (first == null || last == null) {
    return sorted;
  }

  final List<DateTime> grid = <DateTime>[];
  DateTime current = first;
  // Emit every tick up to and including [last]; isAfter stops one past the end.
  while (!current.isAfter(last)) {
    grid.add(current);
    current = current.add(interval);
  }
  return grid;
}

/// A copy of [values] with each null replaced by the most recent non-null value
/// before it (last-observation-carried-forward). LEADING nulls have no prior
/// value and stay null.
///
/// Example:
/// ```dart
/// forwardFill(<num?>[null, 1, null, null, 3, null]);
/// // [null, 1, 1, 1, 3, 3]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<num?> forwardFill(List<num?> values) {
  final List<num?> filled = <num?>[];
  num? last;
  // Carry the last seen non-null forward; a null before any value stays null.
  for (final num? value in values) {
    if (value != null) {
      last = value;
    }
    filled.add(value ?? last);
  }
  return filled;
}
