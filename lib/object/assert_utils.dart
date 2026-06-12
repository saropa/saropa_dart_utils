const String _kDefaultAssertionMessage = 'Assertion failed';

/// Assert with message (only in debug if desired). Roadmap #205.
/// Audited: 2026-06-12 11:26 EDT
void assertThat(bool isConditionMet, [String message = _kDefaultAssertionMessage]) {
  if (!isConditionMet) throw AssertionError(message);
}
