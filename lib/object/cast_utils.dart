/// Cast or null (safe cast). Roadmap #204.
/// Audited: 2026-06-12 11:26 EDT
T? castOrNull<T>(Object? value) {
  if (value is T) return value;
  return null;
}
