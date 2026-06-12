/// Flatten nested data and explode arrays for tabular/BI export — roadmap #648.
///
/// Two transforms that turn JSON-like records into flat rows: [flattenMap]
/// collapses nested maps and lists into dotted keys, and [explode] fans a row
/// out into one row per element of a named array. Together they prepare nested
/// API payloads for CSV / spreadsheet / BI tools that expect flat columns.
library;

/// Recursively flattens nested maps in [input] into dotted keys.
///
/// Nested maps become `parent<separator>child` keys; nested lists become
/// indexed keys (`tags.0`, `tags.1`, ...). Scalar leaves are kept as-is. The
/// [separator] defaults to `.` and joins each level of nesting.
///
/// Example:
/// ```dart
/// flattenMap(<String, Object?>{
///   'user': <String, Object?>{'name': 'Ann'},
///   'tags': <Object?>['a', 'b'],
/// });
/// // {'user.name': 'Ann', 'tags.0': 'a', 'tags.1': 'b'}
/// ```
Map<String, Object?> flattenMap(
  Map<String, Object?> input, {
  String separator = '.',
}) {
  final Map<String, Object?> out = <String, Object?>{};
  input.forEach((String key, Object? value) {
    _flattenInto(out, key, value, separator);
  });
  return out;
}

/// Writes [value] under [prefix] into [out], recursing into maps and lists.
void _flattenInto(
  Map<String, Object?> out,
  String prefix,
  Object? value,
  String separator,
) {
  // Nested map: recurse with the child key appended to the dotted prefix.
  if (value is Map<String, Object?>) {
    value.forEach((String key, Object? child) {
      _flattenInto(out, '$prefix$separator$key', child, separator);
    });
    return;
  }
  // Nested list: recurse with the element index appended to the prefix.
  if (value is List<Object?>) {
    for (int i = 0; i < value.length; i++) {
      _flattenInto(out, '$prefix$separator$i', value[i], separator);
    }
    return;
  }
  out[prefix] = value;
}

/// Explodes [row] into one row per element of the list at [arrayKey].
///
/// Each result row copies the other fields of [row] and replaces [arrayKey]
/// with a single element. An empty list yields an empty result; a missing key
/// or a non-list value yields the single original [row] unchanged.
///
/// Example:
/// ```dart
/// explode(<String, Object?>{'id': 1, 'tags': <Object?>['a', 'b']}, 'tags');
/// // [{'id': 1, 'tags': 'a'}, {'id': 1, 'tags': 'b'}]
/// ```
List<Map<String, Object?>> explode(Map<String, Object?> row, String arrayKey) {
  final Object? value = row[arrayKey];
  // Missing key or non-list value: nothing to fan out, return the row as-is.
  if (value is! List<Object?>) {
    return <Map<String, Object?>>[Map<String, Object?>.of(row)];
  }
  // Emit one row per element, each carrying that element under arrayKey.
  return <Map<String, Object?>>[
    for (final Object? element in value) <String, Object?>{...row, arrayKey: element},
  ];
}
