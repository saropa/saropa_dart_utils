/// Parse compact number ("1.2K" → 1200). Roadmap #121.
/// Audited: 2026-06-12 11:26 EDT
double? parseCompactNumber(String input) {
  final String s = input.trim().toUpperCase().replaceAll(' ', '');
  if (s.isEmpty) return null;
  final RegExp re = RegExp(r'^([+-]?\d+(?:\.\d+)?)\s*([KMBT]?)$', caseSensitive: false);
  final RegExpMatch? m = re.firstMatch(s);
  if (m == null) return null;
  final g1 = m.group(1);
  if (g1 == null) return null;
  final double? value = double.tryParse(g1);
  if (value == null) return null;
  final String suffix = m.group(2) ?? '';
  // Decimal (1000-based) scale for human counts: 1K = 1000, not 1024. This is
  // deliberately distinct from byte-size parsing, which uses 1024-based factors.
  const Map<String, double> multipliers = <String, double>{
    '': 1,
    'K': 1e3,
    'M': 1e6,
    'B': 1e9,
    'T': 1e12,
  };
  final double? mult = multipliers[suffix];
  if (mult == null) return null;
  return value * mult;
}
