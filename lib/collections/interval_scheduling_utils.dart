/// Interval scheduling: max non-overlapping intervals (roadmap #445).
library;

import 'package:collection/collection.dart';

/// Interval with [start] and [end] (inclusive or exclusive per usage).
class IntervalSchedulingUtils {
  const IntervalSchedulingUtils(num start, num end) : _start = start, _end = end;
  final num _start;

  /// Start of the interval.
  num get start => _start;
  final num _end;

  /// End of the interval.
  num get end => _end;

  @override
  String toString() => 'IntervalSchedulingUtils(start: $_start, end: $_end)';
}

/// Returns a maximal set of non-overlapping intervals from [intervals],
/// chosen by earliest end time (greedy).
///
/// See [IntervalSchedulingUtils] for the interval type.
List<IntervalSchedulingUtils> maxNonOverlappingIntervals(List<IntervalSchedulingUtils> intervals) {
  if (intervals.isEmpty) return <IntervalSchedulingUtils>[];
  final List<IntervalSchedulingUtils> sorted = List<IntervalSchedulingUtils>.of(intervals)
    ..sort((IntervalSchedulingUtils a, IntervalSchedulingUtils b) => a.end.compareTo(b.end));
  final IntervalSchedulingUtils? firstInterval = sorted.firstOrNull;
  if (firstInterval == null) return <IntervalSchedulingUtils>[];
  final List<IntervalSchedulingUtils> out = <IntervalSchedulingUtils>[firstInterval];
  for (int i = 1; i < sorted.length; i++) {
    final IntervalSchedulingUtils lastInterval = out.lastOrNull ?? firstInterval;
    if (sorted[i].start >= lastInterval.end) out.add(sorted[i]);
  }
  return out;
}
