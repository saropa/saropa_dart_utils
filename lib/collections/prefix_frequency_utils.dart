/// Prefix frequency table (for autocomplete) — roadmap #481.
library;

/// Builds map: prefix -> count of strings having that prefix. [maxPrefixLen] limits key length.
Map<String, int> prefixFrequencyTable(List<String> strings, {int maxPrefixLen = 20}) {
  final Map<String, int> out = <String, int>{};
  // Each string contributes one count to every one of its prefixes (lengths
  // 1..len). maxPrefixLen caps len so a single very long string cannot explode
  // the key set — the table size is bounded by maxPrefixLen per input, not by
  // the longest string's length.
  for (final String s in strings) {
    final int len = s.length < maxPrefixLen ? s.length : maxPrefixLen;
    for (int i = 1; i <= len; i++) {
      // Slice on code units rather than substring so the prefix length is
      // measured consistently with `len` (both count UTF-16 units); a count
      // beyond the string's own length is skipped to stay in bounds.
      if (i > s.length) continue;
      final String p = String.fromCharCodes(s.codeUnits.sublist(0, i));
      out[p] = (out[p] ?? 0) + 1;
    }
  }
  return out;
}
