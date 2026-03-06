/// Cast or null (safe cast). Roadmap #204.
T? castOrNull<T>(Object? value) {
  if (value is T) return value;
  return null;
}
