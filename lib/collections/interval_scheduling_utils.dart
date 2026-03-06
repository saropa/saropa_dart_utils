/// Interval scheduling: max non-overlapping intervals (roadmap #445).
library;

import 'package:collection/collection.dart';

/// Interval with [start] and [end] (inclusive or exclusive per usage).
class Interval {
  const Interval(num start, num end) : _start = start, _end = end;
  final num _start;

  /// Start of the interval.
  num get start => _start;
  final num _end;

  /// End of the interval.
  num get end => _end;

  @override
  String toString() => 'Interval(start: $_start, end: $_end)';
}

/// Returns a maximal set of non-overlapping intervals from [intervals],
/// chosen by earliest end time (greedy).
///
/// See [Interval] for the interval type.
List<Interval> maxNonOverlappingIntervals(List<Interval> intervals) {
  if (intervals.isEmpty) return <Interval>[];
  final List<Interval> sorted = List<Interval>.of(intervals)
    ..sort((Interval a, Interval b) => a.end.compareTo(b.end));
  final Interval? firstInterval = sorted.firstOrNull;
  if (firstInterval == null) return <Interval>[];
  final List<Interval> out = <Interval>[firstInterval];
  for (int i = 1; i < sorted.length; i++) {
    final Interval lastInterval = out.lastOrNull ?? firstInterval;
    if (sorted[i].start >= lastInterval.end) out.add(sorted[i]);
  }
  return out;
}
