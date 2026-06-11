# SPEC: compareStringFolded / foldedCompare / sortedFolded — diacritic-folding sort comparator

**Status:** Proposed (originated from a Saropa Contacts evaluation of the `lexical_sort` pub package, 2026-06-11)
**Proposed location:** `lib/string/string_folded_compare_extensions.dart`
**Proposed version:** ships in the next `saropa_dart_utils` release (current `pubspec.yaml` is `1.5.1` → target `1.5.2`/`1.6.0`).
**Portability:** Pure Dart. Composes three EXISTING, already-tested library members — no new logic, no external packages, no Flutter, no `intl`.

---

## Why this exists (the gap)

The library already has the pieces but no single comparator that combines them:

| Existing member | File | What it gives | What it lacks |
|---|---|---|---|
| `String.removeDiacritics()` | `string/string_diacritics_extensions.dart` | Folds `á→a`, `ß→ss`, `æ→ae`, `œ→oe`, full Latin-1 + Latin-Extended map (both cases) | It's a transformer, not a comparator |
| `naturalCompare` / `List<String>.sortedNatural()` | `niche/natural_sort_utils.dart` | Embedded numbers by value (`a2` < `a10`) | No diacritic folding, no case-fold, no null handling |
| `String?.compareStringNullable(...)` | `string/string_compare_extensions.dart` | Null-aware, optional case-insensitive `String.compareTo` | Code-unit order, NOT folded. Its own docstring says: *"For human-facing alphabetic order across diacritics, **fold/normalize the inputs first**."* |

`compareStringFolded` is exactly the "fold first" comparator that `compareStringNullable`'s docstring tells callers to build. It makes `"Ángel"` sort with the **A** names instead of after `"Zoe"` (because `Á` is U+00C1, far above ASCII `z`), and makes mixed-case ordering stable.

### Relationship to `lexical_sort` (the package that prompted this)

`lexical_sort` (pub.dev, ported from a Rust crate) does the same folding (`á→a`, `ß→ss`), case-insensitivity, natural numbers, and a deterministic scalar-value tie-break. This spec reproduces those semantics from in-house, already-shipped, already-tested members instead of taking a brand-new third-party dependency. The one behavior we deliberately MATCH from `lexical_sort` is the **deterministic tie-break**: when two distinct strings fold to the same key (`"Foo"` vs `"fóò"`), fall back to raw `String.compareTo` so the comparator NEVER returns `0` for unequal strings (critical for `SplayTreeMap` keys, which silently drop a key on a `0` compare).

---

## API

One file, three public surfaces (mirrors the `naturalCompare` + `sortedNatural` + `compareStringNullable` shape already in the library).

```dart
/// Compares two nullable strings as a human would read a contact/name list:
/// diacritics folded (á→a, ß→ss), case-insensitive by default, optional
/// natural numeric ordering, nulls grouped, and a deterministic tie-break so
/// distinct strings never compare equal.
///
/// Pipeline per side: removeDiacritics() → (optional) toLowerCase().
/// Primary compare: naturalCompare(folded) when [natural], else
/// folded.compareTo(folded). On a 0 primary result the raw (unfolded,
/// original-case) values are compared with String.compareTo so two strings
/// that fold to the same key ("Foo" vs "fóò") still order deterministically
/// — never 0 unless the originals are identical.
extension StringFoldedCompareExtensions on String? {
  int compareStringFolded(
    String? other, {
    bool caseSensitive = false,
    bool nullsLast = false,
    bool natural = false,
  });
}

/// Comparator-shaped free function (for List.sort / SplayTreeMap / sort keys),
/// since tearing off an extension method into a `Comparator<String?>` is awkward.
/// Delegates to [StringFoldedCompareExtensions.compareStringFolded].
int foldedCompare(
  String? a,
  String? b, {
  bool caseSensitive = false,
  bool nullsLast = false,
  bool natural = false,
});

/// Returns a NEW list sorted with [foldedCompare]. Original is not modified.
extension FoldedSortExtension on List<String> {
  List<String> sortedFolded({bool natural = false});
}
```

### Algorithm (exact, in order)

1. **Null branch** — identical convention to `compareStringNullable`: both null → `0`; exactly one null → `nullsLast ? (self-null:1 / other-null:-1) : (self-null:-1 / other-null:1)`. The direction flip happens BEFORE any folding; nulls never reach the fold step.
2. **Fold** — `final String fa = a.removeDiacritics(); final String fb = b.removeDiacritics();`
3. **Case** — if `!caseSensitive`: `fa = fa.toLowerCase(); fb = fb.toLowerCase();`
4. **Primary compare** — `final int primary = natural ? naturalCompare(fa, fb) : fa.compareTo(fb);`
5. **Return primary if non-zero.**
6. **Deterministic tie-break** — `primary == 0` means the folded/cased keys match. Return `a.compareTo(b)` on the **raw, original-case** strings. This is the only branch that can still return `0`, and only when `a == b` exactly.

> Note on ligature folding + natural: `removeDiacritics()` expands `ß→ss` and `æ→ae`, changing string length. That is fine for both `compareTo` and `naturalCompare` (the latter re-tokenizes the folded string). Document that folding runs BEFORE tokenization so `"Straße"` and `"Strasse"` collate equal (then tie-break by raw).

### Reference implementation (drop-in)

```dart
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/niche/natural_sort_utils.dart';
import 'package:saropa_dart_utils/string/string_diacritics_extensions.dart';

extension StringFoldedCompareExtensions on String? {
  @useResult
  int compareStringFolded(
    String? other, {
    bool caseSensitive = false,
    bool nullsLast = false,
    bool natural = false,
  }) {
    final String? self = this;

    if (self == null && other == null) {
      return 0;
    }
    if (self == null) {
      return nullsLast ? 1 : -1;
    }
    if (other == null) {
      return nullsLast ? -1 : 1;
    }

    // Fold diacritics so accented Latin interfiles with its base letter
    // (á with a) instead of sorting after z by code unit.
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

    // Folded keys tie ("Foo" vs "fóò"): deterministic scalar tie-break on the
    // raw originals so the comparator never returns 0 for unequal strings —
    // required for SplayTreeMap keys (a 0 compare silently drops a key).
    return self.compareTo(other);
  }
}

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

extension FoldedSortExtension on List<String> {
  @useResult
  List<String> sortedFolded({bool natural = false}) =>
      List<String>.of(this)..sort((String a, String b) => foldedCompare(a, b, natural: natural));
}
```

(Adjust the two `import` paths to whatever the library barrel re-exports; the repo may prefer importing through `package:saropa_dart_utils/saropa_dart_utils.dart`.)

---

## What it does NOT do (scope boundaries — match `lexical_sort` honestly)

- **Non-Latin scripts pass through unchanged.** `removeDiacritics()` only maps Latin diacritics/ligatures; CJK, Cyrillic, Arabic, Greek, Hebrew, etc. are not transliterated. They then sort by `String.compareTo` (code unit), which places them AFTER all ASCII. This is a FEATURE for the Saropa Contacts caller (it wants Latin-before-non-Latin), but it is NOT locale-aware collation. Document plainly: "Latin-focused folding; non-Latin orders by code point."
- **No locale/ICU collation.** No `intl`, no `Collator`. Turkish dotless-i, German phonebook-ß, Swedish å-after-z, etc. are NOT honored. Out of scope; note it.
- **No "alphanumeric sorts after punctuation" rule.** `lexical_sort` has `onlyAlnum*` variants that skip non-alphanumerics. This spec does NOT replicate those — the Saropa caller already buckets numbers/symbols itself. If a future caller needs alnum-skipping, add a separate `onlyAlnum` flag in a follow-up; do not bloat this comparator now.
- **BMP + astral both fine for compare** (we never classify code points here, only fold-and-compare), so emoji/surrogate input does not throw — it just folds to itself and compares by code unit.

---

## Test cases — author these for full coverage

```dart
group('compareStringFolded / foldedCompare', () {
  // --- Core folding ---
  test('accented Latin interfiles with base letter (the headline fix)', () {
    final List<String> names = <String>['Zoe', 'Ángel', 'Andy', 'Bob'];
    expect(names.sortedFolded(), <String>['Andy', 'Ángel', 'Bob', 'Zoe']);
    // Without folding, raw sort would put 'Ángel' (U+00C1) AFTER 'Zoe'.
  });
  test('ß folds to ss', () => expect(foldedCompare('Straße', 'Strasse').isNegative
      || foldedCompare('Straße', 'Strasse') == 0, isTrue)); // equal-fold → tie-break
  test('æ folds to ae', () => expect(foldedCompare('Æsir', 'aesir'), isNonNegative)); // equal-fold, tie-break by raw case

  // --- Case-insensitivity (default) ---
  test('default is case-insensitive', () => expect(foldedCompare('apple', 'Apple') == 0
      ? true : foldedCompare('apple', 'Apple') != 0, isTrue)); // fold-equal → raw tie-break, never throws
  test('Bob before alice case-insensitively', () =>
      expect(foldedCompare('Bob', 'alice'), isPositive)); // b > a, case-folded
  test('caseSensitive: true uses raw order', () =>
      expect(foldedCompare('Bob', 'alice', caseSensitive: true), isNegative)); // 'B'(66) < 'a'(97)

  // --- Deterministic tie-break (the lexical_sort guarantee) ---
  test('distinct strings that fold equal never return 0', () {
    expect(foldedCompare('Foo', 'fóò'), isNot(0));
    expect(foldedCompare('fóò', 'Foo'), isNot(0));
    // Antisymmetry: a<b ⇒ b>a
    expect(foldedCompare('Foo', 'fóò').sign, -foldedCompare('fóò', 'Foo').sign);
  });
  test('identical strings return exactly 0', () => expect(foldedCompare('Foo', 'Foo'), isZero));

  // --- Natural numbers ---
  test('natural: img2 before img10', () =>
      expect(<String>['img10', 'img2', 'img1'].sortedFolded(natural: true),
          <String>['img1', 'img2', 'img10']));
  test('non-natural keeps lexicographic', () =>
      expect(<String>['img10', 'img2'].sortedFolded(),
          <String>['img10', 'img2'])); // '1' < '2' by char

  // --- Nulls ---
  test('both null → 0', () => expect(foldedCompare(null, null), isZero));
  test('null first by default', () => expect(foldedCompare(null, 'a'), -1));
  test('nullsLast pushes null to end', () => expect(foldedCompare(null, 'a', nullsLast: true), 1));
  test('nulls ignore folding/case entirely', () =>
      expect(foldedCompare(null, 'Ángel', nullsLast: true), 1));

  // --- Non-Latin pass-through (documented limitation) ---
  test('Latin sorts before CJK/Cyrillic', () {
    // 'Zoe' vs '李' (U+674E) vs 'Иван' (U+0418): Latin first, then by code point.
    final List<String> mixed = <String>['李', 'Zoe', 'Иван', 'Andy'];
    final List<String> sorted = mixed.sortedFolded();
    expect(sorted.indexOf('Andy') < sorted.indexOf('Zoe'), isTrue);
    expect(sorted.indexOf('Zoe') < sorted.indexOf('李'), isTrue);
    expect(sorted.indexOf('Zoe') < sorted.indexOf('Иван'), isTrue);
  });

  // --- SplayTreeMap safety (the reason for the tie-break) ---
  test('usable as SplayTreeMap comparator without dropping fold-equal keys', () {
    final SplayTreeMap<String, int> m =
        SplayTreeMap<String, int>((String a, String b) => foldedCompare(a, b));
    m['Foo'] = 1;
    m['fóò'] = 2; // folds to 'foo' too — must NOT overwrite 'Foo'
    expect(m, hasLength(2));
  });

  // --- Edge cases ---
  test('empty string vs non-empty', () => expect(foldedCompare('', 'a'), isNegative));
  test('both empty → 0', () => expect(foldedCompare('', ''), isZero));
  test('emoji input does not throw', () => expect(() => foldedCompare('\u{1F600}', 'a'), returnsNormally));
  test('whitespace-only strings compare by raw', () => expect(foldedCompare('  ', ' '), isPositive));
});
```

### Bulletproofing gaps to add

- **Antisymmetry sweep:** for a fixed sample set, assert `foldedCompare(a,b).sign == -foldedCompare(b,a).sign` for ALL pairs (a comparator that violates this corrupts `List.sort`).
- **Transitivity spot-check:** `a<b && b<c ⇒ a<c` on a folded-collision triple like `['Foo','fÒo','FOO']`.
- **`natural` + ligature length change:** `'Straße2'` vs `'Strasse10'` — folding expands `ß` before tokenizing; assert `'Straße2'` (→`strasse2`) sorts before `'Strasse10'`.
- **All-caps ligature:** `ẞ` (U+1E9E, capital sharp s) → `SS` map entry exists; assert `'GROẞ'` folds and collates with `'gross'`.
- **`caseSensitive: true` + folding:** confirm folding still happens but case is preserved — `'É'` and `'e'` fold to `'E'`/`'e'`, which differ; assert non-zero, `'E'(69) < 'e'(101)`.
- **`removeDiacritics` coverage delta:** any accented char NOT in the library's `_accentsMap` (e.g. a rare Vietnamese stack) passes through unfolded; add one such case and assert it does not throw and orders by code unit (documents the map-bound limitation).
- **Stability:** `List.sort` is not stable; if a caller needs stable order for fold-equal items, the raw tie-break already provides a total order, so document that two truly-identical strings keep input order is NOT guaranteed (they're equal, position arbitrary) — only DISTINCT strings are deterministically ordered.

---

## Adoption note (downstream)

Saropa Contacts is the first consumer; its adoption is specced separately at
`D:\src\contacts\docs\PLAN_CONTACT_SORT_DIACRITIC_ADOPTION.md`, **gated on this
member shipping**. The contacts side swaps the leaf `String.compareTo` calls in
its name comparators (`_compareNames`, `latinSortComparator`) for `foldedCompare`,
keeping its own status/Latin-bucket/direction keys above the leaf. No third-party
dependency is added on either side.

---

## Finish Report (2026-06-11)

**Scope:** (A) Dart library code — one new source file, one new test file, barrel export, three doc updates. No Flutter UI, no extension, no l10n.

### Built
- `lib/string/string_folded_compare_extensions.dart` — implements the spec exactly: `StringFoldedCompareExtensions.compareStringFolded` (on `String?`), the `foldedCompare` free comparator, and `FoldedSortExtension.sortedFolded` (on `List<String>`). Pipeline per side is `removeDiacritics()` → optional `toLowerCase()`; primary compare is `naturalCompare` (when `natural`) else `compareTo`; deterministic raw-string tie-break on a `0` primary so distinct fold-equal strings never return `0`. Null branch runs before folding (both-null `0`; one-null first/last by `nullsLast`). Composes existing `removeDiacritics()` + `naturalCompare()`; no new dependencies.
- `test/string/string_folded_compare_extensions_test.dart` — 27 tests covering folding, case modes, the tie-break guarantee (incl. an all-pairs antisymmetry sweep and a transitivity triple), natural mode + ligature length change, nulls, non-Latin pass-through, an out-of-map diacritic (`ạ`), `SplayTreeMap` non-drop, emoji/empty/whitespace edges, and `sortedFolded` non-mutation.

### Deviation from spec (intentional, documented)
The spec's own test snippet predicted the tie-break SIGN wrong in two cases. Raw `String.compareTo` tie-break uses the original code units: `ß` (U+00DF, 223) > `s` (115), so `foldedCompare('Straße','Strasse')` is **positive**, not the spec's hedged "negative or 0"; likewise `'Æsir'` vs `'aesir'` is positive (`Æ` 198 > `a` 97). The shipped tests assert the actual, correct behavior with comments explaining the code-unit math, rather than copy the spec's guesses. The comparator logic itself matches the spec unchanged.

### Verification
- `flutter test test/string/string_folded_compare_extensions_test.dart` → **All 27 tests passed.**
- `flutter analyze` was NOT run — it is CPU-bound on this device and locked the machine (consistent with the project memory note that the Dart analyzer/test toolchain is the wall-clock bottleneck here). The new code compiles cleanly as a side effect of the passing test run. Recommend gating the full analyze in CI.

### Files changed
- Added: `lib/string/string_folded_compare_extensions.dart`
- Added: `test/string/string_folded_compare_extensions_test.dart`
- Modified: `lib/saropa_dart_utils.dart` (barrel export)
- Modified: `CHANGELOG.md` (Unreleased → Added), `CODE_INDEX.md`, `CODEBASE_INDEX.md`
- Moved: `plans/SPEC-sort-diacritic-fold.md` → `plans/history/2026.06/2026.06.11/SPEC-sort-diacritic-fold.md`

**Plan archived:** `plans/SPEC-sort-diacritic-fold.md` → `plans/history/2026.06/2026.06.11/SPEC-sort-diacritic-fold.md` (fully implemented; no remaining scope).
**No bug archive** — task did not close a `bugs/*.md` file.
**Finish report appended:** `plans/history/2026.06/2026.06.11/SPEC-sort-diacritic-fold.md`.

### Outstanding
- Downstream adoption in Saropa Contacts (`D:\src\contacts\docs\PLAN_CONTACT_SORT_DIACRITIC_ADOPTION.md`) was gated on this member shipping; it is now unblocked but out of scope for this repo.
