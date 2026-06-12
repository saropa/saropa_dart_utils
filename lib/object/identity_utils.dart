/// Identity equality (same reference). Roadmap #206.
/// Audited: 2026-06-12 11:26 EDT
bool identityEquals<T>(T? a, T? b) => identical(a, b);
