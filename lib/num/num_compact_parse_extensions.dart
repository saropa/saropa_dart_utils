/// Parse compact number ("1.2K" → 1200). Roadmap #121.
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
