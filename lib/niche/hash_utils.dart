/// Simple hash for cache key from objects. Roadmap #214.
int simpleHash(Object? value) {
  if (value == null) return 0;
  if (value is List) {
    int h = 1;
    for (final Object? e in value) h = 31 * h + simpleHash(e);
    return h;
  }
  if (value is Map) {
    int h = 1;
    for (final MapEntry<Object?, Object?> e in value.entries) {
      h = 31 * h + simpleHash(e.key);
      h = 31 * h + simpleHash(e.value);
    }
    return h;
  }
  return value.hashCode;
}
