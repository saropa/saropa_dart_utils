/// Cross-field validation (start < end, one-of required) — roadmap #682.
library;

const String _kDefaultStartName = 'start';
const String _kDefaultEndName = 'end';
const String _kDefaultFieldNames = 'fields';

/// Returns null if valid, else error message.
String? validateStartBeforeEnd(
  num start,
  num end, {
  String startName = _kDefaultStartName,
  String endName = _kDefaultEndName,
}) {
  if (start <= end) return null;
  return '$startName must be <= $endName';
}

/// Returns null if at least one of [values] is non-null and non-empty (for strings).
String? validateOneOfRequired(List<Object?> values, {String fieldNames = _kDefaultFieldNames}) {
  final bool hasAny = values.any(
    (Object? v) {
      if (v == null) return false;
      if (v is String) return v.trim().isNotEmpty;
      return true;
    },
  );
  return hasAny ? null : 'At least one of $fieldNames is required';
}
