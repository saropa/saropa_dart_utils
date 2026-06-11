import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/niche/natural_sort_utils.dart';
import 'package:saropa_dart_utils/string/string_diacritics_extensions.dart';

/// Null-aware, diacritic-folding comparison helpers for `String?` — the
/// "fold first" comparator that `compareStringNullable`'s docstring tells
/// callers to build for human-facing alphabetic order.
extension StringFoldedCompareExtensions on String? {
  /// Compares two nullable strings as a human reads a contact/name list:
  /// diacritics folded (`á→a`, `ß→ss`, `æ→ae`), case-insensitive by default,
  /// optional natural numeric ordering, nulls grouped, and a deterministic
  /// tie-break so distinct strings NEVER compare equal.
  ///
  /// This makes `"Ángel"` interfile with the **A** names instead of sorting
  /// after `"Zoe"` — raw `String.compareTo` orders by UTF-16 code unit, where
  /// `Á` (U+00C1) sits far above ASCII `z`, so an accented name would otherwise
  /// land at the very end of the list.
  ///
  /// Pipeline per side: [StringDiacriticsExtensions.removeDiacritics] →
  /// (optional) `toLowerCase()`. Primary compare is [naturalCompare] when
  /// [natural] is `true`, else `String.compareTo` on the folded keys. When the
  /// primary result is `0` (the two folded/cased keys match, e.g. `"Foo"` vs
  /// `"fóò"`) the RAW, original-case strings are compared with `String.compareTo`
  /// as a deterministic tie-break — so the comparator returns `0` only when the
  /// originals are byte-for-byte identical. That total order is required for
  /// `SplayTreeMap` keys, which silently drop a key whenever the comparator
  /// returns `0`.
  ///
  /// Null convention mirrors `compareStringNullable`: both `null` → `0`; exactly
  /// one `null` sorts first by default, or last when [nullsLast] is `true`. The
  /// null branch runs BEFORE folding, so `null`s never reach the fold step.
  ///
  /// Latin-focused: [removeDiacritics] only maps Latin diacritics/ligatures, so
  /// CJK, Cyrillic, Arabic, Greek, etc. pass through unchanged and order by code
  /// point (after all ASCII). This is NOT locale-aware ICU collation — Turkish
  /// dotless-i, German phonebook-ß, Swedish å-after-z are not honored.
  ///
  /// Example:
  /// ```dart
  /// 'Ángel'.compareStringFolded('Andy');   // > 0 (folds to 'angel' vs 'andy')
  /// 'Zoe'.compareStringFolded('Ángel');     // > 0 ('zoe' after 'angel')
  /// 'Foo'.compareStringFolded('fóò');        // != 0 (fold-equal → raw tie-break)
  /// null.compareStringFolded('a');           // -1 (null first)
  /// ```
  @useResult
  int compareStringFolded(
    String? other, {
    bool caseSensitive = false,
    bool nullsLast = false,
    bool natural = false,
  }) {
    final String? self = this;

    // Null branch first: nulls never reach the fold step. Convention matches
    // compareStringNullable / compareDateTimeNullable (null first by default).
    if (self == null && other == null) {
      return 0;
    }
    if (self == null) {
      return nullsLast ? 1 : -1;
    }
    if (other == null) {
      return nullsLast ? -1 : 1;
    }

    // Fold diacritics so accented Latin interfiles with its base letter (á with
    // a) instead of sorting after z by code unit. Ligatures expand here (ß→ss,
    // æ→ae), changing length — fine for both compareTo and naturalCompare, which
    // re-tokenizes the already-folded string.
    String fa = self.removeDiacritics();
    String fb = other.removeDiacritics();

    if (!caseSensitive) {
      fa = fa.toLowerCase();
      fb = fb.toLowerCase();
    }

    final int primary = natural ? naturalCompare(fa, fb) : fa.compareTo(fb);
    if (primary != 0) {
      return primary;
    }

    // Folded keys tie ("Foo" vs "fóò"): deterministic tie-break on the raw
    // originals so the comparator never returns 0 for unequal strings — a 0
    // compare makes SplayTreeMap silently drop the colliding key. Only truly
    // identical originals reach 0 here.
    return self.compareTo(other);
  }
}

/// Comparator-shaped free function for `List.sort`, `SplayTreeMap`, and other
/// sort-key APIs, since tearing an extension method off into a
/// `Comparator<String?>` is awkward. Delegates to
/// [StringFoldedCompareExtensions.compareStringFolded].
///
/// Example:
/// ```dart
/// names.sort(foldedCompare);
/// SplayTreeMap<String, int>(foldedCompare);
/// ```
@useResult
int foldedCompare(
  String? a,
  String? b, {
  bool caseSensitive = false,
  bool nullsLast = false,
  bool natural = false,
}) => a.compareStringFolded(
  b,
  caseSensitive: caseSensitive,
  nullsLast: nullsLast,
  natural: natural,
);

/// Adds diacritic-folding sorting to a `List<String>`.
extension FoldedSortExtension on List<String> {
  /// Returns a NEW list sorted with [foldedCompare] (case-insensitive,
  /// diacritics folded). The original list is not modified.
  ///
  /// Set [natural] to order embedded numbers by value (`img2` before `img10`).
  ///
  /// Note: `List.sort` is not stable. Distinct strings are always ordered
  /// deterministically (via the raw tie-break), but two byte-for-byte identical
  /// strings are equal and may appear in any relative order.
  ///
  /// Example:
  /// ```dart
  /// ['Zoe', 'Ángel', 'Andy'].sortedFolded(); // ['Andy', 'Ángel', 'Zoe']
  /// ```
  @useResult
  List<String> sortedFolded({bool natural = false}) => List<String>.of(this)
    ..sort((String a, String b) => foldedCompare(a, b, natural: natural));
}
