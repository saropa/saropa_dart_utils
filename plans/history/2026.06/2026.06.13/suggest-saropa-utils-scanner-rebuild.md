# suggest_saropa_utils scanner rebuild + isNullOrEmpty deprecation

The `suggest_saropa_utils` command-line scanner recommends `saropa_dart_utils`
helpers in place of hand-rolled boilerplate. An audit of its detector list
against the current `lib/` public API found it substantially inaccurate: four
detectors named utilities that do not exist anywhere in the package (`orZero`,
`orNow`, `toIntOr`, and a misspelled `notNullOrEmpty`), so applying their
suggestions would produce code that does not compile; three more pushed the
`isNullOrEmpty` / `isNotNullOrEmpty` family, and one pushed `isNullOrZero` — all
boolean getters on a nullable receiver that defeat Dart's null promotion. The
`String?.isNullOrEmpty` getter was simultaneously deprecated for the same reason.

## Finish Report (2026-06-13)

### What changed and why

**`lib/string/string_nullable_extensions.dart` — `isNullOrEmpty` and
`isNotNullOrEmpty` deprecated.** After `if (x.isNullOrEmpty) return;` (or inside
`if (x.isNotNullOrEmpty) { … }`), Dart flow analysis cannot tell the opaque getter
implies `x != null`, so `x` stays nullable in the guarded scope and callers are
pushed toward `!`. The explicit `x == null || x.isEmpty` and
`x != null && x.isNotEmpty` promote `x` to non-null and are preferred. A
`@Deprecated` annotation carries that reasoning to every call site; each dartdoc
gains a worked before/after example. Both getters are retained for source
compatibility.

**`tool/suggest_saropa_utils_lib.dart` — detector list rebuilt.** The detector
list was replaced with 45 entries, each audited against three gates: the named
utility exists in `lib/`, recommending it does not degrade the code (no
`isNullOrX`-getter-on-nullable target), and the regex is specific enough to avoid
broad false positives (same-variable backreferences where applicable). Detectors
cover string helpers (`capitalize`, `truncateWithEllipsis`, `containsIgnoreCase`,
`ensurePrefix`/`ensureSuffix`, `getEverythingBefore`/`getEverythingAfter`,
`compressSpaces`, `firstWord`, `countOccurrences`, `removeAll`, `wordCount`,
`isNumeric`, `isPalindrome`, `orEmpty`), collection helpers (`addNotNull`,
`takeLast`, `dropLast`, `lastOrNull`, `whereNotNull`, `countWhere`, `containsAny`,
`containsAll`, `endsWithAny`, `nullIfEmpty`, `flatten`, `none`, `sumBy`, `invert`),
DateTime helpers (`isSameDay`, `startOfDay`/`endOfDay`,
`addDays`/`addHours`/`addMinutes`/`addMonths`/`addYears`, `isLeapYear`,
`isWeekend`), and numeric helpers (`clampNonNegative`, `percentageOf`, `lerp`,
`isInteger`). A reverse detector flags *use* of the deprecated `isNullOrEmpty` /
`isNotNullOrEmpty` / `isNullOrZero` getters and points back at the explicit form.
A header comment records why the `isNullOrX` family is excluded as a target.

### Verification

- `flutter test test/string/string_nullable_extensions_test.dart test/tool/suggest_saropa_utils_test.dart` → 28 passed.
- Scoped `dart analyze` on the four changed Dart files → no new issues (five
  pre-existing `curly_braces_in_flow_control_structures` infos remain in the
  untouched `jsonString` function and are out of scope).

### Test changes

`test/tool/suggest_saropa_utils_test.dart` — the `scanContent` group dropped
assertions that pinned the removed `isNullOrEmpty` and phantom `orZero`
detectors, and gained cases asserting the correct long-form guard is NOT flagged,
that use of a deprecated getter IS flagged, and that the `capitalize` and
`takeLast` patterns are detected. `test/string/string_nullable_extensions_test.dart`
gained a file-level `deprecated_member_use_from_same_package` suppression because
it deliberately exercises the deprecated getter.

### Documentation

`CHANGELOG.md` gained a `Deprecated` entry for `isNullOrEmpty` and a `Changed`
entry for the scanner rebuild. `README.md` line 316 was corrected — its example
previously advertised the removed `x == null || x.isEmpty → x.isNullOrEmpty`
suggestion. `plans/SAROPA_SUITE_INTEGRATION.md` R5 was corrected to describe the
scanner as the real (CLI) home of migration detection, with an in-editor
`saropa_lints` rule pack noted as possible future work rather than the shipped
mechanism.

### Scope and outstanding

Migration detection lives in the CLI scanner only; it is not surfaced as
in-editor diagnostics. The detector regexes were unit-tested on synthetic
snippets; their false-positive rate against a large real codebase is unmeasured.
Further detectors are possible but would trade into fuzzier patterns; 45 verified
detectors are shipped.
