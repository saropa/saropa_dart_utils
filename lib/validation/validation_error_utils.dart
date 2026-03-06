/// Normalized error model (code, message, details) for validation (roadmap #683).
library;

/// Single validation error with optional path and code.
final class ValidationError {
  const ValidationError(this.message, {String? code, String? path}) : _code = code, _path = path;
  final String message;
  final String? _code;

  /// Optional machine-readable error code.
  String? get code => _code;
  final String? _path;

  /// Optional path (e.g. field name) for the error.
  String? get path => _path;

  @override
  String toString() => _path != null ? '[$_path] $message' : message;
}

/// Aggregates multiple validation errors (roadmap #684).
final class ValidationErrors {
  ValidationErrors([List<ValidationError>? list]) : _list = list ?? [];
  final List<ValidationError> _list;

  /// Appends a single error.
  void add(ValidationError e) => _list.add(e);

  /// Appends all errors from [e].
  void addAll(Iterable<ValidationError> e) => _list.addAll(e);

  /// True when there are no errors.
  bool get isEmpty => _list.isEmpty;

  /// True when there is at least one error.
  bool get isNotEmpty => _list.isNotEmpty;

  /// Unmodifiable list of all errors.
  List<ValidationError> get errors => List<ValidationError>.unmodifiable(_list);

  @override
  String toString() => 'ValidationErrors(errors: ${_list.length})';
}
