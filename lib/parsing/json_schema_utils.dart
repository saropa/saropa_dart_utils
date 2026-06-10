/// Declarative schema validation for JSON-like data — roadmap #636.
///
/// A lightweight companion to `JsonModelReader`: instead of reading typed
/// fields one by one, describe the whole object as a `field → FieldSchema` map
/// and validate it in one pass, collecting a [ValidationErrors] list (required
/// presence, type match, enum membership). No code generation, no dependency.
library;

import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/validation/validation_error_utils.dart';

/// The JSON value kinds a [FieldSchema] can require.
enum JsonType {
  /// A `String`.
  string,

  /// An `int` specifically (not a fractional number).
  integer,

  /// Any `num` (int or double).
  number,

  /// A `bool`.
  boolean,

  /// A `List`.
  list,

  /// A `Map` (nested object).
  object,

  /// Any non-null value (no type constraint).
  any,
}

/// The constraints on a single field: its [type], whether it must be present
/// ([isRequired]), and an optional [allowed] set of values (an enum).
@immutable
class FieldSchema {
  /// Describes a field of [type]. [isRequired] defaults to true; pass [allowed]
  /// to restrict the value to a fixed set.
  const FieldSchema(this.type, {this.isRequired = true, this.allowed});

  /// The required value kind.
  final JsonType type;

  /// Whether an absent (or null) value is an error.
  final bool isRequired;

  /// When non-null, the value must equal one of these (an enum constraint).
  final List<Object?>? allowed;
}

bool _typeMatches(JsonType type, Object value) {
  // Maps each schema type to the Dart runtime check a decoded JSON value must
  // satisfy. `integer` is stricter than `number` (int vs any num), and `any`
  // accepts everything. Exhaustive over JsonType, so no default is needed.
  switch (type) {
    case JsonType.string:
      return value is String;
    case JsonType.integer:
      return value is int;
    case JsonType.number:
      return value is num;
    case JsonType.boolean:
      return value is bool;
    case JsonType.list:
      return value is List;
    case JsonType.object:
      return value is Map;
    case JsonType.any:
      return true;
  }
}

/// Validates a decoded JSON [object] against [schema], returning a
/// [ValidationErrors] collecting every problem (it never throws). Per field:
/// a required field that is absent or null is `missing`; a present value of the
/// wrong kind is `type`; a value outside an [FieldSchema.allowed] set is `enum`.
/// A non-map [object] yields a single object-level type error.
///
/// Example:
/// ```dart
/// validateJsonSchema(decoded, <String, FieldSchema>{
///   'name': FieldSchema(JsonType.string),
///   'age': FieldSchema(JsonType.integer, isRequired: false),
///   'role': FieldSchema(JsonType.string, allowed: <Object?>['admin', 'user']),
/// });
/// ```
ValidationErrors validateJsonSchema(Object? object, Map<String, FieldSchema> schema) {
  final ValidationErrors errors = ValidationErrors();
  if (object is! Map) {
    errors.add(ValidationErrorUtils('expected object', code: 'type'));
    return errors;
  }
  for (final MapEntry<String, FieldSchema> entry in schema.entries) {
    final String key = entry.key;
    final FieldSchema field = entry.value;
    final Object? value = object[key];
    // Absent-or-null: only an error when the field is required.
    if (value == null) {
      if (field.isRequired) {
        errors.add(ValidationErrorUtils('missing required field', code: 'missing', path: key));
      }
      continue;
    }
    if (!_typeMatches(field.type, value)) {
      errors.add(ValidationErrorUtils('expected ${field.type.name}', code: 'type', path: key));
      continue;
    }
    final List<Object?>? allowed = field.allowed;
    if (allowed != null && !allowed.contains(value)) {
      errors.add(ValidationErrorUtils('value not in allowed set', code: 'enum', path: key));
    }
  }
  return errors;
}
