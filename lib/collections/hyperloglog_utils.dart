/// HyperLogLog-lite approximate distinct count — roadmap #454.
library;

import 'dart:math' as math;

/// Lowest precision: 2^4 = 16 registers (least memory, roughest estimate).
const int _kMinPrecision = 4;

/// Highest precision: 2^16 = 65536 registers (caps memory at a sane bound).
const int _kMaxPrecision = 16;

/// Mask for one 32-bit limb of the web-safe 64-bit hash arithmetic.
const int _mask32 = 0xFFFFFFFF;

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
/// Web-safe: the 64-bit hash mixing, register-index/rank extraction, and the
/// `2^-rank` term are all computed in 32-bit limbs (see [_mix64]), so estimates
/// are the same on the VM and on the web. A naive native `int` version would
/// overflow the web's 53-bit-double `int` (and truncate shifts to 32 bits),
/// collapsing the estimate; this implementation avoids that. See
/// https://dart.dev/resources/language/number-representation.
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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  int get registerCount => _registers.length;

  /// Folds [element] into the sketch (idempotent for equal elements).
  /// Audited: 2026-06-12 11:26 EDT
  void add(Object? element) {
    // Top `precision` bits pick the register; the remaining bits' leading-zero
    // run (rank) is what HyperLogLog records — a long run is rare and signals
    // many distinct elements landed in that bucket. The 64-bit hash is held as
    // two 32-bit limbs so the mixing and bit extraction are identical on the VM
    // and the web (a native 64-bit `<<`/`*` would truncate to 32 bits on web).
    final (int hashHi, int hashLo) = _mix64(element.hashCode);
    // precision <= 16, so the top `precision` index bits live entirely in the
    // high limb.
    final int index = hashHi >>> (32 - precision);
    final int rank = _rank64(hashHi, hashLo, precision);
    if (rank > _registers[index]) _registers[index] = rank;
  }

  /// Approximate count of distinct elements added so far (0 for empty).
  /// Audited: 2026-06-12 11:26 EDT
  int cardinality() {
    final int m = _registers.length;
    double sum = 0;
    int zeros = 0;
    // Harmonic mean of 2^-register is the core HLL estimator; also tally empty
    // registers so the small-range branch can use linear counting instead.
    for (final int r in _registers) {
      // 2^-r. The integer shift is exact and web-safe for realistic ranks; the
      // pow fallback covers the astronomically rare r > 30, where `1 << r` would
      // overflow the web's 32-bit shift and corrupt the sum.
      sum += r <= 30 ? 1.0 / (1 << r) : math.pow(2, -r).toDouble();
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
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  static double _corrected(double raw, int m, int zeros) {
    const double smallRangeFactor = 2.5;
    if (raw <= smallRangeFactor * m && zeros > 0) {
      return m * math.log(m / zeros);
    }
    return raw;
  }

  /// Bias-correction constant alpha_m for the harmonic-mean estimator; the
  /// `< 128` cases are the published HLL constants, the rest is the limit form.
  /// Audited: 2026-06-12 11:26 EDT
  static double _alpha(int m) {
    if (m >= 128) return 0.7213 / (1 + 1.079 / m);
    if (m >= 64) return 0.709;
    if (m >= 32) return 0.697;
    return 0.673;
  }

  /// Rank: 1-based position of the first set bit in the `64 - precision` bits
  /// below the register-index bits of the 64-bit hash held as [hi]:[lo]; a fully
  /// zero window yields `width + 1`. Reads bits straight from the two 32-bit
  /// limbs so it never relies on a 64-bit shift the web cannot perform.
  /// Audited: 2026-06-12 11:26 EDT
  static int _rank64(int hi, int lo, int precision) {
    final int width = 64 - precision;
    for (int i = 0; i < width; i++) {
      // Bit (63 - precision - i) of the 64-bit value, scanned MSB-first within
      // the window; pos >= 32 reads the high limb, else the low limb.
      final int pos = 63 - precision - i;
      final int bit = pos >= 32 ? (hi >>> (pos - 32)) & 1 : (lo >>> pos) & 1;
      if (bit == 1) return i + 1;
    }
    return width + 1;
  }

  /// Avalanche-mixes a 32-ish-bit [Object.hashCode] into a 64-bit value (returned
  /// as `(hi, lo)` 32-bit limbs) so the top bits (register index) and low bits
  /// (rank) are both well distributed. This is the splitmix64 finalizer computed
  /// in 32-bit limbs: on the VM it reproduces the old native-int value exactly,
  /// and on the web it now yields that same value instead of a 32-bit-truncated
  /// one. See https://dart.dev/resources/language/number-representation.
  /// Audited: 2026-06-12 11:26 EDT
  static (int, int) _mix64(int h) {
    final (int aHi, int aLo) = _xorShr(0, h & _mask32, 30);
    final (int bHi, int bLo) = _mulMod64(aHi, aLo, 0xbf58476d, 0x1ce4e5b9);
    final (int cHi, int cLo) = _xorShr(bHi, bLo, 27);
    final (int dHi, int dLo) = _mulMod64(cHi, cLo, 0x94d049bb, 0x133111eb);
    return _xorShr(dHi, dLo, 31);
  }

  /// `(hi:lo) ^ ((hi:lo) >>> n)` for `0 < n < 32`, in 32-bit limbs.
  static (int, int) _xorShr(int hi, int lo, int n) {
    final int sHi = (hi >>> n) & _mask32;
    final int sLo = ((lo >>> n) | (hi << (32 - n))) & _mask32;
    return ((hi ^ sHi) & _mask32, (lo ^ sLo) & _mask32);
  }

  /// 64-bit product reduced mod 2^64 as `(hi, lo)` limbs. (An identical private
  /// helper lives in `parsing/stable_hash_utils.dart`; kept duplicated per file
  /// rather than promoted to a shared public primitive for just two call sites.)
  static (int, int) _mulMod64(int aHi, int aLo, int bHi, int bLo) {
    final (int llHi, int llLo) = _mul3232(aLo, bLo);
    final int cross = (_mul3232(aLo, bHi).$2 + _mul3232(aHi, bLo).$2) & _mask32;
    return ((llHi + cross) & _mask32, llLo);
  }

  /// 64-bit product of two 32-bit values as `(hi, lo)` limbs; 16-bit splitting
  /// keeps every intermediate under 2^53 so it is exact on the web.
  static (int, int) _mul3232(int a, int b) {
    final int aLo = a & 0xFFFF;
    final int aHi = (a >>> 16) & 0xFFFF;
    final int bLo = b & 0xFFFF;
    final int bHi = (b >>> 16) & 0xFFFF;
    final int ll = aLo * bLo;
    final int lh = aLo * bHi;
    final int hl = aHi * bLo;
    final int hh = aHi * bHi;
    final int carry = (ll >>> 16) + (lh & 0xFFFF) + (hl & 0xFFFF);
    final int lo = ((ll & 0xFFFF) | ((carry & 0xFFFF) << 16)) & _mask32;
    final int hi = (hh + (lh >>> 16) + (hl >>> 16) + (carry >>> 16)) & _mask32;
    return (hi, lo);
  }

  @override
  String toString() => 'HyperLogLogUtils(precision: $precision, registers: $registerCount)';
}
