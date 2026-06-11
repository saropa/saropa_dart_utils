import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/list/list_extensions.dart';
import 'package:saropa_dart_utils/list/unique_list_extensions.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Extensions on List<String> for common prefix/suffix.
extension ListStringExtensions on List<String> {
  /// Joins these strings into a natural-language list with an Oxford comma:
  /// one item is itself, two become `'a and b'`, three or more become
  /// `'a, b, and c'`.
  ///
  /// Each entry is trimmed and blank/whitespace-only entries are dropped before
  /// counting, so `[' ', 'a', '']` collapses to a single item rather than
  /// emitting stray separators. When [isUnique] is `true` (default) duplicates
  /// are removed via [toUnique] (first-seen order preserved). Returns `null` —
  /// not `''` — when nothing remains after trimming, so a caller can tell
  /// "no items" apart from a real joined string.
  ///
  /// The joiners are caller-controlled for locale/style:
  /// - [joiner] separates the leading items in the 3+ case (default `', '`).
  /// - [doubleJoiner] joins exactly two items (default `' and '`).
  /// - [lastJoiner] precedes the final item in the 3+ case (default `', and '`,
  ///   the Oxford comma).
  ///
  /// Example:
  /// ```dart
  /// ['Alice', 'Bob', 'Carol'].joinDisplayList(); // 'Alice, Bob, and Carol'
  /// ['Alice', 'Bob'].joinDisplayList();          // 'Alice and Bob'
  /// ['Alice'].joinDisplayList();                 // 'Alice'
  /// <String>[].joinDisplayList();                // null
  /// ```
  @useResult
  String? joinDisplayList({
    String joiner = ', ',
    String doubleJoiner = ' and ',
    String lastJoiner = ', and ',
    bool isUnique = true,
  }) {
    // Trim and drop blanks before counting so the length-based branching below
    // sees the real item count, not entries that would render as empty.
    final List<String> trimmed = <String>[
      for (final String s in this)
        if (s.trim().isNotEmpty) s.trim(),
    ];

    final List<String> list = isUnique ? trimmed.toUnique() : trimmed;
    if (list.isEmpty) {
      return null;
    }

    // first/last are safe here: each branch runs only after its length is
    // proven, so the list is never empty at the access site.
    if (list.length == 1) {
      return list.first;
    }

    if (list.length == 2) {
      return '${list.first}$doubleJoiner${list.last}';
    }

    // 3+ items: lead items joined by [joiner], then the Oxford [lastJoiner].
    return list.takeSafe(list.length - 1).join(joiner) + lastJoiner + list.last;
  }

  /// Returns the longest common prefix of all strings in this list.
  ///
  /// Returns empty string if list is empty or any element is empty.
  ///
  /// Example:
  /// ```dart
  /// ['flower', 'flow', 'flight'].commonPrefix();  // 'fl'
  /// ['a', 'b'].commonPrefix();  // ''
  /// ```
  @useResult
  String commonPrefix() {
    if (isEmpty) return '';
    String prefix = this[0];
    for (int i = 1; i < length; i++) {
      final String s = this[i];
      final int maxLen = prefix.length < s.length ? prefix.length : s.length;
      int j = 0;
      while (j < maxLen && prefix[j] == s[j]) {
        j++;
      }
      prefix = prefix.replaceRange(j, prefix.length, '');
      if (prefix.isEmpty) return '';
    }
    return prefix;
  }

  /// Returns the longest common suffix of all strings in this list.
  ///
  /// Returns empty string if list is empty or any element is empty.
  ///
  /// Example:
  /// ```dart
  /// ['ending', 'ding'].commonSuffix();  // 'ing'
  /// ```
  @useResult
  String commonSuffix() {
    if (isEmpty) return '';
    String suffix = this[0];
    for (int i = 1; i < length; i++) {
      final String s = this[i];
      final int maxLen = suffix.length < s.length ? suffix.length : s.length;
      int j = 0;
      while (j < maxLen && suffix[suffix.length - 1 - j] == s[s.length - 1 - j]) {
        j++;
      }
      suffix = suffix.replaceRange(0, suffix.length - j, '');
      if (suffix.isEmpty) return '';
    }
    return suffix;
  }

  /// Returns the first element that is not equal to [value].
  ///
  /// When [value] is `null` the comparison is skipped and the first element is
  /// returned (or `null` for an empty list). Comparison is case-sensitive, so
  /// `firstNotEqualTo('a')` does not match `'A'`. Returns `null` when every
  /// element equals [value], distinguishing "no differing element" from a real
  /// hit.
  ///
  /// Example:
  /// ```dart
  /// ['a', 'a', 'b'].firstNotEqualTo('a'); // 'b'
  /// ['a', 'b'].firstNotEqualTo(null);     // 'a'
  /// ['a', 'a'].firstNotEqualTo('a');      // null
  /// ```
  @useResult
  String? firstNotEqualTo(String? value) =>
      // The package:collection accessors return null instead of throwing when no
      // element qualifies, so an all-equal or empty list yields null cleanly.
      value == null ? firstOrNull : firstWhereOrNull((String item) => item != value);

  /// Joins these strings into a sentence with a distinct final connector, e.g.
  /// `['a', 'b', 'c'].joinWithFinal()` -> `'a, b and c'`.
  ///
  /// Unlike [joinDisplayList] this adds **no** Oxford comma before the final
  /// connector (British style), and it does **no** trimming or de-duplication —
  /// a blank entry is kept, so `['a', '', 'c']` yields `'a,  and c'`. Returns
  /// `null` for an empty list and the sole element for a single-item list, so a
  /// caller can tell "no items" apart from a real joined string.
  ///
  /// - [separator]: placed between the leading items (default `', '`).
  /// - [finalSeparator]: the connector word before the last item (default
  ///   `'and'`); it is surrounded by single spaces.
  ///
  /// Example:
  /// ```dart
  /// ['Alice', 'Bob'].joinWithFinal();          // 'Alice and Bob'
  /// ['Alice', 'Bob', 'Carol'].joinWithFinal(); // 'Alice, Bob and Carol'
  /// <String>[].joinWithFinal();                // null
  /// ```
  @useResult
  String? joinWithFinal({String separator = ', ', String finalSeparator = 'and'}) {
    if (isEmpty) {
      return null;
    }

    if (length == 1) {
      return firstOrNull;
    }

    // sublist(0, length - 1) drops the final element so [finalSeparator] (not
    // [separator]) precedes it; `last` is safe because length >= 2 here.
    return '${sublist(0, length - 1).join(separator)} '
        '$finalSeparator $last';
  }

  /// Returns `true` if any element contains [check] as a substring.
  ///
  /// A `null` or empty [check], or an empty list, returns `false` (there is no
  /// meaningful substring to look for). When [caseSensitive] is `false` both
  /// sides are lowercased with the invariant culture before comparing.
  ///
  /// Example:
  /// ```dart
  /// ['HelloWorld'].anyContains('world', caseSensitive: false); // true
  /// ['HelloWorld'].anyContains('world', caseSensitive: true);  // false
  /// <String>[].anyContains('x');                               // false
  /// ```
  @useResult
  bool anyContains(String? check, {bool caseSensitive = true}) {
    if (isEmpty) {
      return false;
    }

    // A null/empty needle has no substring to match; short-circuit before any
    // per-element scan so a 1M-element list still returns immediately.
    if (check == null || check.isEmpty) {
      return false;
    }

    if (caseSensitive) {
      return any((String e) => e.contains(check));
    }

    // Lowercase the needle once outside the scan rather than per element.
    final String checkLower = check.toLowerCase();
    return any((String e) => e.toLowerCase().contains(checkLower));
  }

  /// Drops entries that are empty after trimming, returning a new list.
  ///
  /// With [trim] `true` (default) the survivors are also trimmed; with [trim]
  /// `false` only literally empty (`''`) entries are dropped — a whitespace-only
  /// `'   '` is kept untouched. Returns `null` (never `[]`) when nothing
  /// remains, so a caller distinguishes "no items" from a real result. Does not
  /// mutate the receiver.
  ///
  /// Example:
  /// ```dart
  /// [' a ', 'b'].removeTrimmedEmpty();              // ['a', 'b']
  /// [' a ', '   '].removeTrimmedEmpty(trim: false); // [' a ']
  /// ['', '  '].removeTrimmedEmpty();                // null
  /// ```
  @useResult
  List<String>? removeTrimmedEmpty({bool trim = true}) =>
      // The per-element nullable trimmer enforces the trim-vs-keep contract,
      // the null filter strips dropped entries, and the list helper collapses
      // an empty result to null rather than an empty list.
      map((String e) => e.nullIfEmpty(trimFirst: trim)).nonNulls.toList().nullIfEmpty();

  /// Returns a new list with every element lowercased (invariant culture).
  ///
  /// Casing is locale-independent: Turkish `'I'` lowercases to `'i'`, never the
  /// dotless `'ı'`. Surrogate pairs and emoji round-trip unchanged. Does not
  /// mutate the receiver. The return is nullable for symmetry with
  /// [removeTrimmedEmpty], but a non-empty list always yields a non-empty list.
  ///
  /// Example:
  /// ```dart
  /// ['Ab', 'CD'].toLowerCase(); // ['ab', 'cd']
  /// ```
  @useResult
  List<String>? toLowerCase() => map((String e) => e.toLowerCase()).toList();

  /// Returns a new list with every element uppercased (invariant culture).
  ///
  /// Casing is locale-independent: Turkish `'i'` uppercases to `'I'`, never the
  /// dotted `'İ'`. Dart's `String.toUpperCase()` is a 1:1 code-point mapping and
  /// does NOT special-case the German eszett, so `'ß'` stays `'ß'` (it is NOT
  /// expanded to `'SS'`). Surrogate pairs and emoji round-trip unchanged. Does
  /// not mutate the receiver.
  ///
  /// Example:
  /// ```dart
  /// ['Ab', 'cd'].toUpperCase(); // ['AB', 'CD']
  /// ```
  @useResult
  List<String>? toUpperCase() => map((String e) => e.toUpperCase()).toList();
}

/// Extensions on `List<String?>` mirroring [ListStringExtensions], with nulls
/// dropped first via core-Dart `nonNulls`.
extension NullableListStringExtensions on List<String?> {
  /// Drops nulls, then lowercases each survivor (invariant culture).
  ///
  /// See [ListStringExtensions.toLowerCase] for casing semantics. Does not
  /// mutate the receiver.
  ///
  /// Example:
  /// ```dart
  /// <String?>['Ab', null, 'CD'].toLowerCase(); // ['ab', 'cd']
  /// ```
  @useResult
  List<String>? toLowerCase() => nonNulls.toList().toLowerCase();

  /// Drops nulls, then uppercases each survivor (invariant culture).
  ///
  /// See [ListStringExtensions.toUpperCase] for casing semantics. Does not
  /// mutate the receiver.
  ///
  /// Example:
  /// ```dart
  /// <String?>['Ab', null, 'cd'].toUpperCase(); // ['AB', 'CD']
  /// ```
  @useResult
  List<String>? toUpperCase() => nonNulls.toList().toUpperCase();

  /// Drops nulls, then applies [ListStringExtensions.removeTrimmedEmpty].
  ///
  /// Returns `null` (never `[]`) when nothing remains after removing nulls and
  /// trimmed-empty entries. Does not mutate the receiver.
  ///
  /// Example:
  /// ```dart
  /// <String?>[null, '', 'abc'].removeNullsAndTrimmedEmpty(); // ['abc']
  /// <String?>[null, ' ', null].removeNullsAndTrimmedEmpty(); // null
  /// ```
  @useResult
  List<String>? removeNullsAndTrimmedEmpty({bool trim = true}) =>
      nonNulls.toList().removeTrimmedEmpty(trim: trim);
}
