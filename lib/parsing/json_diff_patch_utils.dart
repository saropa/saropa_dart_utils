/// JSON diff/patch (simple key-level) — roadmap #624.
library;

/// Returns keys added, removed, or changed between [a] and [b] (one level).
(Map<String, Object?> added, Map<String, Object?> removed, Map<String, Object?> changed)
jsonDiffShallow(Map<String, Object?> a, Map<String, Object?> b) {
  final Map<String, Object?> removed = <String, Object?>{};
  final Map<String, Object?> changed = <String, Object?>{};
  // Pass over the OLD map: a key gone from the new map is a removal; a key whose
  // value differs is a change (shallow `!=` only — nested maps compare by ref).
  for (final String k in a.keys) {
    if (!b.containsKey(k)) {
      removed[k] = a[k];
    } else if (a[k] != b[k]) {
      changed[k] = b[k];
    }
  }
  // Pass over the NEW map for keys absent from the old one: those are additions.
  final Map<String, Object?> added = <String, Object?>{};
  for (final String k in b.keys) {
    if (!a.containsKey(k)) added[k] = b[k];
  }
  return (added, removed, changed);
}
