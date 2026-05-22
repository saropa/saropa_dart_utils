/// Canonicalization (sort keys, normalize) for JSON-like data — roadmap #639.
library;

/// Recursively sorts map keys and normalizes numbers. Returns new structure.
///
/// Recurses to the value's nesting depth; not intended for untrusted,
/// arbitrarily-deep input (deep nesting can exhaust the stack).
Object? canonicalizeJson(Object? value) {
  if (value == null) return null;
  if (value is Map) {
    final Map<String, Object?> out = <String, Object?>{};
    // ignore: saropa_lints/avoid_large_list_copy -- needs an independent copy to sort the keys in place before iterating
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
