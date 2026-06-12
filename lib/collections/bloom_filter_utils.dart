/// Bloom filter with tunable false positive rate — roadmap #455.
library;

import 'dart:math' show log;

/// Simple Bloom filter: add elements, test membership (may have false positives).
class BloomFilterUtils {
  /// Creates a filter sized for [expectedCount] elements at the target
  /// [falsePositiveRate] (default 1%). The bit array length and hash count are
  /// derived from these to minimize false positives at the expected load.
  /// Audited: 2026-06-12 11:26 EDT
  BloomFilterUtils({required int expectedCount, double falsePositiveRate = 0.01})
    : _expectedCount = expectedCount,
      _falsePositiveRate = falsePositiveRate,
      _bits = List<bool>.filled(_sizeBits(expectedCount, falsePositiveRate), false),
      _hashCount = _optimalHashCount(expectedCount, _sizeBits(expectedCount, falsePositiveRate));

  final int _expectedCount;

  /// Expected number of elements (used for sizing).
  /// Audited: 2026-06-12 11:26 EDT
  int get expectedCount => _expectedCount;
  final double _falsePositiveRate;

  /// Target false positive rate (e.g. 0.01 for 1%).
  /// Audited: 2026-06-12 11:26 EDT
  double get falsePositiveRate => _falsePositiveRate;
  final List<bool> _bits;
  final int _hashCount;

  static int _sizeBits(int n, double p) {
    if (n <= 0 || p <= 0) return 64;
    const double ln2 = 0.69314718056;
    const double ln2Sq = 0.4804530139182014; // ln2 * ln2
    // Optimal Bloom size m = -n*ln(p)/ln(2)^2. Use dart:math `log` (natural log)
    // for an accurate ln; a hand-rolled approximation here mis-sized the filter.
    final double logReciprocalP = log(1 / p);
    return (n * ln2 * logReciprocalP / ln2Sq).ceil().clamp(64, 0x7fffffff);
  }

  static int _optimalHashCount(int n, int m) =>
      (n <= 0 ? 1 : (m / n * 0.69314718056).round().clamp(1, 32));

  /// Adds [element] to the filter (idempotent).
  /// Audited: 2026-06-12 11:26 EDT
  void add(Object element) {
    final int h = element.hashCode;
    for (int i = 0; i < _hashCount; i++) {
      final int idx = (_mix(h + i * 31) % _bits.length).abs();
      _bits[idx] = true;
    }
  }

  /// True if [element] might have been added (may have false positives).
  /// Audited: 2026-06-12 11:26 EDT
  bool mightContain(Object element) {
    final int h = element.hashCode;
    for (int i = 0; i < _hashCount; i++) {
      final int idx = (_mix(h + i * 31) % _bits.length).abs();
      if (!_bits[idx]) return false;
    }
    return true;
  }

  static int _mix(int h) {
    final v0 = h ^ (h >>> 16);
    final v1 = v0 * 0x85ebca6b;
    final v2 = v1 ^ (v1 >>> 13);
    final v3 = v2 * 0xc2b2ae35;
    return v3 ^ (v3 >>> 16);
  }

  @override
  String toString() =>
      'BloomFilterUtils(expectedCount: $_expectedCount, falsePositiveRate: $_falsePositiveRate, bits: ${_bits.length})';
}
