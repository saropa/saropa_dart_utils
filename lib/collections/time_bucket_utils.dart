/// Time-bucketed aggregation — roadmap #468.
library;

/// Groups [events] (DateTime) into buckets of [bucketSize]; returns map of bucketStart -> count.
Map<DateTime, int> bucketByTime(List<DateTime> events, Duration bucketSize) {
  final Map<DateTime, int> out = <DateTime, int>{};
  for (final DateTime d in events) {
    final int ms = d.millisecondsSinceEpoch;
    final int bucketMs = (ms ~/ bucketSize.inMilliseconds) * bucketSize.inMilliseconds;
    final DateTime key = DateTime.fromMillisecondsSinceEpoch(bucketMs);
    out[key] = (out[key] ?? 0) + 1;
  }
  return out;
}
