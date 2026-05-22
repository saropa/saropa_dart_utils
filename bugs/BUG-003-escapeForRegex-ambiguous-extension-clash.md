# BUG-003: `escapeForRegex()` — Ambiguous Extension Member Clash on `String`

**File:** `lib/string/string_manipulation_extensions.dart` (redundant copy to remove); counterpart `lib/string/string_regex_extensions.dart` (canonical, tested)
**Severity:** 🔴 High
**Category:** Logic Error (API collision — build-breaking for consumers; duplicate implementation)
**Status:** Closed (code fix complete & verified in working tree; release of 1.1.4 still pending)

<!-- Status values: Open → Investigating → Fix Ready → Closed
     Closed = duplicate + its private regex removed, canonical copy kept,
     verified (full suite + analyze clean). OPERATIONAL FOLLOW-UP (not this bug's
     code fix): publish 1.1.4 and bump the consumer constraint. Released v1.1.3
     stays broken until 1.1.4 ships. -->

---

## Summary

Two extensions in this package declare a method named `escapeForRegex()` on
`String`, and the public barrel exports both. Any consumer that imports the
barrel and calls `.escapeForRegex()` gets a compile error —
`ambiguous_extension_member_access`. Unlike [BUG-002](BUG-002-truncateWithEllipsis-ambiguous-extension-clash.md),
the two implementations are functionally equivalent — this is pure duplication;
one copy should be deleted.

Same defect class as [BUG-001](BUG-001-toListIfNotNull-ambiguous-extension-clash.md)
and [BUG-002](BUG-002-truncateWithEllipsis-ambiguous-extension-clash.md).

---

## Attribution Evidence

Both declarations live in `lib/` (this package):

```bash
grep -rn "String escapeForRegex" lib/
# lib/string/string_manipulation_extensions.dart:166: String escapeForRegex() => ...  [extension StringManipulationExtensions on String]
# lib/string/string_regex_extensions.dart:19:         String escapeForRegex() { ... } [extension StringRegexExtensions on String]
```

Both files are exported from the barrel:

```
lib/saropa_dart_utils.dart:247: export 'string/string_regex_extensions.dart';
lib/saropa_dart_utils.dart:269: export 'string/string_manipulation_extensions.dart';
```

History (which is older vs the re-add):

```
lib/string/string_manipulation_extensions.dart  added 3bd5b7f 2026-02-22  (older; no dedicated escapeForRegex test)
lib/string/string_regex_extensions.dart         added 035a0f7 2026-03-06  (newer; has empty guard, full dartdoc, AND tests)
```

---

## Reproduction

Minimal — any consumer importing the barrel:

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';

void main() {
  print(r'$10.00'.escapeForRegex());
  // ACTUAL:  compile error — ambiguous_extension_member_access:
  //   "A member named 'escapeForRegex' is defined in
  //    'extension StringManipulationExtensions on String' and
  //    'extension StringRegexExtensions on String', and neither is more specific."
  // EXPECTED: prints r'\$10\.00'
}
```

**Frequency:** Always — for any consumer importing the barrel and calling
`.escapeForRegex()`.

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | `.escapeForRegex()` resolves to a single extension; the call compiles. |
| **Actual** | Two extensions declare it on `String`; the call is `ambiguous_extension_member_access` and fails to compile in every barrel-importing consumer. |

---

## Root Cause

Two in-scope extensions declare the same member with the same signature on the
identical receiver (`String`), so neither is more specific → ambiguous. The two
bodies are functionally equivalent (both backslash-escape regex metacharacters
via `replaceAllMapped`); the only difference is the newer one's `isEmpty` guard,
which is a no-op (`''.replaceAllMapped(...)` already returns `''`):

```dart
// lib/string/string_manipulation_extensions.dart:161-169  (older, untested)
@useResult
String escapeForRegex() => replaceAllMapped(
  _regexSpecialCharsRegex,
  (Match m) => '\\${m.group(0) ?? ''}',
);

// lib/string/string_regex_extensions.dart:18-25  (newer, tested, fuller docs)
@useResult
String escapeForRegex() {
  if (isEmpty) return this;                       // harmless guard
  return replaceAllMapped(
    _regexSpecialChars,
    (Match m) => '\\${m.group(0) ?? ''}',
  );
}
```

Each file defines its own private metacharacter `RegExp` (`_regexSpecialCharsRegex`
vs `_regexSpecialChars`) — duplicated state for one logical operation.

---

## Impact

- **Who hits this:** every barrel consumer calling `.escapeForRegex()`. The
  `saropa` Contacts app does **not** currently call it (no matches in
  `contacts/lib`), so this collision is **not** part of the 1000+ errors observed
  there — it is latent. It will break the first consumer that calls it via the
  barrel, including contacts if a future call is added.
- **Why it still matters:** it is a build-breaking ambiguity shipped in a public
  API (released v1.1.3), and it is pure duplicated code (two private regexes for
  one operation) that will keep diverging if left.

---

## Suggested Fix

Keep the canonical `StringRegexExtensions.escapeForRegex()` (dedicated regex
file, fuller dartdoc, empty guard, **already tested** in
`test/string/string_regex_extensions_test.dart`). Remove the older redundant
copy and its now-unused private regex from `StringManipulationExtensions`.
Output is identical for all non-empty input, so no consumer behavior changes.

```dart
// lib/string/string_manipulation_extensions.dart — delete this member ...
- @useResult
- String escapeForRegex() => replaceAllMapped(
-   _regexSpecialCharsRegex,
-   (Match m) => '\\${m.group(0) ?? ''}',
- );
// ... and remove the now-unused `_regexSpecialCharsRegex` declaration if nothing
// else in the file references it (verify with grep before deleting).
```

---

## Missing Tests

The retained `StringRegexExtensions.escapeForRegex()` is already covered by
`test/string/string_regex_extensions_test.dart`. After removing the duplicate,
confirm those tests still pass (`dart test test/string/string_regex_extensions_test.dart`)
and that no test imported the manipulation-file copy directly. No new tests are
required for the kept method.

---

## Changes Made

Applied the suggested fix, with one correction to this report's test analysis
(see below). Verified on 2026-05-22 (full suite: 3439 tests pass; `dart analyze`
clean; `dart format` clean).

### `lib/string/string_manipulation_extensions.dart`

Removed the duplicate `escapeForRegex()` and its now-unused private
`_regexSpecialCharsRegex` (confirmed by grep that nothing else in the file
referenced it), leaving a comment noting the method lives only on
`StringRegexExtensions` and must not be re-added here.

### `lib/string/string_extensions.dart`

**Correction to the "Missing Tests" claim** — the report said "no test imported
the manipulation-file copy directly," which is literally true but missed an
indirect path: `string_extensions.dart` *re-exports*
`string_manipulation_extensions.dart` (line 5), and
`test/string/string_extensions_test.dart` (which imports only
`string_extensions.dart`) tests `escapeForRegex` at 10 sites. Removing the
manipulation copy alone would have broken those tests at compile time. Fixed by
adding `export 'string_regex_extensions.dart';` to `string_extensions.dart`, so
`escapeForRegex` stays reachable via that file (now resolving to the canonical
`StringRegexExtensions` copy) — preserving backward compatibility for direct
importers and keeping the 10 tests valid. They pass unchanged against the kept
method (identical output; both return `''` for empty input).

Coverage is therefore stronger than the report assumed: `escapeForRegex` is now
exercised by both `string_regex_extensions_test.dart` and the 10 cases in
`string_extensions_test.dart`, all against the single canonical implementation.

---

## Commits

- `fix(string): remove duplicate String.escapeForRegex to resolve ambiguous-extension clash (BUG-003)`
  — bundled with BUG-002 in the same string-collisions commit on `main`.

---

## Environment

- saropa_dart_utils version: **1.1.3** (released, broken on pub.dev); no fix staged
- Dart SDK version: 3.12.0 (stable)
- Triggering call site: any consumer importing `package:saropa_dart_utils/saropa_dart_utils.dart` and calling `.escapeForRegex()`. Not currently called in the `saropa` Contacts app (latent).
