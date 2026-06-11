/// URI template expansion (RFC 6570 subset) — roadmap #629.
///
/// Expands `{...}` expressions in a URI template against a variable map, the way
/// API clients build request URLs from a template like
/// `https://api/users/{id}{?fields*}`. Covers RFC 6570 Levels 1–3 plus the
/// prefix (`{var:3}`) and explode (`{list*}`) modifiers:
///
///   * simple `{var}` and multiple `{a,b}` (comma-joined, percent-encoded)
///   * reserved `{+var}` and fragment `{#var}` (keep reserved chars)
///   * label `{.var}`, path `{/var}`, path-style `{;var}`, query `{?var}` /
///     `{&var}` (operator-specific separators and `name=` for the named ones)
///
/// Values may be a string, number, bool, or `List`; an undefined (absent or
/// null) variable contributes nothing. Map/associative values are out of scope.
/// Literal text outside braces is passed through unchanged.
library;

import 'dart:convert' show utf8;

/// Characters never percent-encoded (RFC 3986 unreserved).
const String _unreserved = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

/// Reserved set kept unencoded by the `+` and `#` operators (allow = U+R).
const String _reserved = ":/?#[]@!\$&'()*+,;=";

/// Splits a varspec into name, optional `:maxLength` prefix, optional `*` explode.
final RegExp _specPattern = RegExp(r'^([^:*]+)(?::(\d+))?(\*)?$');

/// One RFC 6570 operator's expansion rules.
class _Op {
  const _Op(
    this.symbol,
    this.first,
    this.separator, {
    this.named = false,
    this.ifEmpty = '',
    this.allowReserved = false,
  });

  /// The leading operator character in the template (`''` for the default op).
  final String symbol;

  /// Prepended before the joined result when it is non-empty (e.g. `?`).
  final String first;

  /// Joins multiple values / varspecs.
  final String separator;

  /// Whether each value is rendered as `name=value` (`; ? &`).
  // ignore: saropa_lints/prefer_boolean_prefixes -- "named" is RFC 6570 operator terminology (named expansion); a prefix would obscure the spec mapping
  final bool named;

  /// What follows the name when a named value is empty (`` for `;`, `=` for `?`/`&`).
  final String ifEmpty;

  /// Whether reserved characters pass through unencoded.
  final bool allowReserved;
}

const _Op _defaultOp = _Op('', '', ',');

const Map<String, _Op> _operators = <String, _Op>{
  '+': _Op('+', '', ',', allowReserved: true),
  '#': _Op('#', '#', ',', allowReserved: true),
  '.': _Op('.', '.', '.'),
  '/': _Op('/', '/', '/'),
  ';': _Op(';', ';', ';', named: true),
  '?': _Op('?', '?', '&', named: true, ifEmpty: '='),
  '&': _Op('&', '&', '&', named: true, ifEmpty: '='),
};

/// Expands every `{...}` expression in [template] against [variables], leaving
/// literal text untouched.
///
/// Example:
/// ```dart
/// expandUriTemplate('/users/{id}{?tags*}', {'id': 7, 'tags': ['a', 'b']});
/// // /users/7?tags=a&tags=b
/// ```
String expandUriTemplate(String template, Map<String, Object?> variables) =>
    template.replaceAllMapped(
      RegExp(r'\{([^{}]*)\}'),
      (Match m) => _expandExpression(m.group(1) ?? '', variables),
    );

/// Expands one expression body (the text between the braces).
String _expandExpression(String expression, Map<String, Object?> variables) {
  // The first character may be an RFC 6570 operator (`+`, `#`, `.`, `/`, ...)
  // that changes the prefix/separator/encoding; if it isn't one of those, fall
  // back to the default (simple) operator and treat the whole text as varspecs.
  final _Op op = expression.isEmpty ? _defaultOp : (_operators[expression[0]] ?? _defaultOp);
  // Strip the operator char only when one was actually matched (its symbol is
  // non-empty); the default operator has no leading char to drop.
  // ignore: avoid_string_substring -- symbol is non-empty only when expression starts with the operator char
  final String body = op.symbol.isEmpty ? expression : expression.substring(1);
  final List<String> parts = <String>[];
  // Expand each comma-separated varspec independently; undefined variables
  // yield null and are omitted entirely (not rendered as empty).
  for (final String spec in body.split(',')) {
    // An empty spec (e.g. a trailing comma) has no variable to expand.
    if (spec.isEmpty) {
      continue;
    }
    final String? piece = _expandSpec(spec, op, variables);
    if (piece != null) {
      parts.add(piece);
    }
  }
  // When every variable was undefined the expansion is empty (no prefix); else
  // join with the operator's separator behind its leading char (e.g. `?a=1&b=2`).
  return parts.isEmpty ? '' : op.first + parts.join(op.separator);
}

/// Expands a single varspec (`name`, `name:3`, or `name*`) or null if the
/// variable is undefined.
String? _expandSpec(String spec, _Op op, Map<String, Object?> variables) {
  final RegExpMatch? m = _specPattern.firstMatch(spec);
  if (m == null) {
    throw FormatException('invalid URI-template varspec "$spec"');
  }
  final String name = m.group(1) ?? '';
  final Object? value = variables[name];
  if (value == null) {
    return null;
  }
  if (value is List) {
    return _expandList(name, value, op, explode: m.group(3) != null);
  }
  return _expandString(name, value.toString(), op, m.group(2));
}

/// Expands a scalar value, applying an optional `:maxLength` prefix and the
/// operator's encoding + named formatting.
String _expandString(String name, String raw, _Op op, String? maxLength) {
  String value = raw;
  final int? limit = maxLength == null ? null : int.tryParse(maxLength);
  if (limit != null && limit < raw.length) {
    // ignore: avoid_string_substring -- limit is a parsed \d+ and guarded < raw.length, so [0, limit) is in bounds
    value = raw.substring(0, limit);
  }
  final String encoded = _pctEncode(value, allowReserved: op.allowReserved);
  return op.named ? _named(name, encoded, op) : encoded;
}

/// Expands a list value, exploded (each item separated by the operator's
/// separator) or joined by commas. An empty list contributes nothing.
String? _expandList(String name, List<Object?> values, _Op op, {required bool explode}) {
  if (values.isEmpty) {
    return null;
  }
  final Iterable<String> encoded = values.map(
    (Object? v) => _pctEncode(v.toString(), allowReserved: op.allowReserved),
  );
  if (explode) {
    final Iterable<String> items = op.named
        ? encoded.map((String e) => _named(name, e, op))
        : encoded;
    return items.join(op.separator);
  }
  final String joined = encoded.join(',');
  return op.named ? '$name=$joined' : joined;
}

/// Renders a named pair: `name=value`, or `name` + [_Op.ifEmpty] when empty.
String _named(String name, String value, _Op op) =>
    value.isEmpty ? '$name${op.ifEmpty}' : '$name=$value';

/// Percent-encodes [value] (UTF-8), keeping unreserved characters and — when
/// [allowReserved] — reserved characters too.
String _pctEncode(String value, {required bool allowReserved}) {
  final StringBuffer out = StringBuffer();
  for (final int byte in utf8.encode(value)) {
    final String ch = String.fromCharCode(byte);
    if (_unreserved.contains(ch) || (allowReserved && _reserved.contains(ch))) {
      out.write(ch);
    } else {
      out
        ..write('%')
        ..write(byte.toRadixString(16).toUpperCase().padLeft(2, '0'));
    }
  }
  return out.toString();
}
