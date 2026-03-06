/// Text normalization pipeline (composable steps) — roadmap #408.
library;

/// One normalization step: (name, function).
typedef NormalizeStep = String Function(String text);

/// Applies [steps] in order to [text].
String normalizeText(String text, List<NormalizeStep> steps) {
  String out = text;
  for (final NormalizeStep step in steps) {
    out = step(out);
  }
  return out;
}

/// Predefined: lowercase.
String normalizeLower(String s) => s.toLowerCase();

/// Predefined: trim.
String normalizeTrim(String s) => s.trim();
