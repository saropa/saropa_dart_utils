# BUG-001: `toListIfNotNull()` — Ambiguous Extension Member Clash on `T?`

**File:** `lib/object/nullable_more_extensions.dart` (offending re-declaration); counterpart `lib/list/make_list_extensions.dart` (original)
**Severity:** 🔴 High
**Category:** Logic Error (API collision — build-breaking for consumers)
**Status:** Closed (code fix complete & verified in working tree; release of 1.1.4 still pending)

<!-- Status values: Open → Investigating → Fix Ready → Closed
     Closed = the toListIfNotNull rename is implemented and verified in the
     working tree (dart analyze clean, dart format clean, 33-case test passes).
     OPERATIONAL FOLLOW-UP (not part of this bug's code fix): commit, publish
     1.1.4, bump the consumer constraint. Released v1.1.3 on pub.dev stays broken
     until 1.1.4 ships. The two sibling collisions (see "Related") are a SEPARATE
     scope — still Open in both released and working-tree code; close depends on
     BUG-002 / BUG-003 being filed and fixed. -->

---

## Summary

Two extensions in this package declare a method named `toListIfNotNull()` on the
same receiver type `T?`, and the public barrel (`saropa_dart_utils.dart`) exports
both. Any consumer that imports the barrel and calls `.toListIfNotNull()` gets a
compile error — `ambiguous_extension_member_access` — because neither extension
is more specific than the other. The package fails to compile in downstream
projects, not just at runtime.

---

## Attribution Evidence

Both declarations live in `lib/` (this package), so this is a library bug, not a
consumed-dependency / lint issue.

```bash
grep -rn "toListIfNotNull" lib/
# lib/list/make_list_extensions.dart:9:   List<T>? toListIfNotNull() {   [extension MakeListExtensions<T> on T?]
# lib/object/nullable_more_extensions.dart:38: List<T> toListIfNotNull() { [extension ToListIfNotNull<T> on T?]
```

Both are exported from the barrel:

```
lib/saropa_dart_utils.dart:161: export 'list/make_list_extensions.dart';
lib/saropa_dart_utils.dart:239: export 'object/nullable_more_extensions.dart';
```

The newer `ToListIfNotNull` extension was introduced in commit `443562b`
("feat: roadmap 400/700 implementation"); the original `MakeListExtensions` is
the established, tested API (`test/list/make_list_extensions_test.dart`).

---

## Reproduction

Minimal — any consumer importing the barrel:

```dart
import 'package:saropa_dart_utils/saropa_dart_utils.dart';

void main() {
  const String? value = 'a';
  print(value?.toListIfNotNull());
  // ACTUAL:  compile error — ambiguous_extension_member_access:
  //   "A member named 'toListIfNotNull' is defined in
  //    'extension MakeListExtensions<T> on T?' and
  //    'extension ToListIfNotNull<T> on T?', and neither is more specific."
  // EXPECTED: prints [a]
}
```

**Frequency:** Always — for any consumer that (a) imports the package barrel and
(b) calls `.toListIfNotNull()`. Importing only `list/make_list_extensions.dart`
directly avoids it, but the barrel is the documented entry point.

> Note on detection: a *cold* `dart analyze` / `flutter analyze` in the consuming
> project may report "No issues found" from a stale analysis-driver cache. The
> error is real — confirmed by analyzing a freshly-created file (no cache
> possible), which immediately reported the clash naming both extensions. Do not
> trust a clean CLI analyze here over the IDE; restart the analysis server to
> reconcile.

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | `.toListIfNotNull()` resolves to a single extension; the call compiles. |
| **Actual** | Two extensions declare it on `T?`; the call is `ambiguous_extension_member_access` and fails to compile in every barrel-importing consumer. |

---

## Root Cause

Extension method resolution is ambiguous when two in-scope extensions declare the
same member and neither receiver type is more specific. Here both receivers are
*identical* (`T?`), so neither wins:

```dart
// lib/list/make_list_extensions.dart:4-13  (original — null-preserving)
extension MakeListExtensions<T> on T? {
  List<T>? toListIfNotNull() {            // returns List<T>?  (null when null)
    final T? self = this;
    return self == null ? null : <T>[self];
  }
}

// lib/object/nullable_more_extensions.dart:37-43  (newer — empty-on-null)
extension ToListIfNotNull<T> on T? {
  List<T> toListIfNotNull() {             // returns List<T>   (empty when null)
    final T? self = this;
    if (self == null) return <T>[];
    return <T>[self];
  }
}
```

The two are *not* duplicates — they have different return types and different
null behavior — but they share a name on the same receiver. The roadmap commit
that added the second one did not notice the existing one. The barrel exporting
both is what makes both visible at every call site.

---

## Impact

- **Who hits this:** every downstream consumer importing
  `package:saropa_dart_utils/saropa_dart_utils.dart` and calling
  `.toListIfNotNull()`. Discovered via the `saropa` Contacts app, where 14 call
  sites across 10 files use the pattern `x?.toListIfNotNull()`; the single
  ambiguous call cascades (the errored expression poisons the enclosing
  `ActivityFilters` / `ContactFilters` constructors and their downstream uses),
  producing 1000+ analyzer errors from a handful of call sites.
- **Why it matters:** this is a *compile-time* break in consumers, the most
  severe failure mode for a published library — worse than a runtime edge case.
  It shipped in a released version (v1.1.3) and cannot be worked around in the
  consumer without per-call extension overrides.
- **Note on the real call sites:** every observed consumer call uses
  `receiver?.toListIfNotNull()`. The `?.` short-circuits on null, so the method
  body only ever runs on a non-null receiver — where *both* implementations
  return the identical `<T>[value]`. So the two semantics are indistinguishable
  at those sites; the only consumer-visible effect is the ambiguity error.

---

## Suggested Fix

Rename the newer method so it no longer collides, keeping the established
`MakeListExtensions.toListIfNotNull()` (`List<T>?`) untouched. `toListOrEmpty()`
names the "null → empty list" behavior accurately; "if not null" wrongly implied
a nullable result.

```dart
// lib/object/nullable_more_extensions.dart
extension ToListOrEmpty<T> on T? {
  List<T> toListOrEmpty() {   // was: ToListIfNotNull.toListIfNotNull()
    final T? self = this;
    if (self == null) return <T>[];
    return <T>[self];
  }
}
```

A new `1.1.4` must be published; pub.dev `1.1.3` stays broken until then.
Bump the consumer constraint after publish.

---

## Missing Tests

`test/object/nullable_more_extensions_test.dart` did not exist when the colliding
method was added. A regression test must assert the renamed method's behavior
(non-null wrap, null → empty, falsy-but-non-null preserved). Tests for
`MakeListExtensions.toListIfNotNull()` already exist in
`test/list/make_list_extensions_test.dart`.

```dart
group('ToListOrEmpty.toListOrEmpty', () {
  test('should wrap a non-null value in a single-element list', () {
    const int? value = 5;
    expect(value.toListOrEmpty(), <int>[5]);
  });
  test('should return an empty list for a null receiver', () {
    const String? value = null;
    expect(value.toListOrEmpty(), <String>[]);
  });
});
```

---

## Resolution (verified)

The `toListIfNotNull` rename is **implemented in the working tree** (uncommitted,
not yet released). Verified on 2026-05-22:

- `dart analyze lib/object/nullable_more_extensions.dart` — no issues.
- `dart format` — already formatted (0 changed).
- `test/object/nullable_more_extensions_test.dart` — 33 cases pass, including the
  renamed method (non-null wrap, null → empty, falsy-but-non-null preserved) and
  all previously-untested siblings in the same file (`whenNonNull`, `mapNonNull`,
  `orElse`, `tryCast`, `isType`, `asTypeOr`, `firstOfType`).
- `test/list/make_list_extensions_test.dart` — the untouched original
  `MakeListExtensions.toListIfNotNull()` still passes.

## Changes Made

The `toListIfNotNull` rename is **implemented in the working tree**
(uncommitted, not yet released).

### `lib/object/nullable_more_extensions.dart`

**Before:**
```dart
extension ToListIfNotNull<T> on T? {
  List<T> toListIfNotNull() {
    final T? self = this;
    if (self == null) return <T>[];
    return <T>[self];
  }
}
```

**After:**
```dart
extension ToListOrEmpty<T> on T? {
  /// Wraps a non-null value in a single-element list, or returns an empty list
  /// when null. Distinct from `MakeListExtensions.toListIfNotNull` (returns
  /// `null` for a null receiver). Renamed to avoid the ambiguous-extension clash.
  List<T> toListOrEmpty() {
    final T? self = this;
    if (self == null) return <T>[];
    return <T>[self];
  }
}
```

Also landed: full dartdoc with examples for the file's other extensions
(`whenNonNull`, `mapNonNull`, `orElse`, `tryCast`, `isType`, `asTypeOr`,
`firstOfType`), the new 33-case test file
`test/object/nullable_more_extensions_test.dart`, and CHANGELOG entries under
`## [Unreleased]` (`Fixed` for the rename, `Changed` for the docs/coverage).

**Still outstanding (release ops, tracked separately — not blocking this bug's
code fix):** commit the working tree, publish `1.1.4`, and bump the consumer's
version constraint. Until `1.1.4` is published, released `1.1.3` remains broken on
pub.dev.

---

## Related: sibling collisions found in the same sweep (NOT fixed by the staged change)

A package-wide scan for same-name extension methods on the same receiver found
two more genuine ambiguities of the identical kind. These are **Open** — the
staged `toListIfNotNull` rename does not touch them, and they will break any
consumer that imports the barrel and calls them:

| Method | Receiver | Declared in (both `on String`) |
|---|---|---|
| `truncateWithEllipsis()` | `String` | `lib/string/string_extensions.dart:179` and `lib/string/string_lower_extensions.dart:8` |
| `escapeForRegex()` | `String` | `lib/string/string_manipulation_extensions.dart:166` and `lib/string/string_regex_extensions.dart:19` |

(Other scan hits were ruled out: `mostOccurrences` is type-specialized —
`Iterable<int>`/`<double>`/`<bool>`/`<Enum>` are *more specific* than
`Iterable<T>`, so no ambiguity; `substringSafe` and `words` are each declared
once, the extra hits were invocations; `replaceAll`/`split`/`startsWith`/
`toLowerCase`/`replaceAllMapped`/`toList` are built-in instance methods that
shadow any extension, so no clash.)

Recommend filing these as **BUG-002** (`truncateWithEllipsis`) and **BUG-003**
(`escapeForRegex`) and fixing all three in the `1.1.4` release so consumers are
not broken twice.

---

## Commits

- `fix(object): rename T?.toListIfNotNull → toListOrEmpty to remove ambiguous-extension clash (BUG-001)`
  — lands the rename, dartdoc/test backfill for `nullable_more_extensions.dart`,
  CHANGELOG entries, and this report's closure on `main`.

---

## Environment

- saropa_dart_utils version: **1.1.3** (released, broken on pub.dev); working tree has the rename staged but uncommitted/unreleased
- Dart SDK version: 3.12.0 (stable)
- Triggering call site: `saropa` Contacts app — `import 'package:saropa_dart_utils/saropa_dart_utils.dart';` then `x?.toListIfNotNull()` (14 sites / 10 files). Surfaced as `ambiguous_extension_member_access` in VS Code (diagnostic owner `_generated_diagnostic_collection_name_#3`).
