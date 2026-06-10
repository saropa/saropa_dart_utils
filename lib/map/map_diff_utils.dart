/// Map diff: keys added, removed, changed.
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
  // to neither bucket.)
  for (final K k in after.keys) {
    final V? afterVal = after[k];
    if (afterVal == null) continue;
    if (!before.containsKey(k)) {
      added[k] = afterVal;
    } else {
      final V? beforeVal = before[k];
      if (beforeVal != null && !eq(beforeVal, afterVal)) changed[k] = afterVal;
    }
  }
  // Second pass over `before`: any key not in `after` is a removal. Removals
  // need their own pass because the first loop only visits `after`'s keys.
  final Map<K, V> removed = <K, V>{};
  for (final K k in before.keys) {
    if (!after.containsKey(k)) {
      final V? v = before[k];
      if (v != null) removed[k] = v;
    }
  }
  return (added, removed, changed);
}
