# SPEC: String misc helpers (secondIndex / reversed / substringSafe / removeEnd* / toAlphaNumeric) — for inclusion

**Status:** Proposed (from Saropa Contacts) — **mostly already in library**; one net-new helper (`removeEndNullable`).
**Proposed location:** `lib/string/string_nullable_extensions.dart` (the single net-new member, `removeEndNullable`, belongs on the `String?` extension).
**Portability:** Pure Dart. No Flutter, no external packages. Rune/UTF-16 string operations only.

## Purpose — what it does + why it is general-purpose (not proprietary)

The harvested file `lib/utils/primitive/string/string_utils_local.dart` is the Saropa Contacts local `extension StringExtensionsLocal on String`. The members in scope are basic, domain-agnostic string utilities:

- `secondIndex(String char)` — index of the **second** occurrence of `char`, or `-1`.
- `reversed` (getter) — rune-aware string reversal (so surrogate pairs / emoji are not split).
- `substringSafe` — bounds-clamped substring that never throws (used here transitively via the library).
- `removeEnd(String find)` — strip a suffix if present.
- `removeEndNullable(String? find)` — nullable-aware suffix strip with empty/null semantics.
- `toAlphaNumeric({bool allowSpace})` — alias that delegates to `removeNonAlphaNumeric`.

None of these touch the contact domain, Saropa formats, l10n, or app state — they are textbook `String` helpers.

### Overlap finding — almost the entire surface already ships in `saropa_dart_utils` 1.4.1

| Member (local) | Library location | Status |
|---|---|---|
| `secondIndex(String char)` | `string/string_analysis_extensions.dart:164` | **Already in library** — identical logic. The library version returns `indexOf(char, firstIdx + 1)` directly (which is already `-1` when absent), so it is equivalent to the local guarded version. |
| `reversed` (getter) | `string/string_extensions.dart:248` — `String.fromCharCodes(runes.toList().reversed)` | **Already in library** — byte-for-byte identical implementation (local just adds a try/catch + empty short-circuit). |
| `substringSafe(start, [end])` | `string/string_extensions.dart:282` | **Already in library** — grapheme-aware bounds-safe substring; superset of local usage. |
| `removeEnd(String end)` | `string/string_manipulation_extensions.dart:112` | **Already in library** — identical (`endsWith(end) ? substringSafe(0, length - end.length) : this`). |
| `removeNonAlphaNumeric({allowSpace})` | `string/string_manipulation_extensions.dart:172` | **Already in library** — identical. |
| `toAlphaNumeric({allowSpace})` | — | **Not in library, but it is a pure alias** of `removeNonAlphaNumeric`. The local definition is literally `=> removeNonAlphaNumeric(allowSpace: allowSpace)`. Recommend NOT adding — call `removeNonAlphaNumeric` directly. (Listed for completeness; no net-new value.) |
| `removeEndNullable(String? find)` | — (no nullable variant of `removeEnd` on `StringNullableExtensions`) | **NET-NEW** — the only member worth adding. |

So: **the util is partial-overlap**. The single net-new contribution is `removeEndNullable`.

### Excluded members (out of scope per SCOPE NOTE / proprietary / already spec'd)

- `preventOrphans` — already spec'd separately (typography orphan-prevention). EXCLUDED.
- `splitCapitalizedUnicode` — already in the library. EXCLUDED.
- `substringSafeEllipsis` — app-specific ellipsis truncation built on `SpecialChar.Ellipsis`; depends on the app `SpecialChar` table. Library already has `excerpt_utils.dart` / truncate helpers covering this. EXCLUDED (not requested; truncation-with-ellipsis already covered).
- `multilineSplit` — wrapping/hyphenation helper depending on app `SpecialChar.Hyphen` and `debug()` logging; library already has `string_wrap_extensions.dart`. EXCLUDED (not in scope; wrapping already covered).
- `commonWordEndings` (static const) — depends on the app `SpecialChar` table (accented quotes, ellipsis, dot). App-specific constant list. EXCLUDED.
- `toAlphaNumeric` — pure alias of an existing library method; adds no behavior. EXCLUDED from inclusion (documented above for traceability).
- Commented-out dead code (`trimWithEllipsis`, `replaceLastNCharacters`, `lastChars`, `removeNonDigits`, `isLetter`) — already removed/commented. EXCLUDED.
- `isNumber`, `removeLastChars` — noted in source as already migrated to `saropa_dart_utils`. EXCLUDED (done).

## Source (from Saropa Contacts) — net-new member, verbatim (debug logging stripped)

`removeEndNullable` is the only member proposed for inclusion. Verbatim from source (it has no `debug()`/`DebugType` logging to strip):

```dart
extension StringExtensionsLocal on String {
  String? removeEndNullable(String? find) => find == null || find.isEmpty
      ? this
      : isEmpty
      ? null
      : removeEnd(find);
}
```

Note the asymmetric semantics worth preserving in a doc comment:
- `find == null` OR `find.isEmpty` -> returns the receiver unchanged (nothing to remove).
- receiver `isEmpty` (and `find` is non-empty) -> returns `null` (not `''`) — this is the deliberate "empty source with a real suffix to strip yields null" branch.
- otherwise -> delegates to the existing `removeEnd(find)`.

Proposed library shape — move this onto `StringNullableExtensions on String?` so it composes with the existing nullable surface (`isNullOrEmpty`), OR keep it on `String` mirroring the local placement. Recommend `String` placement (the receiver is non-null; only `find` is nullable), as a sibling of `removeEnd`:

```dart
/// Removes [find] from the end of this string, tolerating a null/empty [find].
///
/// - When [find] is `null` or empty, there is nothing to strip: returns this
///   string unchanged.
/// - When this string is empty (and [find] is a real, non-empty suffix),
///   returns `null` — the empty source cannot carry the requested suffix, and
///   `null` (rather than `''`) lets callers distinguish "stripped to nothing"
///   from "no source".
/// - Otherwise delegates to [removeEnd].
@useResult
String? removeEndNullable(String? find) => find == null || find.isEmpty
    ? this
    : isEmpty
        ? null
        : removeEnd(find);
```

## Test cases — no existing tests in Saropa Contacts; proposed cases

The Saropa Contacts test tree has no `*_test.dart` covering `StringExtensionsLocal` (`string_utils_test.dart` exists but references none of these symbols). The already-in-library members (`secondIndex`, `reversed`, `substringSafe`, `removeEnd`, `removeNonAlphaNumeric`) carry the library's own coverage. Proposed cases below are for the **net-new** `removeEndNullable` only.

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';
import 'package:test/test.dart';

void main() {
  group('removeEndNullable', () {
    test('strips a matching suffix', () {
      expect('hello.txt'.removeEndNullable('.txt'), 'hello');
    });

    test('leaves string unchanged when suffix absent', () {
      expect('hello'.removeEndNullable('.txt'), 'hello');
    });

    test('null find returns receiver unchanged', () {
      expect('hello'.removeEndNullable(null), 'hello');
    });

    test('empty find returns receiver unchanged', () {
      expect('hello'.removeEndNullable(''), 'hello');
    });

    test('empty receiver with non-empty find returns null', () {
      expect(''.removeEndNullable('x'), isNull);
    });

    test('empty receiver with null find returns empty (unchanged)', () {
      expect(''.removeEndNullable(null), '');
    });

    test('empty receiver with empty find returns empty (unchanged)', () {
      expect(''.removeEndNullable(''), '');
    });

    test('find equal to whole string strips to empty string (not null)', () {
      expect('abc'.removeEndNullable('abc'), '');
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

For `removeEndNullable` (the net-new member):

- **Empty:** empty receiver + each of {null, empty, non-empty} `find` (asserts the null-vs-empty branch split above).
- **Whole-string match:** `'abc'.removeEndNullable('abc')` -> `''` (NOT `null` — `null` is reserved for the empty-receiver-with-real-suffix case).
- **Suffix longer than receiver:** `'ab'.removeEndNullable('xabc')` -> unchanged `'ab'` (no match).
- **Repeated suffix:** `'aaa'.removeEndNullable('a')` -> `'aa'` (removes only ONE trailing occurrence, matching `removeEnd`).
- **Case sensitivity:** `'Hello.TXT'.removeEndNullable('.txt')` -> unchanged (suffix match is case-sensitive); add an explicit assertion so the contract is locked.
- **Unicode / emoji suffix:** `'café'.removeEndNullable('é')` -> `'caf'`; `'hi🙂'.removeEndNullable('🙂')` (the U+1F642 emoji) -> `'hi'` — verify the surrogate-pair suffix strips cleanly and does not leave a lone surrogate.
- **Combining marks:** receiver ending in a base+combining sequence where `find` is just the combining mark (`String.fromCharCode(0x0301)`, combining acute) — document that this is UTF-16 code-unit matching, NOT grapheme-aware, so a partial-cluster strip is possible.
- **Whitespace suffix:** `'hi '.removeEndNullable(' ')` and non-breaking space `'hi' + String.fromCharCode(0x00A0)` stripped with `String.fromCharCode(0x00A0)`.
- **`find` containing the full receiver plus more:** `'x'.removeEndNullable('yx')` -> unchanged `'x'`.

For the already-in-library members (cross-check that library coverage already includes these; add if missing):

- `reversed`: empty string -> `''`; single rune; surrogate-pair / emoji string round-trips (`reversed.reversed == original`); combining-mark ordering note (combining marks reverse by code point, which can visually corrupt clusters — document, don't "fix").
- `secondIndex`: char absent (-1); char appears exactly once (-1); empty `char` (-1); empty receiver (-1); multi-char `char` needle (`'abab'.secondIndex('ab')` -> 2); overlapping matches.
- `substringSafe`: `start < 0`, `start >= length`, `end < start`, `end > length`, emoji-boundary clamps (library already documents `'🙂hello'.substringSafe(0, 1)` -> the emoji).
- `removeEnd`: suffix longer than string; whole-string suffix -> `''`; empty suffix -> unchanged.
- `removeNonAlphaNumeric`: `allowSpace` true/false; unicode letters (`'café'`), digits, mixed punctuation, empty string, all-symbol string -> `''`.

## Recommendation

Add **only** `removeEndNullable` (one method on `String` next to `removeEnd` in `string_manipulation_extensions.dart`, or on `StringNullableExtensions`). Everything else in the in-scope set is already shipped in `saropa_dart_utils` 1.4.1; `toAlphaNumeric` is a redundant alias and should NOT be added.
