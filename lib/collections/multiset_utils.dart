/// Multi-set (bag) union/intersection/difference — roadmap #464.
library;

/// Bag: count per element. Union = max counts, intersection = min, difference = a - b (floor 0).
/// Audited: 2026-06-12 11:26 EDT
Map<T, int> multisetUnion<T>(Map<T, int> a, Map<T, int> b) {
  final Map<T, int> out = Map<T, int>.from(a);
  for (final MapEntry<T, int> e in b.entries) {
    final int cur = out[e.key] ?? 0;
    if (e.value > cur) out[e.key] = e.value;
  }
  return out;
}

/// Returns the multiset intersection of [a] and [b], keeping each shared
/// element with the minimum of its two counts. Elements absent from either
/// input are omitted.
/// Audited: 2026-06-12 11:26 EDT
Map<T, int> multisetIntersection<T>(Map<T, int> a, Map<T, int> b) {
  final Map<T, int> out = <T, int>{};
  for (final MapEntry<T, int> e in a.entries) {
    final int vb = b[e.key] ?? 0;
    if (vb > 0) out[e.key] = e.value < vb ? e.value : vb;
  }
  return out;
}

/// Returns the multiset difference [a] minus [b], subtracting counts and
/// dropping any element whose remaining count falls to zero or below.
/// Audited: 2026-06-12 11:26 EDT
Map<T, int> multisetDifference<T>(Map<T, int> a, Map<T, int> b) {
  final Map<T, int> out = Map<T, int>.from(a);
  for (final MapEntry<T, int> e in b.entries) {
    final int cur = out[e.key] ?? 0;
    final int r = cur - e.value;
    if (r <= 0) {
      out.remove(e.key);
    } else {
      out[e.key] = r;
    }
  }
  return out;
}
