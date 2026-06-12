/// Pretty-print decoded JSON with configurable indentation and key sorting —
/// roadmap #436.
library;

import 'dart:convert';

import 'package:saropa_dart_utils/parsing/canonicalize_json_utils.dart';

/// Renders a decoded-JSON [value] (the `Map`/`List`/`num`/`String`/`bool`/null
/// tree returned by `jsonDecode`) as an indented string.
///
/// [indent] is the number of spaces per level; pass `0` (or less) for compact
/// single-line output. When [sortKeys] is true, object keys are sorted
/// recursively (via `canonicalizeJson`) so the output is stable for diffing and
/// snapshot tests — note this also normalizes numbers to their canonical form,
/// which is a no-op for the int/double values `jsonDecode` produces.
///
/// Example:
/// ```dart
/// prettyPrintJson(<String, Object?>{'b': 1, 'a': 2}, sortKeys: true);
/// // {
/// //   "a": 2,
/// //   "b": 1
/// // }
/// ```
/// Audited: 2026-06-12 11:26 EDT
String prettyPrintJson(Object? value, {int indent = 2, bool sortKeys = false}) {
  final Object? prepared = sortKeys ? canonicalizeJson(value) : value;
  // indent <= 0 selects the compact encoder (no newlines); otherwise indent
  // each nesting level by that many spaces.
  final JsonEncoder encoder = indent <= 0
      ? const JsonEncoder()
      : JsonEncoder.withIndent(' ' * indent);
  return encoder.convert(prepared);
}
