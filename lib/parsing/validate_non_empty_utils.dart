/// Validate non-empty after trim. Roadmap #155.
bool isNonEmptyAfterTrim(String? value) {
  if (value == null) return false;
  return value.trim().isNotEmpty;
}
