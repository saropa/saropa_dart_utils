/// Defensive coding helpers (guard patterns, invariants) — roadmap #700.
library;

const String _kDefaultGuardMessage = 'Assertion failed';

/// Throws [ArgumentError] if [isConditionMet] is false, with [message].
void guardArgument(bool isConditionMet, [String message = _kDefaultGuardMessage]) {
  if (!isConditionMet) throw ArgumentError(message);
}

/// Returns [value] if [isConditionMet] else throws [ArgumentError].
T guard<T>({
  required bool isConditionMet,
  required T value,
  String message = _kDefaultGuardMessage,
}) {
  if (!isConditionMet) throw ArgumentError(message);
  return value;
}
