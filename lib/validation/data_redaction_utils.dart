/// Data redaction policies (masking per field path) — roadmap #692.
library;

/// Maps a field [value] to its masked replacement (e.g. `(value) => '***'`).
typedef RedactMaskFn = String Function(Object? value);

/// Redacts [data] by applying [mask] to values at keys in [fieldPaths]. [mask] e.g. (value) => '***'.
/// Audited: 2026-06-12 11:26 EDT
Map<String, Object?> redactFields({
  required Map<String, Object?> data,
  required List<String> fieldPaths,
  required RedactMaskFn mask,
}) {
  final Map<String, Object?> out = Map<String, Object?>.from(data);
  for (final String path in fieldPaths) {
    if (out.containsKey(path)) out[path] = mask(out[path]);
  }
  return out;
}
