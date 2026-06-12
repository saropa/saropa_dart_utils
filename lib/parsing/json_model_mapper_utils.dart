/// Read typed fields from decoded JSON, collecting errors instead of throwing
/// — roadmap #637.
library;

import 'package:saropa_dart_utils/validation/validation_error_utils.dart';

/// Reads typed values from a decoded-JSON object, accumulating a
/// [ValidationErrors] list for missing or wrong-typed fields instead of
/// throwing on the first problem.
///
/// The usual `Map<String, dynamic>` → model conversion either throws (losing
/// every error after the first) or silently coerces (hiding bad data). This
/// reader does neither: each `requireX` records a structured error and returns
/// null, so a caller can build the model, then inspect [errors] once and report
/// every field that failed at the same time.
///
/// Example:
/// ```dart
/// final r = JsonModelReader(decoded);
/// final user = (name: r.requireString('name'), age: r.requireInt('age'));
/// if (r.errors.isNotEmpty) handle(r.errors.errors);
/// ```
class JsonModelReader {
  /// Wraps [source], the decoded JSON object to read. A non-map [source]
  /// (null, a list, a scalar) is treated as an empty object, so every required
  /// read reports a missing-field error rather than throwing a cast error.
  /// [path] prefixes the [ValidationErrorUtils.path] of each error, letting a
  /// nested reader report `address.city` instead of a bare `city`.
  /// Audited: 2026-06-12 11:26 EDT
  JsonModelReader(Object? source, {String path = ''})
    : _map = source is Map ? source : const <Object?, Object?>{},
      _path = path;

  final Map<Object?, Object?> _map;
  final String _path;

  /// Accumulated errors for every failed read on this object.
  /// Audited: 2026-06-12 11:26 EDT
  final ValidationErrors errors = ValidationErrors();

  String _at(String key) => _path.isEmpty ? key : '$_path.$key';

  void _typeError(String key, Object? value, String typeName) {
    // "missing" and "wrong type" are distinct codes so a UI can prompt for an
    // absent field differently from one the user filled in with bad data.
    errors.add(
      ValidationErrorUtils(
        value == null ? 'missing required field' : 'expected $typeName',
        code: value == null ? 'missing' : 'type',
        path: _at(key),
      ),
    );
  }

  T? _require<T>(String key, String typeName) {
    final Object? v = _map[key];
    if (v is T) return v;
    _typeError(key, v, typeName);
    return null;
  }

  /// Required [String]; records an error and returns null if absent/non-string.
  /// Audited: 2026-06-12 11:26 EDT
  String? requireString(String key) => _require<String>(key, 'string');

  /// Required [int]; records an error and returns null if absent/non-int.
  /// Audited: 2026-06-12 11:26 EDT
  int? requireInt(String key) => _require<int>(key, 'int');

  /// Required [bool]; records an error and returns null if absent/non-bool.
  /// Audited: 2026-06-12 11:26 EDT
  bool? requireBool(String key) => _require<bool>(key, 'bool');

  /// Required number as [double]; an [int] is widened. Records an error and
  /// returns null when the value is absent or not a number.
  /// Audited: 2026-06-12 11:26 EDT
  double? requireDouble(String key) {
    final Object? v = _map[key];
    if (v is num) return v.toDouble();
    _typeError(key, v, 'double');
    return null;
  }

  /// Optional [String]: returns [fallback] when the key is absent, but still
  /// records an error when the key is present with a non-string value (bad data
  /// is a real problem; a missing optional field is not).
  /// Audited: 2026-06-12 11:26 EDT
  String? optionalString(String key, {String? fallback}) {
    final Object? v = _map[key];
    if (v == null) return fallback;
    if (v is String) return v;
    _typeError(key, v, 'string');
    return fallback;
  }

  /// Required homogeneous list. Records an error and returns null when the value
  /// is absent, is not a list, or any element is not an [E].
  /// Audited: 2026-06-12 11:26 EDT
  List<E>? requireList<E>(String key) {
    final Object? v = _map[key];
    if (v is List && v.every((Object? e) => e is E)) return v.cast<E>();
    _typeError(key, v, 'List<$E>');
    return null;
  }

  /// Required nested object as a child reader sharing this reader's error list,
  /// so a nested failure surfaces with a dotted [_at] path on the SAME
  /// [errors] collection. Returns null (and records an error) when absent or
  /// not a map.
  /// Audited: 2026-06-12 11:26 EDT
  JsonModelReader? child(String key) {
    final Object? v = _map[key];
    if (v is Map) return JsonModelReader(v, path: _at(key));
    _typeError(key, v, 'object');
    return null;
  }
}
