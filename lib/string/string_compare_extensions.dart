import 'package:meta/meta.dart';

/// Null-aware comparison helpers for `String?`, the string counterpart to
/// `compareDateTimeNullable` on `DateTime?`.
extension StringNullableCompareExtensions on String? {
  /// Compares two nullable strings for sorting, tolerating `null` on either
  /// side without throwing.
  ///
  /// Null convention mirrors `compareDateTimeNullable`: by default `null` sorts
  /// **before** non-null. Set [nullsLast] to `true` to push `null`s to the end
  /// instead. Two `null`s compare equal (`0`).
  ///
  /// When [caseSensitive] is `false` (default) the two strings are lowercased
  /// before comparing, so `'Apple'` and `'apple'` are equal. When `true`, the
  /// raw values are compared.
  ///
  /// Comparison of the non-null pair is `String.compareTo`, i.e. by UTF-16 code
  /// unit, NOT locale-aware collation: every ASCII letter sorts before any
  /// accented Latin-1 letter (`'z'` < `'é'`, because `é` is U+00E9). For
  /// human-facing alphabetic order across diacritics, fold/normalize the inputs
  /// first.
  ///
  /// Returns:
  /// - `0` when the two are considered equal (both `null`, or equal strings
  ///   under the active case mode),
  /// - a negative number when this sorts before [other],
  /// - a positive number when this sorts after [other].
  ///
  /// Example:
  /// ```dart
  /// 'apple'.compareStringNullable('Banana');                 // < 0 (case-insensitive)
  /// 'apple'.compareStringNullable('Banana', caseSensitive: true); // > 0 ('B' < 'a')
  /// null.compareStringNullable('a');                          // -1 (null first)
  /// null.compareStringNullable('a', nullsLast: true);         //  1 (null last)
  /// null.compareStringNullable(null);                         //  0
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  int compareStringNullable(
    String? other, {
    bool caseSensitive = false,
    bool nullsLast = false,
  }) {
    final String? self = this;

    // Both null: equal regardless of nullsLast.
    if (self == null && other == null) {
      return 0;
    }

    // Exactly one null: its position flips with [nullsLast]. Default puts null
    // first (negative for a null self), matching compareDateTimeNullable.
    if (self == null) {
      return nullsLast ? 1 : -1;
    }

    if (other == null) {
      return nullsLast ? -1 : 1;
    }

    if (caseSensitive) {
      return self.compareTo(other);
    }

    return self.toLowerCase().compareTo(other.toLowerCase());
  }
}
