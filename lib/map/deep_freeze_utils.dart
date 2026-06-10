/// Deep freeze: recursively unmodifiable views of maps, lists, and sets.
/// Roadmap #90.
///
/// Dart has no language-level immutability, but `Map`/`List`/`Set` offer
/// `.unmodifiable` views that throw on mutation. Applying that recursively
/// guards a whole configuration / decoded-JSON tree against accidental edits
/// shared across call sites — a defensive copy that fails loud instead of
/// silently letting one consumer corrupt another's data.
library;

/// Returns a deeply-unmodifiable copy of [value].
///
/// Maps, lists, and sets are rebuilt as `unmodifiable` collections with every
/// nested collection frozen too; scalars (num, String, bool, null) are
/// returned as-is. Any attempt to mutate the result — at any depth — throws
/// `UnsupportedError`.
///
/// This is a copy, not a wrapper: later mutations to the ORIGINAL nested
/// collections do not show through, because each level is rebuilt. Non-
/// collection objects are passed through by reference and are only as
/// immutable as their own type.
///
/// Example:
/// ```dart
/// final frozen = deepFreeze({'a': [1, 2], 'b': {'c': 3}});
/// (frozen as Map)['a']; // unmodifiable List [1, 2]
/// (frozen['a'] as List).add(9); // throws UnsupportedError
/// ```
Object? deepFreeze(Object? value) {
  if (value is Map) {
    return Map<Object?, Object?>.unmodifiable(
      <Object?, Object?>{
        for (final MapEntry<Object?, Object?> e in value.entries) e.key: deepFreeze(e.value),
      },
    );
  }
  if (value is List) {
    return List<Object?>.unmodifiable(
      <Object?>[
        for (final Object? element in value) deepFreeze(element),
      ],
    );
  }
  // Set checked after List/Map; a Set is not a List, so order is irrelevant
  // here, but keeping scalars last avoids needless is-checks on the common case.
  if (value is Set) {
    return Set<Object?>.unmodifiable(
      <Object?>{
        for (final Object? element in value) deepFreeze(element),
      },
    );
  }
  return value;
}
