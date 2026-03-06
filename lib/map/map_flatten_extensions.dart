import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Flatten/unflatten keys (e.g. a.b.c -> value).
extension MapFlattenExtensions on Map<String, dynamic> {
  /// Flattens nested keys to dot-separated keys. [prefix] is prepended (for recursion).
  @useResult
  Map<String, dynamic> flattenKeys({String prefix = ''}) {
    final Map<String, dynamic> out = <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in entries) {
      final String key = prefix.isEmpty ? e.key : '$prefix.${e.key}';
      final val = e.value;
      if (val is Map<String, dynamic>) {
        out.addAll(val.flattenKeys(prefix: key));
      } else {
        out[key] = val;
      }
    }
    return out;
  }

  /// Unflattens dot-separated keys into nested maps.
  @useResult
  Map<String, dynamic> unflattenKeys() {
    final Map<String, dynamic> out = <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in entries) {
      final List<String> parts = e.key.split('.');
      Map<String, dynamic> parentMap = out;
      for (int i = 0; i < parts.length - 1; i++) {
        final String part = parts[i];
        final childMap = parentMap.putIfAbsent(part, () => <String, dynamic>{});
        if (childMap is Map<String, dynamic>) parentMap = childMap;
      }
      final lastPart = parts.lastOrNull;
      if (lastPart != null) parentMap[lastPart] = e.value;
    }
    return out;
  }
}
