/// Acronym/initialism extractor (e.g. "Saropa Dart Utils (SDU)") — roadmap #429.
library;

/// Extracts patterns like "Full Name (ABC)" -> (ABC, Full Name).
List<(String, String)> extractAcronyms(String text) {
  final List<(String, String)> out = [];
  final RegExp re = RegExp(r'([A-Za-z][A-Za-z\s]+)\s*\(([A-Z]{2,})\)');
  for (final Match m in re.allMatches(text)) {
    final String full = (m.group(1) ?? '').trim();
    final String acronym = m.group(2) ?? '';
    if (full.isNotEmpty && acronym.length >= 2) out.add((acronym, full));
  }
  return out;
}
