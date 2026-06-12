/// Map diff: keys added, removed, changed.
/// Audited: 2026-06-12 11:26 EDT
(Map<K, V> added, Map<K, V> removed, Map<K, V> changed) mapDiff<K, V>(
  Map<K, V> before,
  Map<K, V> after, {
  bool Function(V a, V b)? equals,
}) {
  final Map<K, V> added = <K, V>{};
  final Map<K, V> changed = <K, V>{};
  // Default to `==`; callers pass a custom comparator for deep/semantic equality
  // so unchanged values are not misreported as changed.
  final bool Function(V a, V b) eq = equals ?? (V a, V b) => a == b;
  // First pass over `after`: a key absent from `before` is an addition; a key
  // present in both whose value differs is a change. (Equal values are emitted
  // to neither bucket.) Use key PRESENCE, not a null value, to detect
  // membership: a key whose value is genuinely `null` (nullable V) is a real
  // entry and must still be reported as added/changed. Casting `map[k] as V` is
  // safe because the key is known present from `.keys`/`containsKey`.
  for (final MapEntry<K, V> entry in after.entries) {
    final V afterVal = entry.value;
    if (!before.containsKey(entry.key)) {
      added[entry.key] = afterVal;
    } else {
      // `before[k]` is V? (the lookup is nullable); an `is V` check both narrows
      // it to V and — for a present key — is always true, so a genuine null
      // value (nullable V) is still compared rather than skipped.
      final V? beforeRaw = before[entry.key];
      if (beforeRaw is V && !eq(beforeRaw, afterVal)) changed[entry.key] = afterVal;
    }
  }
  // Second pass over `before`: any key not in `after` is a removal. Removals
  // need their own pass because the first loop only visits `after`'s keys.
  final Map<K, V> removed = <K, V>{};
  for (final MapEntry<K, V> entry in before.entries) {
    if (!after.containsKey(entry.key)) removed[entry.key] = entry.value;
  }
  return (added, removed, changed);
}
