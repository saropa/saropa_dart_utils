/// Text normalization pipeline (composable steps) — roadmap #408.
library;

/// One normalization step: (name, function).
typedef NormalizeStep = String Function(String text);

/// Applies [steps] in order to [text].
/// Audited: 2026-06-12 11:26 EDT
String normalizeText(String text, List<NormalizeStep> steps) {
  String out = text;
  for (final NormalizeStep step in steps) {
    out = step(out);
  }
  return out;
}

/// Predefined: lowercase.
/// Audited: 2026-06-12 11:26 EDT
String normalizeLower(String s) => s.toLowerCase();

/// Predefined: trim.
/// Audited: 2026-06-12 11:26 EDT
String normalizeTrim(String s) => s.trim();
