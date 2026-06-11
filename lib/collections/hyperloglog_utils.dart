/// HyperLogLog-lite approximate distinct count — roadmap #454.
library;

import 'dart:math' as math;

/// Lowest precision: 2^4 = 16 registers (least memory, roughest estimate).
const int _kMinPrecision = 4;

/// Highest precision: 2^16 = 65536 registers (caps memory at a sane bound).
const int _kMaxPrecision = 16;

/// HyperLogLog-lite cardinality sketch: [add] elements, read an approximate
/// distinct count from [cardinality].
///
/// Estimates the number of *distinct* elements seen using O(2^precision) memory
/// instead of storing every element — the trade-off is a small, bounded error
/// (roughly 1.04 / sqrt(registers)) in exchange for tiny fixed memory.
///
/// The hash source is Dart's [Object.hashCode] mixed into a 64-bit-ish value;
/// because `hashCode` is only 32-ish bits and per-isolate, estimates are
/// approximate and not stable across runs/isolates. Treat the result as a
/// statistical estimate, never an exact count.
///
/// Example:
/// ```dart
/// final hll = HyperLogLogUtils(precision: 12);
/// for (var i = 0; i < 1000; i++) {
///   hll.add('user_$i');
/// }
/// hll.cardinality(); // ~1000 (within a few percent)
/// ```
class HyperLogLogUtils {
  /// Creates an empty sketch with `2^precision` registers.
  ///
  /// [precision] must be in `[4, 16]`; higher precision means more registers,
  /// more memory, and a tighter estimate. Out-of-range values throw because a
  /// silent clamp would hide a sizing mistake.
  HyperLogLogUtils({this.precision = 12})
    : _registers = List<int>.filled(_validatedRegisterCount(precision), 0);

  /// Number of register-index bits; register count is `2^precision`.
  final int precision;

  /// Leading-zero registers; each holds the max `rank` seen for its bucket.
  final List<int> _registers;

  static int _validatedRegisterCount(int precision) {
    // Reject early: an invalid precision otherwise produces a nonsense-sized
    // (or zero-length) register array that fails far from the real cause.
    if (precision < _kMinPrecision || precision > _kMaxPrecision) {
      throw ArgumentError.value(
        precision,
        'precision',
        'must be in [$_kMinPrecision, $_kMaxPrecision]',
      );
    }
    return 1 << precision;
  }

  /// Number of registers (`2^precision`).
  int get registerCount => _registers.length;

  /// Folds [element] into the sketch (idempotent for equal elements).
  void add(Object? element) {
    // Top `precision` bits pick the register; the remaining bits' leading-zero
    // run (rank) is what HyperLogLog records — a long run is rare and signals
    // many distinct elements landed in that bucket.
    final int hash = _hash64(element.hashCode);
    final int index = hash >>> (64 - precision);
    final int rank = _rank(hash << precision, 64 - precision);
    if (rank > _registers[index]) _registers[index] = rank;
  }

  /// Approximate count of distinct elements added so far (0 for empty).
  int cardinality() {
    final int m = _registers.length;
    double sum = 0;
    int zeros = 0;
    // Harmonic mean of 2^-register is the core HLL estimator; also tally empty
    // registers so the small-range branch can use linear counting instead.
    for (final int r in _registers) {
      sum += 1.0 / (1 << r);
      if (r == 0) zeros++;
    }
    final double raw = _alpha(m) * m * m / sum;
    return _corrected(raw, m, zeros).round();
  }

  /// Merges [other] into a new sketch (both must share this [precision]).
  ///
  /// Register-wise max is the exact merge rule for HLL: the union's rank in a
  /// bucket is whichever sketch saw the longer leading-zero run there, so
  /// merging never loses information. Differing precision throws.
  HyperLogLogUtils merge(HyperLogLogUtils other) {
    if (other.precision != precision) {
      throw ArgumentError.value(
        other.precision,
        'other.precision',
        'must equal this.precision ($precision)',
      );
    }
    final HyperLogLogUtils out = HyperLogLogUtils(precision: precision);
    for (int i = 0; i < _registers.length; i++) {
      out._registers[i] = math.max(_registers[i], other._registers[i]);
    }
    return out;
  }

  /// Small-range correction: when many registers are still empty the harmonic
  /// estimator is biased, so linear counting (`m * ln(m / zeros)`) is far more
  /// accurate near zero. Above the threshold the raw HLL estimate stands.
  static double _corrected(double raw, int m, int zeros) {
    const double smallRangeFactor = 2.5;
    if (raw <= smallRangeFactor * m && zeros > 0) {
      return m * math.log(m / zeros);
    }
    return raw;
  }

  /// Bias-correction constant alpha_m for the harmonic-mean estimator; the
  /// `< 128` cases are the published HLL constants, the rest is the limit form.
  static double _alpha(int m) {
    if (m >= 128) return 0.7213 / (1 + 1.079 / m);
    if (m >= 64) return 0.709;
    if (m >= 32) return 0.697;
    return 0.673;
  }

  /// Position of the first set bit (1-based) scanning from the most significant
  /// of [width] bits; all-zero (within the window) yields `width + 1`.
  static int _rank(int bits, int width) {
    for (int i = 0; i < width; i++) {
      if ((bits >>> (63 - i)) & 1 == 1) return i + 1;
    }
    return width + 1;
  }

  /// Avalanche-mixes a 32-ish-bit [Object.hashCode] into a 64-bit value so the
  /// top bits (register index) and low bits (rank) are both well distributed.
  static int _hash64(int h) {
    int x = h & 0xFFFFFFFF;
    x = (x ^ (x >>> 30)) * 0xbf58476d1ce4e5b9;
    x = (x ^ (x >>> 27)) * 0x94d049bb133111eb;
    return x ^ (x >>> 31);
  }

  @override
  String toString() => 'HyperLogLogUtils(precision: $precision, registers: $registerCount)';
}
