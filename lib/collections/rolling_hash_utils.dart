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
  final int patternHash = rollingHash(pattern, 0, pattern.length);
  int textHash = rollingHash(text, 0, pattern.length);
  int pow = 1;
  for (int i = 0; i < pattern.length - 1; i++) pow = (pow * _base) % _mod;
  for (int i = 0; i <= text.length - pattern.length; i++) {
    final int end = i + pattern.length;
    if (end <= text.length &&
        textHash == patternHash &&
        String.fromCharCodes(text.codeUnits.sublist(i, end)) == pattern)
      return i;
    if (i + pattern.length < text.length) {
      textHash = (textHash - text.codeUnitAt(i) * pow % _mod + _mod) % _mod;
      textHash = (textHash * _base + text.codeUnitAt(i + pattern.length)) % _mod;
    }
  }
  return -1;
}
