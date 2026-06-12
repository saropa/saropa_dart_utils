/// Time-series buffer that keeps recent raw points and down-samples old ones —
/// roadmap #510.
///
/// Dashboards and sparkline widgets want full resolution for the most recent
/// span but only summary statistics for older history, and they cannot grow
/// without bound. This buffer keeps the last [rawCapacity] points verbatim;
/// when a new point pushes an old one out, that evicted point is folded into a
/// fixed-width time bucket holding count / sum / min / max. The result is a
/// bounded structure that answers "exact recent values" and "aggregated older
/// trend" from the same feed.
///
/// Points must be added in non-decreasing timestamp order — the eviction logic
/// assumes the oldest raw point is always the front of the buffer.
library;

/// A down-sampled aggregate over one fixed-width time bucket.
class TimeBucket {
  TimeBucket._(this.startMs);

  /// Inclusive lower bound of the bucket's time span, in epoch milliseconds.
  final int startMs;

  int _count = 0;
  num _sum = 0;
  num _min = double.infinity;
  num _max = double.negativeInfinity;

  /// Number of points folded into this bucket.
  int get count => _count;

  /// Sum of folded values.
  num get sum => _sum;

  /// Smallest folded value.
  num get min => _min;

  /// Largest folded value.
  num get max => _max;

  /// Arithmetic mean of folded values, or `0` when the bucket is empty.
  double get mean => _count == 0 ? 0 : _sum / _count;

  void _add(num value) {
    _count++;
    _sum += value;
    if (value < _min) _min = value;
    if (value > _max) _max = value;
  }

  @override
  String toString() => 'TimeBucket(startMs: $startMs, count: $_count, mean: $mean)';
}

/// A single raw observation: a [t]imestamp (epoch ms) and a [v]alue.
typedef RawPoint = ({int t, num v});

/// A bounded time-series buffer mixing raw recent points and older aggregates.
class TimeSeriesBuffer {
  /// Keeps at most [rawCapacity] raw points; evicted points fold into buckets
  /// [bucketSizeMs] milliseconds wide. Both must be positive.
  TimeSeriesBuffer({required int rawCapacity, required int bucketSizeMs})
    : assert(rawCapacity > 0, 'rawCapacity ($rawCapacity) must be > 0'),
      assert(bucketSizeMs > 0, 'bucketSizeMs ($bucketSizeMs) must be > 0'),
      _rawCapacity = rawCapacity,
      _bucketSizeMs = bucketSizeMs;

  final int _rawCapacity;
  final int _bucketSizeMs;
  final List<RawPoint> _raw = <RawPoint>[];
  final Map<int, TimeBucket> _buckets = <int, TimeBucket>{};

  /// Adds a point at [timestampMs] with [value]; evicts and folds the oldest
  /// raw point if the raw window is now over capacity.
  ///
  /// Example:
  /// ```dart
  /// final TimeSeriesBuffer b = TimeSeriesBuffer(rawCapacity: 2, bucketSizeMs: 1000)
  ///   ..add(0, 10)
  ///   ..add(500, 20)
  ///   ..add(1500, 30); // (0,10) evicted into the [0,1000) bucket
  /// b.aggregates.first.mean; // 10
  /// ```
  void add(int timestampMs, num value) {
    _raw.add((t: timestampMs, v: value));
    if (_raw.length > _rawCapacity) _evictOldest();
  }

  void _evictOldest() {
    final RawPoint p = _raw.removeAt(0);
    final int start = (p.t ~/ _bucketSizeMs) * _bucketSizeMs;
    _buckets.putIfAbsent(start, () => TimeBucket._(start))._add(p.v);
  }

  /// The raw points still held, oldest first (an unmodifiable snapshot).
  List<RawPoint> get raw => List<RawPoint>.unmodifiable(_raw);

  /// The down-sampled buckets for evicted history, ordered by start time.
  List<TimeBucket> get aggregates => _buckets.values.toList()
    ..sort((TimeBucket a, TimeBucket b) => a.startMs.compareTo(b.startMs));

  @override
  String toString() =>
      'TimeSeriesBuffer(raw: ${_raw.length}/$_rawCapacity, buckets: ${_buckets.length})';
}
