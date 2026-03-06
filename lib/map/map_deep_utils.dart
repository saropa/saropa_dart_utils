/// Deep copy for maps and lists.
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

List<dynamic> deepCopyList(List<dynamic> source) {
  return source.map<dynamic>((dynamic e) {
    if (e is Map<String, dynamic>) return deepCopyMap(e);
    if (e is List<dynamic>) return deepCopyList(e);
    return e;
  }).toList();
}
