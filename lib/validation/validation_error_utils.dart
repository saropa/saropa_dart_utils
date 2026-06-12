/// Normalized error model (code, message, details) for validation (roadmap #683).
library;

/// Single validation error with optional path and code.
final class ValidationErrorUtils {
  /// Creates an error with a human-readable [message], optional machine-readable
  /// [code], and optional [path] identifying the offending field.
  /// Audited: 2026-06-12 11:26 EDT
  const ValidationErrorUtils(this.message, {String? code, String? path})
    : _code = code,
      _path = path;

  /// Human-readable description of what failed.
  final String message;
  final String? _code;

  /// Optional machine-readable error code.
  /// Audited: 2026-06-12 11:26 EDT
  String? get code => _code;
  final String? _path;

  /// Optional path (e.g. field name) for the error.
  /// Audited: 2026-06-12 11:26 EDT
  String? get path => _path;

  @override
  String toString() => _path != null ? '[$_path] $message' : message;
}

/// Aggregates multiple validation errors (roadmap #684).
final class ValidationErrors {
  /// Creates a collector, optionally seeded with an existing [list] of errors.
  /// Audited: 2026-06-12 11:26 EDT
  ValidationErrors([List<ValidationErrorUtils>? list]) : _list = list ?? <ValidationErrorUtils>[];
  final List<ValidationErrorUtils> _list;

  /// Appends a single error.
  /// Audited: 2026-06-12 11:26 EDT
  void add(ValidationErrorUtils e) => _list.add(e);

  /// Appends all errors from [e].
  // ignore: saropa_lints/prefer_spread_over_addall -- appends into a persistent mutable field, not a one-shot list construction
  void addAll(Iterable<ValidationErrorUtils> e) => _list.addAll(e);

  /// True when there are no errors.
  /// Audited: 2026-06-12 11:26 EDT
  bool get isEmpty => _list.isEmpty;

  /// True when there is at least one error.
  /// Audited: 2026-06-12 11:26 EDT
  bool get isNotEmpty => _list.isNotEmpty;

  /// Unmodifiable list of all errors.
  /// Audited: 2026-06-12 11:26 EDT
  List<ValidationErrorUtils> get errors => List<ValidationErrorUtils>.unmodifiable(_list);

  @override
  String toString() => 'ValidationErrors(errors: ${_list.length})';
}
