/// Prefix frequency table (for autocomplete) — roadmap #481.
library;

/// Builds map: prefix -> count of strings having that prefix. [maxPrefixLen] limits key length.
Map<String, int> prefixFrequencyTable(List<String> strings, {int maxPrefixLen = 20}) {
  final Map<String, int> out = <String, int>{};
  for (final String s in strings) {
    final int len = s.length < maxPrefixLen ? s.length : maxPrefixLen;
    for (int i = 1; i <= len; i++) {
      if (i > s.length) continue;
      final String p = String.fromCharCodes(s.codeUnits.sublist(0, i));
      out[p] = (out[p] ?? 0) + 1;
    }
  }
  return out;
}
