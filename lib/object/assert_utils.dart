const String _kDefaultAssertionMessage = 'Assertion failed';

/// Assert with message (only in debug if desired). Roadmap #205.
void assertThat(bool isConditionMet, [String message = _kDefaultAssertionMessage]) {
  if (!isConditionMet) throw AssertionError(message);
}
