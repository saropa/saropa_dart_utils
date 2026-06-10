/// Rolling hash (Rabin–Karp style) for substring search — roadmap #482.
library;

const int _base = 31;
const int _mod = 1000000007;

/// Polynomial rolling hash of [s] in range [start, end).
int rollingHash(String s, int start, int end) {
  int h = 0;
  for (int i = start; i < end && i < s.length; i++) {
    h = (h * _base + s.codeUnitAt(i)) % _mod;
  }
  return h;
}

/// Returns index of [pattern] in [text] using rolling hash, or -1.
int rollingHashSearch(String text, String pattern) {
  if (pattern.isEmpty) return 0;
  if (pattern.length > text.length) return -1;
  // Rabin-Karp: compare a cheap rolling hash of each text window against the
  // pattern's hash, and only do a full char compare on a hash hit (guarding
  // against hash collisions). This makes the common non-match case O(1) per
  // window instead of O(pattern length).
  final int patternHash = rollingHash(pattern, 0, pattern.length);
  int textHash = rollingHash(text, 0, pattern.length);
  // Precompute base^(len-1): the weight of the leftmost char, needed to remove
  // it when sliding the window one position right.
  int pow = 1;
  for (int i = 0; i < pattern.length - 1; i++) {
    pow = (pow * _base) % _mod;
  }
  for (int i = 0; i <= text.length - pattern.length; i++) {
    final int end = i + pattern.length;
    // Hash match is necessary but not sufficient — confirm with a real compare.
    if (end <= text.length &&
        textHash == patternHash &&
        String.fromCharCodes(text.codeUnits.sublist(i, end)) == pattern) {
      return i;
    }
    // Slide the window: drop the leftmost char's contribution, shift, and add
    // the new rightmost char (all mod _mod to bound the integer).
    if (i + pattern.length < text.length) {
      // ignore: saropa_lints/avoid_string_concatenation_loop -- integer rolling-hash arithmetic, not string concatenation
      textHash = (textHash - text.codeUnitAt(i) * pow % _mod + _mod) % _mod;
      // ignore: saropa_lints/avoid_string_concatenation_loop -- integer rolling-hash arithmetic, not string concatenation
      textHash = (textHash * _base + text.codeUnitAt(i + pattern.length)) % _mod;
    }
  }
  return -1;
}
