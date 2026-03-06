import 'package:meta/meta.dart';

/// Deep merge: nested maps are merged recursively; later source overwrites.
extension MapDeepMergeExtensions on Map<String, dynamic> {
  /// Merges [other] into this map recursively. Values in [other] overwrite.
  /// Nested maps are merged; lists and other values are replaced.
  @useResult
  Map<String, dynamic> deepMerge(Map<String, dynamic> other) {
    final Map<String, dynamic> result = Map<String, dynamic>.from(this);
    for (final MapEntry<String, dynamic> e in other.entries) {
      final dynamic existing = result[e.key];
      final dynamic otherVal = e.value;
      if (existing is Map<String, dynamic> && otherVal is Map<String, dynamic>) {
        result[e.key] = existing.deepMerge(otherVal);
      } else {
        result[e.key] = e.value;
      }
    }
    return result;
  }
}
