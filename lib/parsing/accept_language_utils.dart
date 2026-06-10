/// Parse an HTTP `Accept-Language` header into ranked language ranges.
/// Roadmap #159.
///
/// Turns `en-US,en;q=0.9,fr;q=0.8` into an ordered list a server can match
/// against its supported locales. Ranges with `q=0` ("not acceptable" per
/// RFC 7231) are dropped, and the rest are sorted by quality descending,
/// preserving header order on ties (a stable sort, matching how clients expect
/// equal-weight preferences to be honored left-to-right).
library;

/// A single weighted language range from an `Accept-Language` header.
class LanguageRange {
  const LanguageRange(this.tag, this.quality);

  /// The language tag, lower-cased (e.g. `en-us`, `fr`, or `*`).
  final String tag;

  /// The quality weight in 0.0..1.0 (absent `q=` defaults to 1.0).
  final double quality;

  @override
  String toString() => 'LanguageRange($tag, q=$quality)';
}

/// Parses [header] into language ranges ordered most-preferred first.
///
/// Returns an empty list for an empty/whitespace header. Malformed entries
/// (empty tag, unparseable or out-of-range `q`) are skipped rather than
/// failing the whole header, since a single bad client value should not deny
/// content negotiation.
///
/// Example:
/// ```dart
/// parseAcceptLanguage('en-US,en;q=0.9,fr;q=0.8')
///   .map((r) => r.tag); // ('en-us', 'en', 'fr')
/// ```
List<LanguageRange> parseAcceptLanguage(String header) {
  final List<LanguageRange> ranges = <LanguageRange>[];
  if (header.trim().isEmpty) {
    return ranges;
  }

  for (final String raw in header.split(',')) {
    final LanguageRange? range = _parseEntry(raw);
    // Drop unparseable entries and explicit q=0 (not acceptable).
    if (range != null && range.quality > 0) {
      ranges.add(range);
    }
  }

  // Stable sort by quality descending: equal-weight tags keep header order,
  // which is the documented tie-break clients rely on.
  final List<int> order = List<int>.generate(ranges.length, (int i) => i);
  order.sort((int i, int j) {
    final int byQuality = ranges[j].quality.compareTo(ranges[i].quality);
    return byQuality != 0 ? byQuality : i.compareTo(j);
  });
  return <LanguageRange>[for (final int i in order) ranges[i]];
}

/// Parses one `tag` or `tag;q=0.5` entry, or `null` if malformed.
LanguageRange? _parseEntry(String raw) {
  final List<String> parts = raw.split(';');
  final String tag = parts[0].trim().toLowerCase();
  if (tag.isEmpty) {
    return null;
  }

  double quality = 1;
  for (int i = 1; i < parts.length; i++) {
    final String param = parts[i].trim();
    if (!param.startsWith('q=')) {
      continue;
    }
    // The q-prefix check above guarantees this token is at least two
    // characters long, so dropping the first two is always within range and
    // yields an empty remainder at worst, which the parse below rejects.
    // ignore: avoid_string_substring -- start index provably within length
    final double? q = double.tryParse(param.substring(2).trim());
    if (q == null || q < 0 || q > 1) {
      return null;
    }
    quality = q;
  }
  return LanguageRange(tag, quality);
}
