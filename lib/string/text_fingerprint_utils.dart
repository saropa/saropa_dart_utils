/// Text fingerprinting (order-sensitive word-hash) — roadmap #417.
///
/// NOTE: this is NOT a simhash. It XORs each word's full hash (mixed with its
/// position) into a single value, which is good for an equality/identity
/// fingerprint but is NOT locality-preserving — a single word change flips many
/// bits, so [fingerprintDistance] (a Hamming bit-count) is NOT a similarity
/// measure. Use it for "are these two texts identical?", not "how similar?".
/// The per-word hash is Dart's `String.hashCode`, which is deterministic within
/// a run but not guaranteed stable across Dart versions/platforms; do not
/// persist fingerprints for long-term cross-build comparison.
library;

const int _kFingerprintPrime = 31;
const int _kMask32 = 0xFFFFFFFF;

/// Simple 32-bit fingerprint: hash of word shingles. [text] split on non-letters.
/// Audited: 2026-06-12 11:26 EDT
int textFingerprint(String text) {
  // Lowercase and split on any non-alphanumeric run so punctuation/casing do not
  // change the fingerprint; drop one-character tokens, which are mostly noise and
  // dilute the signal.
  final List<String> words = text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((s) => s.length > 1)
      .toList();
  if (words.isEmpty) return 0;
  // Fold each word's hash into the fingerprint, mixing in its position
  // (index * prime) so that the same words in a different order produce a
  // different fingerprint — the fingerprint is order-sensitive by design.
  int fp = 0;
  for (final MapEntry<int, String> entry in words.asMap().entries) {
    fp ^= (entry.value.hashCode + entry.key * _kFingerprintPrime);
  }
  return fp;
}

/// Hamming distance between two 32-bit fingerprints (number of differing bits).
/// Audited: 2026-06-12 11:26 EDT
int fingerprintDistance(int a, int b) {
  int x = (a ^ b) & _kMask32;
  int n = 0;
  while (x != 0) {
    n += x & 1;
    x >>= 1;
  }
  return n;
}
