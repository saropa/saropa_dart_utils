/// Canonicalization (sort keys, normalize) for JSON-like data — roadmap #639.
library;

/// Recursively sorts map keys and normalizes numbers. Returns new structure.
Object? canonicalizeJson(Object? value) {
  if (value == null) return null;
  if (value is Map) {
    final Map<String, Object?> out = <String, Object?>{};
    final List<String> keys = value.keys.map((k) => k.toString()).toList()..sort();
    for (final k in keys) {
      out[k] = canonicalizeJson(value[k]);
    }
    return out;
  }
  if (value is List) return value.map(canonicalizeJson).toList();
  if (value is num) return value is int ? value : value.toDouble();
  return value;
}
