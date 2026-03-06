/// Bloom filter with tunable false positive rate — roadmap #455.
library;

/// Simple Bloom filter: add elements, test membership (may have false positives).
class BloomFilter {
  BloomFilter({required int expectedCount, double falsePositiveRate = 0.01})
    : _expectedCount = expectedCount,
      _falsePositiveRate = falsePositiveRate,
      _bits = List<bool>.filled(_sizeBits(expectedCount, falsePositiveRate), false),
      _hashCount = _optimalHashCount(expectedCount, _sizeBits(expectedCount, falsePositiveRate));

  final int _expectedCount;

  /// Expected number of elements (used for sizing).
  int get expectedCount => _expectedCount;
  final double _falsePositiveRate;

  /// Target false positive rate (e.g. 0.01 for 1%).
  double get falsePositiveRate => _falsePositiveRate;
  final List<bool> _bits;
  final int _hashCount;

  static int _sizeBits(int n, double p) {
    if (n <= 0 || p <= 0) return 64;
    const double ln2 = 0.69314718056;
    const double ln2Sq = 0.4804530139182014; // ln2 * ln2
    final double logReciprocalP = _ln(1 / p);
    return (n * ln2 * logReciprocalP / ln2Sq).ceil().clamp(64, 0x7fffffff);
  }

  static int _optimalHashCount(int n, int m) =>
      (n <= 0 ? 1 : (m / n * 0.69314718056).round().clamp(1, 32));

  static double _ln(double x) {
    if (x <= 0) return 0;
    double r = 0;
    double val = x;
    while (val > 1) {
      val /= 2.718281828459045;
      r += 1;
    }
    return r + (val - 1) / val;
  }

  /// Adds [element] to the filter (idempotent).
  void add(Object element) {
    final int h = element.hashCode;
    for (int i = 0; i < _hashCount; i++) {
      final int idx = (_mix(h + i * 31) % _bits.length).abs();
      _bits[idx] = true;
    }
  }

  /// True if [element] might have been added (may have false positives).
  bool mightContain(Object element) {
    final int h = element.hashCode;
    for (int i = 0; i < _hashCount; i++) {
      final int idx = (_mix(h + i * 31) % _bits.length).abs();
      if (!_bits[idx]) return false;
    }
    return true;
  }

  static int _mix(int h) {
    int v = h;
    v ^= v >>> 16;
    v *= 0x85ebca6b;
    v ^= v >>> 13;
    v *= 0xc2b2ae35;
    v ^= v >>> 16;
    return v;
  }

  @override
  String toString() =>
      'BloomFilter(expectedCount: $_expectedCount, falsePositiveRate: $_falsePositiveRate, bits: ${_bits.length})';
}
