/// Map diff: keys added, removed, changed.
(Map<K, V> added, Map<K, V> removed, Map<K, V> changed) mapDiff<K, V>(
  Map<K, V> before,
  Map<K, V> after, {
  bool Function(V a, V b)? equals,
}) {
  final Map<K, V> added = <K, V>{};
  final Map<K, V> removed = <K, V>{};
  final Map<K, V> changed = <K, V>{};
  final bool Function(V a, V b) eq = equals ?? (V a, V b) => a == b;
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
  for (final K k in before.keys) {
    if (!after.containsKey(k)) {
      final V? v = before[k];
      if (v != null) removed[k] = v;
    }
  }
  return (added, removed, changed);
}
