/// Validate non-empty after trim. Roadmap #155.
/// Audited: 2026-06-12 11:26 EDT
bool isNonEmptyAfterTrim(String? value) {
  if (value == null) return false;
  return value.trim().isNotEmpty;
}
