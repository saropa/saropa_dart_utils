import 'dart:collection';

import 'package:meta/meta.dart';

// Leading-character classifiers, compiled once at top level so every `sortMap`
// call reuses the same RegExp instances instead of recompiling per comparison.
// ASCII-only by design: `[a-zA-Z]` does NOT match accented Latin letters (`Å`,
// `é`, `Ü`) or non-Latin scripts, so those keys fall to the lexicographic
// fallback rather than the alphabetical-letters branch. This is a documented
// limitation, not a bug — see `sortMap`'s dartdoc.
final RegExp _startsWithLetterRegExp = RegExp('[a-zA-Z]');
final RegExp _startsWithNumberRegExp = RegExp(r'\d');

/// Ordering helpers for string-keyed maps shown to a user — index sections,
/// grouped lists, glossaries.
extension InitialsSortingUtils<V> on Map<String, V> {
  /// Returns a [SplayTreeMap] ordered "letters before numbers".
  ///
  /// Letter-initial keys sort alphabetically and come first; number-initial
  /// keys come after, with PURE integers ordered numerically so `'10'` sorts
  /// after `'2'` instead of before it (the trap of plain lexicographic order).
  /// Anything else — punctuation/symbol initials, mixed `'1abc'`, accented or
  /// emoji initials, the empty key `''` — falls back to [String.compareTo].
  ///
  /// Ordering rules, in priority order:
  /// 1. Two letter-initial keys: alphabetical ([String.compareTo]).
  /// 2. Two pure-integer keys: numeric ([int.compareTo]).
  /// 3. Letter-initial vs number-initial: the letter key comes first.
  /// 4. Everything else: lexicographic ([String.compareTo]).
  ///
  /// Edge cases and known limitations:
  /// - ASCII-only letter detection: `'Ångstrom'`, `'é'`, `'Ü'` are NOT treated
  ///   as letter-initial because `[a-zA-Z]` excludes non-ASCII; they collate via
  ///   the lexicographic fallback.
  /// - Signed/huge numerics: `'-5'`, `'+3'`, and integers beyond the `int` range
  ///   are NOT pure integers ([int.tryParse] returns `null` or `'-'`/`'+'` is
  ///   not a digit), so they fall through to lexicographic order — `'-5'` does
  ///   NOT numerically beat `'10'`.
  /// - Leading-zero numerics: `'007'` and `'7'` are numerically equal, so the
  ///   comparator breaks the tie lexicographically to keep BOTH map entries.
  ///
  /// Example:
  /// ```dart
  /// <String, int>{'2def': 3, 'abc': 2, '10': 1}.sortMap().keys.toList();
  /// // ['abc', '2def', '10']  (letters first; numerics in numeric order)
  /// ```
  @useResult
  SplayTreeMap<String, V> sortMap() =>
      SplayTreeMap<String, V>.from(this, _compareInitials);
}

/// Comparator implementing the "letters before numbers" rule for [sortMap].
///
/// Pulled out as a top-level function (rather than a nested closure) to keep
/// `sortMap` a single expression and to stay within the project's per-function
/// line limit.
int _compareInitials(String a, String b) {
  final bool aLetter = a.startsWith(_startsWithLetterRegExp);
  final bool bLetter = b.startsWith(_startsWithLetterRegExp);

  // Rule 1 — both letter-initial: plain alphabetical.
  if (aLetter && bLetter) {
    return a.compareTo(b);
  }

  final bool aNumber = a.startsWith(_startsWithNumberRegExp);
  final bool bNumber = b.startsWith(_startsWithNumberRegExp);

  // Rule 2 — both pure integers: numeric so '10' sorts after '2'. A tie from
  // int.compareTo (e.g. '07' vs '7', both 7) is broken lexicographically;
  // returning 0 for two DISTINCT keys would make SplayTreeMap.from drop one of
  // them, silently losing a map entry. That correctness bug is the reason for
  // the secondary compareTo below.
  if (aNumber && bNumber) {
    final int? aInt = int.tryParse(a);
    final int? bInt = int.tryParse(b);
    if (aInt != null && bInt != null) {
      final int numeric = aInt.compareTo(bInt);
      return numeric != 0 ? numeric : a.compareTo(b);
    }
  }

  // Rule 3 — letter-initial sorts before number-initial (either orientation).
  if (aLetter && bNumber) {
    return -1;
  }
  if (aNumber && bLetter) {
    return 1;
  }

  // Rule 4 — fallback: lexicographic (symbol/punctuation/accented/mixed keys).
  return a.compareTo(b);
}
