# BUG-001: `gen_capabilities.symbol_name()` — emits the RHS / return-type constructor token instead of the declared symbol name

**File:** `tool/gen_capabilities.py`
**Severity:** 🔴 High
**Category:** Logic Error (catalog data wrong)
**Status:** Fixed — the generator was rewritten to scrape the Dart analyzer AST (`tool/gen_capabilities.dart`, replacing the regex-based `tool/gen_capabilities.py`). The AST exposes each declaration's real name and kind directly, so return-type `Function()`, RHS constructors, record returns, and nested-generic param types can no longer masquerade as the name, and private members are filtered by their true identifier. Verified in the regenerated `CAPABILITIES.md`: `memoizeFuture`/`sortBy`/`onFlush` are named correctly and zero `Function`/`RegExp`/`Duration`/`static` rows remain.

<!-- Tooling bug, not a lib/ method bug. The defect is in the CAPABILITIES.md
     generator, so the template's lib/-specific sections (test/<category>/, lib
     line refs) are adapted to point at tool/ instead. -->

---

## Summary

`symbol_name()` resolves a declaration's name with `decl_callable.search(line)`, which returns the **first** `identifier(` found anywhere on the line. For declarations whose return type, field initializer, parameter type, or leading modifier contains a `Name(`, the generator names the symbol after that token instead of the real declared identifier. The genuine public name is lost, and — because the resolved token (`RegExp`, `Duration`, …) is not `_`-prefixed — private `_`-prefixed declarations slip past the public-only filter and appear in the catalog.

---

## Attribution Evidence

Defect is in the generator, not in `lib/`. The mis-named rows in `CAPABILITIES.md` are produced by:

```
tool/gen_capabilities.py:47   decl_callable = re.compile(r"([A-Za-z_]\w*)\s*(?:<[^>]*>)?\s*\(")
tool/gen_capabilities.py:83-85   m = decl_callable.search(line); return m.group(1), "method"
tool/gen_capabilities.py:135-138 public filter checks the RESOLVED name, then upper-case → "constructor"
```

Real `lib/` declarations that trigger it (all confirmed by grep):

```bash
grep -rn "RegExp\|Function\|Duration\|static" \
  lib/parsing/email_validation_utils.dart \
  lib/async/memoize_future_utils.dart \
  lib/datetime/date_time_comparison_extensions.dart \
  lib/html/html_utils.dart \
  lib/iterable/iterable_extensions.dart
# lib/parsing/email_validation_utils.dart:2  final RegExp _emailRegex = RegExp(
# lib/async/memoize_future_utils.dart:4       Future<T> Function() memoizeFuture<T>(AsyncAction<T> fn) {
# lib/datetime/date_time_comparison_extensions.dart:5  const Duration _oneDay = Duration(days: 1);
# lib/html/html_utils.dart:120                static ({String char, int consumed})? _tryNumericEntity(
# lib/iterable/iterable_extensions.dart:220   List<T> sortBy<K extends Comparable<K>>(K Function(T) keyOf) {
```

---

## Reproduction

Four distinct declaration shapes, each producing a wrong row in `CAPABILITIES.md`:

```dart
// 1. Function-typed RETURN TYPE — real name `memoizeFuture` lost.
Future<T> Function() memoizeFuture<T>(AsyncAction<T> fn) { ... }
// CATALOG: | `Function` | constructor | Cache single async result ... |
// EXPECTED: | `memoizeFuture` | method | ... |

// 2. RHS constructor in a field initializer — private `_emailRegex` leaks as `RegExp`.
final RegExp _emailRegex = RegExp(r'...');
// CATALOG: | `RegExp` | constructor | Email validation ... |
// EXPECTED: row omitted (declaration is private) OR named `emailRegex` if public.

// 3. Private const with a constructor RHS — `_oneDay` leaks as `Duration`.
const Duration _oneDay = Duration(days: 1);
// CATALOG: | `Duration` | constructor | One full day ... |
// EXPECTED: row omitted (private).

// 4. Record-type return + leading `static` — private `_tryNumericEntity` leaks as `static`.
static ({String char, int consumed})? _tryNumericEntity(String s, int offset) { ... }
// CATALOG: | `static` | method | Decodes a numeric entity at [offset] ... |
// EXPECTED: row omitted (private).

// 5. Nested generic bound makes `<[^>]*>` stop early, so `Function(` in a PARAM wins.
List<T> sortBy<K extends Comparable<K>>(K Function(T) keyOf) { ... }
// CATALOG: | `Function` | constructor | Sorts by [keyOf] and returns a new list. |
// EXPECTED: | `sortBy` | method | ... |
// (Contrast: groupBy<K>(K Function(T) keyOf) resolves correctly — no nested bound.)
```

**Frequency:** Always, for any declaration matching these shapes.

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | Each row is named after the declared identifier; private (`_`-prefixed) declarations are excluded entirely. |
| **Actual** | Rows are named after the first `Name(` on the line (`Function`, `RegExp`, `Duration`, `Random`, or even the `static` keyword); private declarations whose RHS/return token is public-looking leak into the catalog. |

---

## Root Cause

```python
# tool/gen_capabilities.py:47
decl_callable = re.compile(r"([A-Za-z_]\w*)\s*(?:<[^>]*>)?\s*\(")

# tool/gen_capabilities.py:83-85  (inside symbol_name)
m = decl_callable.search(line)            # <-- .search scans the WHOLE line
if m and m.group(1) not in KEYWORDS:      #     and returns the FIRST identifier(
    return m.group(1), "method"           #     which is often the return type,
                                          #     a field RHS, or a param type.
```

Two compounding problems:

1. `.search` (not an anchored match) grabs the first `identifier(` anywhere on the line. Return-type function types (`… Function() name(...)`), field initializers (`= RegExp(...)` / `= Duration(...)`), record-return modifiers (`static (…)? _name(...)`), and parameter types (`K Function(T)`) all win over the real declared name.
2. The public-only filter at `:135` (`not name.startswith("_")`) tests the **resolved** name, not the source declaration. `_oneDay`/`_emailRegex`/`_tryNumericEntity` are private, but their resolved tokens (`Duration`/`RegExp`/`static`) are not `_`-prefixed, so the filter passes and private internals leak.

The `<[^>]*>` generic group also cannot span nested bounds (`<K extends Comparable<K>>`), so methods with nested generics fall through to the next `(` — usually a `Function(` parameter type.

---

## Impact

- The catalog's headline claim is "a complete, **per-symbol** catalog … for teams evaluating or adopting the library." Adopters searching for real APIs (`memoizeFuture`, `sortBy`, …) will not find them — they are listed as `Function`.
- Private implementation details (`_emailRegex`, `_oneDay`, `_tryNumericEntity`) are advertised as public surface.
- The `total_syms` count in the header is inflated by leaked private rows and skewed by collapsed/duplicate `Function` rows, so "Covers N public symbols" is wrong.

---

## Suggested Fix

Resolve the name from the declaration's own grammar rather than the first `Name(` on the line:

- Anchor the callable match so it skips the return type. A practical approach: strip a leading return-type token sequence (including function types `… Function(...)` and record types `(...)`) before applying `decl_callable`, OR match the method name as the identifier that is immediately followed by an (optionally generic) parameter list AND is the last such identifier before the opening `{`/`=>`/`;`.
- Make the generic group tolerate nested bounds (balanced `<…>` rather than `<[^>]*>`), so `sortBy<K extends Comparable<K>>` resolves to `sortBy`.
- Apply the private-name filter to the **source field/identifier name**, not the resolved RHS token, so `final X _y = Z(...)` and `static (...)? _z(...)` are excluded.

Keep within project limits (functions ≤20 lines). A focused helper that returns `(name, isPrivate)` from the left-hand side keeps `symbol_name` small.

---

## Missing Tests

The generator has no tests. Add `tool/` fixture tests (or a `test/tool/` harness) asserting `symbol_name()` against each shape above:

```dart
// pseudo — assert resolved (name, kind) per input line
expect(symbolName('Future<T> Function() memoizeFuture<T>(AsyncAction<T> fn) {'),
       equals(('memoizeFuture', 'method')));
expect(symbolName('const Duration _oneDay = Duration(days: 1);'),
       isNull); // private — excluded
expect(symbolName('List<T> sortBy<K extends Comparable<K>>(K Function(T) keyOf) {'),
       equals(('sortBy', 'method')));
```

---

## Environment

- saropa_dart_utils: see `pubspec.yaml` version
- Generator: `tool/gen_capabilities.py`
- Triggering output: `CAPABILITIES.md` rows named `Function` / `RegExp` / `Duration` / `Random` / `static`


## Finish Report (2026-06-10)

**Scope:** (C) docs/tooling only — `tool/gen_capabilities.dart` (the Dart AST generator that replaced the removed `tool/gen_capabilities.py` mid-session), the regenerated `CAPABILITIES.md`, `CHANGELOG.md`, and a new `test/tool/gen_capabilities_test.dart`. No `lib/` API change.

**Context note:** This bug was originally written against `tool/gen_capabilities.py`. During the session a parallel workstream replaced that Python generator with an analyzer-AST Dart generator (commit `43b0484`, v1.4.0 prep). The fixes were therefore applied to `tool/gen_capabilities.dart`, where the same defects were present (BUG-002 and BUG-003) or already resolved by the AST rewrite (BUG-001).

**Fix summary:**
- BUG-001 (wrong symbol names / private leaks): resolved by the AST rewrite — names/kinds come straight from the analyzer. Verified: `memoizeFuture`/`sortBy`/`onFlush` correct, zero `Function`/`RegExp`/`Duration`/`static` rows.
- BUG-002 (sentence truncation): `firstSentence` now uses `sentenceEnd`, which ignores periods inside backticks/balanced parens, abbreviations, and single-letter dots.
- BUG-003 (roadmap leak + member-doc-as-purpose): `firstSentence` strips `roadmap #NNN` after the sentence cut (164 leaks → 0); `filePurpose` suppresses a leading block whose offset equals the first declaration's doc comment.

**Verification:** `dart run tool/gen_capabilities.dart` → 1928 symbols / 393 files; `dart analyze tool/gen_capabilities.dart` clean; `flutter test test/tool/gen_capabilities_test.dart` → 11/11 pass.
