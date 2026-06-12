/// Time-bucketed aggregation — roadmap #468.
library;

/// Groups [events] (DateTime) into buckets of [bucketSize]; returns map of bucketStart -> count.
/// Audited: 2026-06-12 11:26 EDT
Map<DateTime, int> bucketByTime(List<DateTime> events, Duration bucketSize) {
  final int sizeMs = bucketSize.inMilliseconds;
  // A non-positive bucket width has no defined bucketing (and would divide by
  // zero); return empty rather than throwing or producing garbage buckets.
  if (sizeMs <= 0) return <DateTime, int>{};
  final Map<DateTime, int> out = <DateTime, int>{};
  for (final DateTime d in events) {
    final int ms = d.millisecondsSinceEpoch;
    // FLOOR the division, not truncate-toward-zero (`~/`): for pre-1970
    // (negative-epoch) timestamps, `~/` rounds toward zero and lands the point
    // in the next-higher bucket, so two points straddling the epoch collide.
    final int bucketMs = (ms / sizeMs).floor() * sizeMs;
    final DateTime key = DateTime.fromMillisecondsSinceEpoch(bucketMs);
    out[key] = (out[key] ?? 0) + 1;
  }
  return out;
}
