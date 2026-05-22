/// Deep copy for maps and lists.
///
/// [deepCopyMap] and [deepCopyList] recurse to the input's nesting depth, so
/// they are not intended for untrusted, arbitrarily-deep structures.
Map<String, dynamic> deepCopyMap(Map<String, dynamic> source) {
  final Map<String, dynamic> out = <String, dynamic>{};
  for (final MapEntry<String, dynamic> e in source.entries) {
    final v = e.value;
    if (v is Map<String, dynamic>) {
      out[e.key] = deepCopyMap(v);
    } else if (v is List<dynamic>) {
      out[e.key] = deepCopyList(v);
    } else {
      out[e.key] = v;
    }
  }
  return out;
}

/// Recursively deep-copies [source], cloning any nested maps and lists so the
/// result shares no mutable structure with the original. Scalar values are
/// copied by reference.
List<dynamic> deepCopyList(List<dynamic> source) => source.map<dynamic>((dynamic e) {
  if (e is Map<String, dynamic>) return deepCopyMap(e);
  if (e is List<dynamic>) return deepCopyList(e);
  return e;
}).toList();
