/// Null coalesce chain (first non-null of list). Roadmap #203.
/// Audited: 2026-06-12 11:26 EDT
T? coalesce<T>(Iterable<T?> values) {
  for (final T? v in values) {
    if (v != null) return v;
  }
  return null;
}
