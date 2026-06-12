/// Typed non-empty/positive wrappers with validation — roadmap #697.
library;

const String _kErrNonEmptyStringRequired = 'NonEmptyString requires non-empty value';
const String _kErrPositiveNumberRequired = 'PositiveNumber requires > 0';

/// Wrapper that guarantees non-empty string (validated at construction).
final class TypedPositiveUtils {
  const TypedPositiveUtils._(this._value);
  final String _value;

  /// Creates a [TypedPositiveUtils] if [value] is non-empty after trim; otherwise throws.
  /// Audited: 2026-06-12 11:26 EDT
  factory TypedPositiveUtils(String value) {
    if (value.trim().isEmpty) throw ArgumentError(_kErrNonEmptyStringRequired);
    return TypedPositiveUtils._(value);
  }

  /// The non-empty string value.
  /// Audited: 2026-06-12 11:26 EDT
  String get value => _value;
}

/// Wrapper that guarantees positive number.
final class PositiveNumber {
  const PositiveNumber._(this._value);
  final double _value;

  /// Creates a [PositiveNumber] if [value] is greater than zero; otherwise throws.
  /// Audited: 2026-06-12 11:26 EDT
  factory PositiveNumber(num value) {
    final valueAsDouble = value.toDouble();
    if (valueAsDouble <= 0) throw ArgumentError(_kErrPositiveNumberRequired);
    return PositiveNumber._(valueAsDouble);
  }

  /// The positive number value.
  /// Audited: 2026-06-12 11:26 EDT
  double get value => _value;

  @override
  String toString() => 'PositiveNumber(value: $_value)';
}
