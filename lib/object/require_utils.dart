const String _kDefaultRequiredNullMessage = 'Required value was null';

/// Require non-null (throw descriptive if null). Roadmap #201.
T requireNonNull<T>(T? value, [String message = _kDefaultRequiredNullMessage]) {
  if (value == null) throw ArgumentError(message);
  return value;
}
