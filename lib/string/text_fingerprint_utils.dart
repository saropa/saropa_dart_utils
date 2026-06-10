/// Text fingerprinting (simhash-style) — roadmap #417.
library;

const int _kFingerprintPrime = 31;
const int _kMask32 = 0xFFFFFFFF;

/// Simple 32-bit fingerprint: hash of word shingles. [text] split on non-letters.
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
int fingerprintDistance(int a, int b) {
  int x = (a ^ b) & _kMask32;
  int n = 0;
  while (x != 0) {
    n += x & 1;
    x >>= 1;
  }
  return n;
}
