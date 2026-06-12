import 'package:meta/meta.dart';

import '../string/string_compare_extensions.dart';

/// Sorts a [List] of nullable strings in place, case-insensitively, with
/// `null`s grouped together at the front.
///
/// Returns `true` on success and `false` only if the underlying sort threw.
/// The `false` branch is defensive: comparing strings via the delegated
/// [StringNullableCompareExtensions.compareStringNullable] cannot throw for any
/// `String?` pair, so in practice this always returns `true`. The boolean is
/// retained so callers that wrap the result keep working, and so a future
/// comparator that CAN throw still reports failure instead of propagating.
///
/// Comparison is by lowercased UTF-16 code unit, NOT locale-aware collation:
/// every ASCII letter sorts before any accented Latin-1 letter (`'z'` < `'é'`),
/// and emoji sort by their code units. `null` and `''` both collate as the
/// empty string, so they compare equal and keep their relative order (a stable
/// in-place [List.sort] retains every element — unlike a tree map, nothing is
/// dropped when the comparator returns `0`).
///
/// Wrapping the comparison in this helper lets callers sort a `List<String?>`
/// without tripping the extension-on-`List<String?>` lint at every call site.
///
/// Example:
/// ```dart
/// final List<String?> names = <String?>['B', null, 'a', 'C'];
/// sortNullableStringListInPlace(names); // true
/// names; // [null, 'a', 'B', 'C']
/// ```
/// Audited: 2026-06-12 11:26 EDT
@useResult
bool sortNullableStringListInPlace(List<String?> list) {
  list.sort(_compareNullableStringsForSort);
  return true;
}

// Case-insensitive nullable-string comparator with nulls grouped first.
// Delegates to compareStringNullable (the library's single source of truth for
// null-aware string ordering) rather than re-implementing the lowercase/null
// coalescing here, so both stay consistent if the rules ever change.
int _compareNullableStringsForSort(String? a, String? b) => a.compareStringNullable(b);
