/// Config precedence resolver: defaults → overlay (roadmap #644).
library;

/// Merges [defaults] with [overlay]; overlay wins for non-null values.
/// Keys in [overlay] with null values are skipped (default is kept).
Map<String, Object?> mergeConfig(Map<String, Object?> defaults, Map<String, Object?> overlay) {
  final Map<String, Object?> out = Map<String, Object?>.from(defaults);
  for (final MapEntry<String, Object?> e in overlay.entries) {
    if (e.value != null) out[e.key] = e.value;
  }
  return out;
}
