/// Bucketed aggregation (sum/count/avg/min/max per bucket) — roadmap #570.
library;

/// Bucket key and list of values.
typedef BucketedValues<K> = Map<K, List<num>>;

/// Groups [values] by [keyOf](index, value), then returns map of key -> list of values.
Map<K, List<num>> bucketBy<K>(List<num> values, K Function(int index, num value) keyOf) {
  final Map<K, List<num>> out = <K, List<num>>{};
  for (int i = 0; i < values.length; i++) {
    final K k = keyOf(i, values[i]);
    out.putIfAbsent(k, () => []).add(values[i]);
  }
  return out;
}

const String _kAggSum = 'sum';
const String _kAggCount = 'count';
const String _kAggAvg = 'avg';
const String _kAggMin = 'min';
const String _kAggMax = 'max';

/// For each bucket, compute [aggregate] (sum, count, avg, min, max).
double bucketAggregate(List<num> bucket, String aggregate) {
  // NaN signals "no value" for an empty bucket — avg would divide by zero and
  // min/max have no defined element, so every branch below assumes non-empty.
  if (bucket.isEmpty) return double.nan;
  switch (aggregate) {
    case _kAggSum:
      return bucket.fold<double>(0, (s, x) => s + x.toDouble());
    case _kAggCount:
      return bucket.length.toDouble();
    case _kAggAvg:
      return bucket.fold<double>(0, (s, x) => s + x.toDouble()) / bucket.length;
    case _kAggMin:
      // Seed with +infinity so the first real element always wins the min fold.
      return bucket
          .map((num x) => x.toDouble())
          .fold<double>(double.infinity, (a, b) => a < b ? a : b);
    case _kAggMax:
      // Seed with -infinity so the first real element always wins the max fold.
      return bucket
          .map((num x) => x.toDouble())
          .fold<double>(double.negativeInfinity, (a, b) => a > b ? a : b);
    default:
      // Unknown aggregate name — NaN rather than a silent wrong number.
      return double.nan;
  }
}
