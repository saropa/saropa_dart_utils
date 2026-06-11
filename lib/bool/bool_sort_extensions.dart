import 'package:meta/meta.dart';

/// Saropa sorting extension for a single [bool].
///
/// `bool` does not implement [Comparable] in `dart:core`, so `[true, false]
/// .sort()` throws and there is no canonical way to order booleans. This
/// extension adds a [Comparable.compareTo]-shaped comparator so a `bool` can
/// be used directly as a sort key or as a tie-break inside a larger
/// comparator.
extension BoolSortingHelper on bool {
  /// Compares this boolean to [other], following the [Comparable.compareTo]
  /// contract so booleans can be used as a sort key.
  ///
  /// `bool` does not implement [Comparable] in `dart:core`, so this fills that
  /// gap. Ordering convention: `true` sorts BEFORE `false` ("flagged first"),
  /// matching the common "float the flagged rows to the top" expectation —
  /// e.g. `items.sort((a, b) => a.isPinned.compareTo(b.isPinned))`.
  ///
  /// Returns:
  /// - `0` when both values are equal (both `true` or both `false`),
  /// - `-1` when this is `true` and [other] is `false`,
  /// - `1` when this is `false` and [other] is `true`.
  ///
  /// The result is contractually a sign, not a magnitude: callers should rely
  /// on `< 0` / `0` / `> 0`, exactly as the [Comparable] contract requires.
  ///
  /// Example:
  /// ```dart
  /// true.compareTo(false);  // -1  (true first)
  /// false.compareTo(true);  //  1  (false last)
  /// true.compareTo(true);   //  0  (equal)
  ///
  /// (<bool>[false, true, false, true]..sort((a, b) => a.compareTo(b)));
  /// // [true, true, false, false]
  /// ```
  ///
  /// ref: https://stackoverflow.com/questions/61881850/sort-list-based-on-boolean
  @useResult
  // ignore: avoid_positional_boolean_parameters -- a bool comparator must take a positional bool to match the Comparable.compareTo signature.
  int compareTo(bool other) {
    // Equal values (both true or both false) compare as 0 — satisfies the
    // reflexivity law and prevents spurious reordering of same-valued runs.
    if (this == other) {
      return 0;
    }

    // When this is true and other is false, this sorts first ("flagged first").
    if (this && !other) {
      return -1;
    }

    // The only remaining case is this false and other true, so this sorts last.
    // The earlier equality and true/false branches make the fall-through total
    // over the closed two-value domain; it cannot misclassify and never throws.
    return 1;
  }
}
