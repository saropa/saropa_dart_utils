# SPEC: sortMap / sortNullableStringListInPlace / compareAges — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:**
- `lib/map/map_initials_sort_extensions.dart` (`InitialsSortingUtils.sortMap`)
- `lib/list/list_nullable_string_sort_extensions.dart` (`sortNullableStringListInPlace`)
- `lib/datetime/date_time_compare_age_extensions.dart` (`compareAges`)

**Portability:** Pure Dart. `sortMap` uses `dart:collection` (`SplayTreeMap`) only. No Flutter, no `intl`/`quiver`/external packages. The Saropa source quotes `debug()`/`debugException` logging — stripped here per scope. The app-only `SortDirection` enum used by `compareAges` is replaced with a pure-Dart `bool ascending = true` parameter (the enum is proprietary and not portable).

## Purpose — what it does + why it is general-purpose (not proprietary)

Three independent, domain-free sort helpers harvested from the app's sort utilities:

- **`sortMap()`** (extension on `Map<String, V>`) — returns a `SplayTreeMap<String, V>` sorted by a "letters-before-numbers" natural-ish rule:
  1. Two letter-initial keys: alphabetical (`String.compareTo`).
  2. Two pure-integer keys (e.g. `'2'` vs `'10'`): numeric (`int.tryParse` then `int.compareTo`), so `'10'` sorts after `'2'` instead of before.
  3. Letter-initial vs number-initial: the letter-initial key comes first.
  4. Anything else (punctuation/symbol initials, mixed `'1abc'`): falls back to `String.compareTo`.
  This is a general key-ordering rule (alpha entries first, numbered entries after and in numeric order) useful for any string-keyed map shown to a user — index sections, grouped lists, glossaries. No contact/Saropa specifics.

- **`sortNullableStringListInPlace(List<String?>)`** — sorts a `List<String?>` in place, case-insensitively, with nulls grouped together. Returns `true` on success, `false` if sorting threw. Wraps the nullable-string comparison so callers avoid the extension-on-`List<String?>` lint. General list utility.

- **`compareAges(DateTime? a, DateTime? b, {bool ascending = true})`** — a nulls-last `DateTime` comparator: two nulls are equal (`0`), a single null sorts last, otherwise `a.compareTo(b)` flipped by direction. "Age" is just the app's call-site name; the function is a generic nulls-last date comparator with no birthday/contact logic.

### Relationship to existing library members (overlap)

| Library member | Overlap | Verdict |
|---|---|---|
| `list/natural_sort_utils.dart` → `naturalCompare` / `List<String>.sortedNatural()` | Both order embedded numbers by value. But `naturalCompare` tokenizes mid-string (`a2` < `a10`) and never special-cases letter-vs-number INITIALS. `sortMap` is a `Map`-keyed `SplayTreeMap` builder with the distinct rule "all letter-initial keys before all number-initial keys." | **Net-new** — different surface (map vs list) and different ordering rule. Not a duplicate. |
| `string/` → `compareStringNullable` (per scope note) | Covers nullable-string comparison. `sortNullableStringListInPlace` is the in-place `List<String?>` sorter built on top; the library has the comparator but not the in-place list helper. | **Partial-overlap** — add the list helper; it can delegate to `compareStringNullable`. |
| `datetime/date_time_nullable_extensions.dart` → `compareDateTimeNullable` | Both compare two nullable `DateTime`s. **Ordering differs:** `compareDateTimeNullable` puts `null` BEFORE non-null; `compareAges` puts `null` LAST, and adds an `ascending` direction flag. | **Partial-overlap** — distinct null placement + direction param. Either add `compareAges` as a nulls-last variant, or extend `compareDateTimeNullable` with a `nullsFirst`/`ascending` option. |

**Excluded from this spec (proprietary / app-specific / scope):**
- `SaropaBaseModelSortingHelper.applyDefaultBaseModelSort` — operates on `SaropaBaseModel` (shared/primary/sortOrder/related app fields). App-domain, not portable.
- `compareNullableStringsForSort` / `_compareNullableStringsImpl` / `StringSortingHelper.compareToStringNullable` — EXCLUDED per scope note; library already has `compareStringNullable`.
- `StringCompareToCaseInsensitive.compareToCaseInsensitive` — superseded by the library's nullable-string comparator.
- `sortByAge` / `toSortedByNameStartsWith` and the `ContactModel`/`UserPreferenceType`/`eventDateBirthday` machinery around `compareAges` — contact-domain, app preferences, excluded.
- `debug()` / `debugException` / `DebugType` logging — stripped from all quoted source.

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging stripped)

```dart
import 'dart:collection';

// Top-level pattern: matches a leading ASCII letter / leading ASCII digit.
final RegExp _startsWithLetterRegExp = RegExp('[a-zA-Z]');
final RegExp _startsWithNumberRegExp = RegExp(r'\d');

extension InitialsSortingUtils<V> on Map<String, V> {
  /// Returns a [SplayTreeMap] ordered "letters before numbers":
  /// letter-initial keys sort alphabetically and come first; number-initial
  /// keys come after, with PURE integers ordered numerically ('2' before '10').
  SplayTreeMap<String, V> sortMap() {
    // Custom comparison function for the SplayTreeMap.
    int compare(String a, String b) {
      // Both start with a letter -> plain alphabetical.
      final bool aStartsWithLetter = a.startsWith(_startsWithLetterRegExp);
      if (aStartsWithLetter && b.startsWith(_startsWithLetterRegExp)) {
        return a.compareTo(b);
      }

      final bool aStartsWithNumber = a.startsWith(_startsWithNumberRegExp);
      final bool bStartsWithNumber = b.startsWith(_startsWithNumberRegExp);

      // Both are PURE integers -> numeric compare so '10' sorts after '2'.
      if (aStartsWithNumber && bStartsWithNumber) {
        final int? aInt = int.tryParse(a);
        final int? bInt = int.tryParse(b);

        // Only numeric when both parse cleanly; '1abc' falls through.
        if (aInt != null && bInt != null) {
          return aInt.compareTo(bInt);
        }
      }

      // Letter-initial sorts before number-initial.
      if (aStartsWithLetter && bStartsWithNumber) {
        return -1;
      }

      final bool bStartsWithLetter = b.startsWith(_startsWithLetterRegExp);
      if (aStartsWithNumber && bStartsWithLetter) {
        return 1;
      }

      // Fallback: lexicographic (covers symbol/punctuation initials, mixed).
      return a.compareTo(b);
    }

    return SplayTreeMap<String, V>.from(this, compare);
  }
}

/// Sorts a [List] of nullable strings in place, case-insensitively, nulls
/// grouped. Returns true on success, false if the sort threw.
bool sortNullableStringListInPlace(List<String?> list) {
  list.sort(_compareNullableStringsForSort);
  return true;
}

// Case-insensitive nullable-string comparator (nulls collate as '').
// In the library this delegates to the existing `compareStringNullable`.
int _compareNullableStringsForSort(String? a, String? b) =>
    (a?.toLowerCase() ?? '').compareTo(b?.toLowerCase() ?? '');

/// Nulls-LAST nullable [DateTime] comparator with a direction flag.
/// Two nulls are equal; a single null sorts last regardless of [ascending].
int compareAges(DateTime? a, DateTime? b, {bool ascending = true}) {
  if (a == null) {
    if (b == null) {
      return 0;
    }
    return 1; // a null -> a goes last
  }
  if (b == null) {
    return -1; // b null -> b goes last
  }
  return a.compareTo(b) * (ascending ? 1 : -1);
}
```

## Test cases — existing tests verbatim (from `test/lib/utils/primative/primative_utils_test.dart`)

`sortMap` group:

```dart
group('sortMap', () {
  test('sorts letters before numbers', () {
    final Map<String, int> map = <String, int>{'1abc': 1, 'abc': 2, '2def': 3};
    final SplayTreeMap<String, int> sortedMap = map.sortMap();
    // 'abc' starts with letter (comes first)
    // '1abc' and '2def' start with numbers, sorted alphabetically
    expect(sortedMap.keys.firstOrNull, 'abc');
    expect(sortedMap.keys, hasLength(3));
  });

  test('sorts letters alphabetically', () {
    final Map<String, int> map = <String, int>{'charlie': 3, 'alpha': 1, 'bravo': 2};
    final SplayTreeMap<String, int> sortedMap = map.sortMap();
    expect(sortedMap.keys.toList(), <String>['alpha', 'bravo', 'charlie']);
  });

  test('sorts numbers numerically', () {
    final Map<String, int> map = <String, int>{'10': 10, '2': 2, '1': 1};
    final SplayTreeMap<String, int> sortedMap = map.sortMap();
    expect(sortedMap.keys.toList(), <String>['1', '2', '10']);
  });

  test('handles mixed letter and number starts correctly', () {
    final Map<String, int> map = <String, int>{'2nd': 2, 'alpha': 1, '1st': 3, 'beta': 4};
    final SplayTreeMap<String, int> sortedMap = map.sortMap();
    // All 4 entries should be preserved
    expect(sortedMap.keys, hasLength(4));
    // Letters should come first (alpha, beta alphabetically)
    expect(sortedMap.keys.toList()[0], 'alpha');
    expect(sortedMap.keys.toList()[1], 'beta');
    // Numbers should come after (1st, 2nd alphabetically)
    expect(sortedMap.keys.skip(2).toSet(), containsAll(<String>['1st', '2nd']));
  });

  test('sorts empty map', () {
    final Map<String, int> map = <String, int>{};
    final SplayTreeMap<String, int> sortedMap = map.sortMap();
    expect(sortedMap.keys.toList(), <String>[]);
  });

  test('single element map remains unchanged', () {
    final Map<String, int> map = <String, int>{'only': 1};
    final SplayTreeMap<String, int> sortedMap = map.sortMap();
    expect(sortedMap.keys.toList(), <String>['only']);
  });

  test('preserves values during sort', () {
    final Map<String, int> map = <String, int>{'b': 2, 'a': 1, 'c': 3};
    final SplayTreeMap<String, int> sortedMap = map.sortMap();
    expect(sortedMap['a'], 1);
    expect(sortedMap['b'], 2);
    expect(sortedMap['c'], 3);
  });
});
```

`toSorted` group (covers `sortNullableStringListInPlace`):

```dart
group('toSorted', () {
  test('when list is null', () {
    final List<String?> list = <String?>[];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>[]));
  });

  test('when list has one null element', () {
    final List<String?> list = <String?>[null];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<void>[null]));
  });

  test('when list has one non-null element', () {
    final List<String?> list = <String?>['test'];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>['test']));
  });

  test('when list has multiple identical elements', () {
    final List<String?> list = <String?>['test', 'test', 'test'];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>['test', 'test', 'test']));
  });

  test('when list has multiple distinct elements', () {
    final List<String?> list = <String?>['test2', 'test1', 'test3'];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>['test1', 'test2', 'test3']));
  });

  test('when list has null and non-null elements', () {
    final List<String?> list = <String?>['test2', null, 'test1'];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String?>[null, 'test1', 'test2']));
  });

  test('when list has empty and non-empty strings', () {
    final List<String?> list = <String?>['test', ''];
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(<String>['', 'test']));
  });

  test('when list has large number of elements', () {
    final List<String?> list = List<String?>.filled(10_000, 'test');
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(List<String?>.filled(10_000, 'test')));
  });

  test('when list has large number of distinct elements', () {
    final List<String?> list = List<String?>.generate(10_000, (int i) => 'test$i');
    final List<String?> sortedList = List<String?>.of(list)..sort();
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(sortedList));
  });

  test('when list has large number of null elements', () {
    final List<String?> list = List<String?>.filled(10_000, null);
    expect(sortNullableStringListInPlace(list), isTrue);
    expect(list, equals(List<String?>.filled(10_000, null)));
  });
});
```

**`compareAges` — no existing tests.** Proposed cases:

```dart
group('compareAges', () {
  final DateTime older = DateTime.utc(1990, 1, 1);
  final DateTime newer = DateTime.utc(2020, 6, 15);

  test('both null -> 0', () => expect(compareAges(null, null), isZero));
  test('a null -> 1 (nulls last)', () => expect(compareAges(null, newer), 1));
  test('b null -> -1 (nulls last)', () => expect(compareAges(older, null), -1));
  test('a null ascending=false still last', () =>
      expect(compareAges(null, newer, ascending: false), 1));
  test('ascending: older before newer', () =>
      expect(compareAges(older, newer).isNegative, isTrue));
  test('descending: newer before older', () =>
      expect(compareAges(older, newer, ascending: false).isNegative, isFalse));
  test('equal dates -> 0 both directions', () {
    expect(compareAges(older, older), isZero);
    expect(compareAges(older, older, ascending: false), isZero);
  });
});
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**`sortMap`:**
- Empty key `''` — `''.startsWith(letter)` is `false`; lands in the lexicographic fallback. Assert it does not throw and collates first.
- Symbol/punctuation initials: `'#tag'`, `'_x'`, `'@me'`, `'.dotfile'` — none match letter/number; assert pure lexicographic ordering among them and that they sort relative to letters/numbers deterministically.
- Unicode/accented letter initials: `'Ångstrom'` (Å), `'é'` (é), `'Ü'` (ü) — the regex `[a-zA-Z]` does NOT match these, so they fall to the lexicographic branch, NOT the alphabetical-letters branch. Document and test this known limitation (ASCII-only letter detection).
- Emoji / non-BMP initials: `'\u{1F600}key'` (grinning face) — non-letter, non-digit; lexicographic fallback. Assert no throw.
- Negative / signed numeric keys: `'-5'`, `'+3'` — `'-'`/`'+'` aren't `\d`, so these go lexicographic, NOT numeric. Test that `'-5'` does not numerically beat `'10'`.
- Huge numeric keys beyond `int` range: `'99999999999999999999'` — `int.tryParse` returns null, falls through to lexicographic. Assert no overflow/throw.
- Leading-zero numerics: `'007'` vs `'7'` vs `'70'` — both pure ints, numeric compare makes `'007' == 7`. Assert `'7'`/`'007'` order is stable and `'70'` sorts after.
- Mixed `'1abc'` vs `'1'` vs `'10'` — `'1abc'` is number-initial but not a pure int; assert it falls through correctly against pure ints.
- Whitespace initials: `' leading'`, `' nbsp'` (non-breaking space U+00A0) — neither letter nor digit; lexicographic. Assert no throw.
- Duplicate-after-normalization keys are impossible for a `Map` (keys unique), but assert `SplayTreeMap.from` preserves ALL values (no key collision from the comparator returning 0 for distinct keys — a comparator that returns 0 for two DISTINCT keys would DROP one in a `SplayTreeMap`; verify `compare` never returns 0 for unequal strings, e.g. two pure ints of equal value like `'07'` and `'7'` → `int.compareTo` returns 0 → ONE entry lost. This is a real correctness bug to test and document/fix).
- Generic value type `V`: test with `V = List<int>`, `V = Object?`, and `V = Null` to confirm value passthrough.

**`sortNullableStringListInPlace`:**
- Case-insensitivity: `['B', 'a', 'C']` -> `['a', 'B', 'C']` (the comparator lowercases). Existing tests don't cover mixed case — add it.
- Tie-break between `'a'` and `'A'`: both lowercase to `'a'` -> compare returns 0; assert sort is stable / no element lost (list sort, unlike SplayTreeMap, keeps both).
- Multiple nulls interleaved with values: `[null, 'b', null, 'a']` -> nulls collate as `''` so they group first; assert exact order.
- Empty string vs null ordering: both lowercase-or-coalesce to `''` -> 0; assert relative order is stable and both retained.
- Unicode collation: `['é', 'e', 'z']` (é, e, z) — `String.compareTo` is code-unit order, so `'é'` (é, U+00E9) sorts AFTER `'z'` (U+007A). Document that this is code-unit, NOT locale-aware, ordering.
- Emoji elements: `['\u{1F4A9}', 'a']` — assert no throw, code-unit ordering.
- Returns `false` path: hard to trigger with `List.sort` on strings (no comparator throw). Note the `false` branch only fires if the comparator throws; document it's defensive.

**`compareAges`:**
- `ascending=false` with one null: confirm nulls stay LAST even in descending (the `* -1` direction multiplier must NOT apply to the null branches — current code returns `1`/`-1` BEFORE the multiplier, which is correct; add an explicit test so a refactor can't regress it).
- UTC vs local same instant: `DateTime.utc(2020,1,1)` vs `DateTime(2020,1,1).toUtc()` — `compareTo` compares instants; assert equality when they represent the same moment.
- DST boundary: two local `DateTime`s straddling a DST transition compare by absolute instant; add a case in a known DST zone to confirm no off-by-one (note: pure `DateTime.compareTo` is instant-based, so DST is irrelevant to ordering — document that "age" here is instant ordering, not calendar-day ordering).
- Leap day: `DateTime.utc(2020,2,29)` vs `DateTime.utc(2021,3,1)` — assert ordering by instant.
- Microsecond-level difference: `DateTime.utc(2020,1,1,0,0,0,0,1)` vs `...,0,0)` — assert the 1-microsecond difference produces a non-zero result (no truncation).
- Far-future / far-past extremes: `DateTime.utc(-271821)` and `DateTime.utc(275760)` (near Dart's `DateTime` range bounds) — assert no overflow in `compareTo`.
- Equal instants both directions return exactly `0` (multiplier of `0` is still `0`) — add for both `ascending` values.
