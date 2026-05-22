# BUG-002: `truncateWithEllipsis()` — Ambiguous Extension Member Clash on `String`

**File:** `lib/string/string_lower_extensions.dart` (offending re-declaration); counterpart `lib/string/string_extensions.dart` (original)
**Severity:** 🔴 High
**Category:** Logic Error (API collision — build-breaking for consumers; also a silent semantic divergence)
**Status:** Closed (code fix complete & verified in working tree; release of 1.1.4 still pending)

<!-- Status values: Open → Investigating → Fix Ready → Closed
     Closed = duplicate removed, grapheme version kept, verified (full suite +
     analyze clean). OPERATIONAL FOLLOW-UP (not this bug's code fix): publish
     1.1.4 and bump the consumer constraint. Released v1.1.3 stays broken until
     1.1.4 ships. -->

---

## Summary

Two extensions in this package declare a method named `truncateWithEllipsis()`
on `String`, and the public barrel exports both. Any consumer that imports the
barrel and calls `.truncateWithEllipsis(...)` gets a compile error —
`ambiguous_extension_member_access`. Worse than a name clash: the two
implementations have **different signatures and different truncation semantics**,
so they are not interchangeable — picking the wrong one to keep changes output.

Same defect class as [BUG-001](BUG-001-toListIfNotNull-ambiguous-extension-clash.md);
the offending declaration was added in the same commit (`443562b`).

---

## Attribution Evidence

Both declarations live in `lib/` (this package):

```bash
grep -rn "String truncateWithEllipsis" lib/
# lib/string/string_extensions.dart:179:       String truncateWithEllipsis(int? cutoff) {                       [extension StringExtensions on String]
# lib/string/string_lower_extensions.dart:8:   String truncateWithEllipsis(int maxLength, [String ellipsis = '...']) { [extension StringLowerExtensions on String]
```

Both files are exported from the barrel:

```
lib/saropa_dart_utils.dart:268: export 'string/string_extensions.dart';
lib/saropa_dart_utils.dart:277: export 'string/string_lower_extensions.dart';
```

History (which is the original vs the re-add):

```
lib/string/string_extensions.dart        added 127ebee 2024-06-27  (original; grapheme-aware; has tests)
lib/string/string_lower_extensions.dart  added 443562b 2026-03-06  (roadmap 400/700 — same commit as BUG-001)
```

---

## Reproduction

Minimal — any consumer importing the barrel:

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';

void main() {
  print('hello world'.truncateWithEllipsis(5));
  // ACTUAL:  compile error — ambiguous_extension_member_access:
  //   "A member named 'truncateWithEllipsis' is defined in
  //    'extension StringExtensions on String' and
  //    'extension StringLowerExtensions on String', and neither is more specific."
  // EXPECTED: prints a 5-grapheme truncation with an ellipsis
}
```

**Frequency:** Always — for any consumer importing the barrel and calling
`.truncateWithEllipsis(...)`.

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | `.truncateWithEllipsis(...)` resolves to a single extension; the call compiles. |
| **Actual** | Two extensions declare it on `String`; the call is `ambiguous_extension_member_access` and fails to compile in every barrel-importing consumer. |

---

## Root Cause

Two in-scope extensions declare the same member on the identical receiver
(`String`), so neither is more specific → ambiguous. The two are *not* the same
function:

```dart
// lib/string/string_extensions.dart:173-189  (original — grapheme-aware)
@useResult
String truncateWithEllipsis(int? cutoff) {
  if (isEmpty || cutoff == null || cutoff <= 0) return this;
  if (characters.length <= cutoff) return this;          // counts grapheme clusters
  return '${substringSafe(0, cutoff)}$ellipsis';         // appends StringExtensions.ellipsis ('…')
}

// lib/string/string_lower_extensions.dart:6-13  (newer — code-unit-based)
@useResult
String truncateWithEllipsis(int maxLength, [String ellipsis = '...']) {
  if (maxLength <= 0) return '';                          // empty (not original) on non-positive
  if (length <= maxLength) return this;                  // counts UTF-16 code units, not graphemes
  if (ellipsis.length >= maxLength) return ellipsis.substringSafe(0, maxLength);
  return substringSafe(0, maxLength - ellipsis.length) + ellipsis;  // reserves room for ellipsis
}
```

Differences that make this more than a naming clash:

- **Counting unit:** grapheme clusters (Unicode/emoji-correct) vs UTF-16 code units.
- **Ellipsis:** the original's `'…'` (single char) vs the newer's `'...'` default, customizable.
- **Length budget:** original appends ellipsis *after* `cutoff` chars (result longer than cutoff); newer reserves room *within* `maxLength`.
- **Edge cases:** non-positive input returns the original string (original) vs `''` (newer).

---

## Impact

- **Who hits this:** every barrel consumer calling `.truncateWithEllipsis(...)`.
  The `saropa` Contacts app calls it at **8+ sites**, including the core
  `lib/components/primitive/common_text.dart` primitive (used app-wide), plus
  `file_backup_utils.dart`, `contact_note_item.dart`, `call_notice_item.dart`,
  `emergency_service_floating_action_button.dart`, `common_url_widget.dart`, and
  a dev panel. Because `common_text.dart` is a base widget, the errored call
  cascades across the whole UI tree — a major contributor to the 1000+ analyzer
  errors observed.
- **Silent-divergence risk:** all observed consumer calls pass a single `int`
  (e.g. `truncateWithEllipsis(100)`), which *both* signatures accept — so before
  the collision shipped, whichever extension happened to be in scope decided the
  output (grapheme vs code-unit, `'…'` vs `'...'`). Resolving the ambiguity by
  keeping the wrong one would silently change truncation output for emoji /
  multi-byte strings.

---

## Suggested Fix

Keep the original grapheme-aware `StringExtensions.truncateWithEllipsis(int? cutoff)`
(Unicode-correct, established since 2024, **already tested**). Remove the newer
`StringLowerExtensions.truncateWithEllipsis` (untested, code-unit-based). All
observed consumer calls use the single-`int` form, which the retained signature
covers, so no consumer call site changes.

```dart
// lib/string/string_lower_extensions.dart — delete this member (keep the rest of the extension)
- @useResult
- String truncateWithEllipsis(int maxLength, [String ellipsis = '...']) { ... }
```

If the customizable-ellipsis behavior is genuinely wanted, do it as a *separate*
change on the retained method (add an optional `[String ellipsis = '…']`
parameter to `StringExtensions.truncateWithEllipsis`) rather than a second
same-named method — and keep grapheme counting. Do not introduce a code-unit
variant under the same name.

---

## Missing Tests

`truncateWithEllipsis` is tested only for the original in
`test/string/string_extensions_test.dart`; the newer `StringLowerExtensions`
copy has no test. After removal, add a grapheme-cluster regression so the
Unicode-correct behavior is locked in:

```dart
group('truncateWithEllipsis grapheme safety', () {
  test('should count emoji as single graphemes', () {
    expect('👋👋👋👋'.truncateWithEllipsis(2), '👋👋…');
  });
  test('should return the original when shorter than cutoff', () {
    expect('hi'.truncateWithEllipsis(10), 'hi');
  });
});
```

---

## Changes Made

Applied the suggested fix. Verified on 2026-05-22 (full suite: 3439 tests pass;
`dart analyze` clean; `dart format` clean).

### `lib/string/string_lower_extensions.dart`

Removed the code-unit-based `truncateWithEllipsis(int maxLength, [String ellipsis])`
method, leaving a comment in its place noting the method lives only on
`StringExtensions` and must not be re-added here. The rest of the extension
(`padLeftTo`, `repeatTimes`, `isWhitespaceOnly`, `ensurePrefix`, …) is untouched;
the `string_extensions.dart` import stays (still used by `removePrefix` /
`removeSuffix` via `substringSafe`).

### `test/string/string_extensions_test.dart`

Added an emoji grapheme regression (case 11): `'👋👋👋👋'.truncateWithEllipsis(2)`
→ `'👋👋…'`. Verified the kept method is grapheme-correct in both its length
check (`characters.length`) and its slice (`substringSafe` uses
`characters.getRange().string`), so emoji truncate by grapheme, not code unit.
This locks in the behavior the removed copy would have broken.

No consumer call-site changes: every observed call passes a single `int`, which
the retained `int? cutoff` signature accepts.

---

## Commits

- `fix(string): remove duplicate String.truncateWithEllipsis to resolve ambiguous-extension clash (BUG-002)`
  — bundled with BUG-003 in the same string-collisions commit on `main`.

---

## Environment

- saropa_dart_utils version: **1.1.3** (released, broken on pub.dev); no fix staged
- Dart SDK version: 3.12.0 (stable)
- Triggering call site: `saropa` Contacts app — `import 'package:saropa_dart_utils/saropa_dart_utils.dart';` then `str.truncateWithEllipsis(n)` (8+ sites incl. `common_text.dart`). Surfaced as `ambiguous_extension_member_access` in VS Code.
