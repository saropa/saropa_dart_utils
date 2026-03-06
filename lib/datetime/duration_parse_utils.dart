/// Parses duration string like "1.5h", "90m", "2d 3h 30m".
///
/// Supports: d, h, m, s, ms. Returns null if invalid.
Duration? parseDuration(String input) {
  final String s = input.trim().toLowerCase();
  if (s.isEmpty) return null;
  final RegExp part = RegExp(r'([\d.]+)\s*([dhms]|ms)\b');
  int totalMs = 0;
  int start = 0;
  for (final RegExpMatch m in part.allMatches(s)) {
    if (m.start != start) return null;
    start = m.end;
    final g1 = m.group(1);
    if (g1 == null) return null;
    final double? val = double.tryParse(g1);
    if (val == null || val < 0) return null;
    switch (m.group(2)) {
      case 'd':
        totalMs += (val * 24 * 60 * 60 * 1000).round();
        break;
      case 'h':
        totalMs += (val * 60 * 60 * 1000).round();
        break;
      case 'm':
        totalMs += (val * 60 * 1000).round();
        break;
      case 's':
        totalMs += (val * 1000).round();
        break;
      case 'ms':
        totalMs += val.round();
        break;
      default:
        return null;
    }
  }
  if (start != s.length) return null;
  return Duration(milliseconds: totalMs);
}
