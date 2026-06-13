import 'package:meta/meta.dart';

/// Deep merge: nested maps are merged recursively; later source overwrites.
extension MapDeepMergeExtensions on Map<String, dynamic> {
  /// Merges [other] into this map recursively. Values in [other] overwrite.
  /// Nested maps are merged; lists and other values are replaced.
  ///
  /// The result is independent of both inputs: nested maps and lists carried
  /// through unchanged are cloned, so mutating the merged map never mutates the
  /// receiver or [other]. (A previous version shared those nested structures by
  /// reference.) Recurses to the maps' nesting depth; not intended for
  /// untrusted, arbitrarily-deep input (deep nesting can exhaust the stack).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Map<String, dynamic> deepMerge(Map<String, dynamic> other) {
    // Clone the receiver's entries first so the result aliases neither input.
    final Map<String, dynamic> result = <String, dynamic>{
      for (final MapEntry<String, dynamic> e in entries) e.key: _deepCloneJson(e.value),
    };
    for (final MapEntry<String, dynamic> e in other.entries) {
      final dynamic existing = result[e.key];
      final dynamic otherVal = e.value;
      if (existing is Map<String, dynamic> && otherVal is Map<String, dynamic>) {
        // Both sides are maps → recurse (deepMerge already returns a fresh map).
        result[e.key] = existing.deepMerge(otherVal);
      } else {
        // Replace — but clone so the result does not alias `other`.
        result[e.key] = _deepCloneJson(otherVal);
      }
    }
    return result;
  }
}

/// Recursively copies JSON-like [value] so a merged map shares no nested
/// map/list structure with its inputs; scalars and other immutables pass through.
dynamic _deepCloneJson(dynamic value) {
  if (value is Map<String, dynamic>) {
    return <String, dynamic>{
      for (final MapEntry<String, dynamic> e in value.entries) e.key: _deepCloneJson(e.value),
    };
  }
  if (value is List) {
    return <dynamic>[for (final dynamic item in value) _deepCloneJson(item)];
  }
  return value;
}
