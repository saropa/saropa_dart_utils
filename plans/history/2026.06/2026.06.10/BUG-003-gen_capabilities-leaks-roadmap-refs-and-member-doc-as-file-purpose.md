# BUG-003: `gen_capabilities` — leaks internal `— roadmap #NNN` refs into descriptions and uses the first member's doc as the file purpose

**File:** `tool/gen_capabilities.py`
**Severity:** 🟢 Low
**Category:** Documentation (catalog header/description noise)
**Status:** Fixed in `tool/gen_capabilities.dart` (the generator is now the Dart AST version; the Python file was removed). `firstSentence` calls `stripInternalRefs` after the sentence cut to drop `roadmap #NNN` markers without leaving a dangling period, and `filePurpose` suppresses a leading `///` block when its offset matches the first declaration's doc comment (a member's dartdoc), so only a genuine library/floating doc becomes the file purpose. Verified: roadmap leaks went 164→0; `html/html_entity_data.dart` no longer shows a field doc as its purpose; `async/async_barrier_utils.dart` keeps its library doc, roadmap-stripped. Regression test: `test/tool/gen_capabilities_test.dart`.

<!-- Tooling bug, not a lib/ method bug — defect is in the CAPABILITIES.md generator.
     Two related cosmetic leaks, both in the file-header / description text path. -->

---

## Summary

Two cosmetic leaks in the customer-facing catalog:

1. Internal planning markers like `— roadmap #676` survive into emitted descriptions and file-purpose lines.
2. When a file has no library-level `///` block, the "purpose" line falls back to the first member's doc (e.g. a field's dartdoc), mislabeling a single symbol's description as the whole file's purpose.

---

## Attribution Evidence

```
tool/gen_capabilities.py:62-70    first_sentence() — passes through "— roadmap #NNN" unchanged
tool/gen_capabilities.py:156-168  parse_file() "top" extraction — collects the first /// block at the top
                                  of the file, which is a MEMBER doc when no library doc precedes it
```

Observed in `CAPABILITIES.md`:

```
## Async → async/async_barrier_utils.dart
  "Async barrier: wait for N events — roadmap #676."          <-- roadmap ref leaked

## HTML → html/html_entity_data.dart
  "Length of the longest key in [htmlNamedEntities]."          <-- first FIELD's doc used as file purpose
```

---

## Reproduction

```dart
// File async/async_barrier_utils.dart begins:
/// Async barrier: wait for N events — roadmap #676.
// CATALOG file-purpose: "Async barrier: wait for N events — roadmap #676."
// EXPECTED: "Async barrier: wait for N events." (internal ref stripped)

// File html/html_entity_data.dart begins directly with a field doc (no library doc):
/// Length of the longest key in [htmlNamedEntities].
final int htmlEntityMaxKeyLength = ...;
// CATALOG file-purpose: "Length of the longest key in [htmlNamedEntities]."
// EXPECTED: no file purpose (file has no library-level summary), not a member's doc.
```

**Frequency:** roadmap leak — every file whose top doc carries a `— roadmap #NNN` tag. Member-doc-as-purpose — every file with no library-level `///` whose first declaration is documented.

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | Descriptions carry no internal backlog markers; file "purpose" comes only from a genuine library-level doc, else is empty. |
| **Actual** | `— roadmap #NNN` appears in the external catalog; a member's doc is promoted to the file purpose when no library doc exists. |

---

## Root Cause

```python
# tool/gen_capabilities.py:62-70  (first_sentence)
# No stripping of internal markers; "— roadmap #676" is part of the first sentence and is kept.

# tool/gen_capabilities.py:156-168  (parse_file "top" extraction)
top = []
for raw in lines:
    s = raw.strip()
    if s.startswith("///"):
        top.append(s[3:].strip())   # <-- collects the first /// block at file top,
    elif top:                       #     which is the first MEMBER's doc when there is
        break                       #     no `library;`-level doc above it.
    ...
```

The "top" loop only skips blank / `//` / `library;` lines; it does not require the `///` block to be a true library-level doc (i.e. one that precedes no declaration on the next non-blank line, or that sits above a `library;` directive).

---

## Impact

- Cosmetic, but the catalog explicitly targets "teams evaluating or adopting the library." Internal roadmap numbers read as noise to an external audience.
- A field-level description shown as the file's purpose mildly misrepresents what the file is for.

---

## Suggested Fix

- In `first_sentence` (or a small cleanup step), strip a trailing `[—-]\s*roadmap\s*#\d+` (and any standalone `roadmap #NNN`) before length-clamping.
- In `parse_file`, only treat the top `///` block as a file purpose when it is NOT immediately followed by a declaration (i.e. it is separated by a blank line or sits above `library;`); otherwise emit an empty purpose so a member doc is never promoted.

---

## Missing Tests

```dart
expect(firstSentence(['Async barrier: wait for N events — roadmap #676.']),
       equals('Async barrier: wait for N events.'));
// File whose first /// is directly above a field declaration → purpose == ''.
```

---

## Environment

- Generator: `tool/gen_capabilities.py` (`first_sentence` line 62; `parse_file` top-doc loop line 156)
- Triggering output: `CAPABILITIES.md` file-purpose lines carrying `— roadmap #NNN` or a member's dartdoc


## Finish Report (2026-06-10)

**Scope:** (C) docs/tooling only — `tool/gen_capabilities.dart` (the Dart AST generator that replaced the removed `tool/gen_capabilities.py` mid-session), the regenerated `CAPABILITIES.md`, `CHANGELOG.md`, and a new `test/tool/gen_capabilities_test.dart`. No `lib/` API change.

**Context note:** This bug was originally written against `tool/gen_capabilities.py`. During the session a parallel workstream replaced that Python generator with an analyzer-AST Dart generator (commit `43b0484`, v1.4.0 prep). The fixes were therefore applied to `tool/gen_capabilities.dart`, where the same defects were present (BUG-002 and BUG-003) or already resolved by the AST rewrite (BUG-001).

**Fix summary:**
- BUG-001 (wrong symbol names / private leaks): resolved by the AST rewrite — names/kinds come straight from the analyzer. Verified: `memoizeFuture`/`sortBy`/`onFlush` correct, zero `Function`/`RegExp`/`Duration`/`static` rows.
- BUG-002 (sentence truncation): `firstSentence` now uses `sentenceEnd`, which ignores periods inside backticks/balanced parens, abbreviations, and single-letter dots.
- BUG-003 (roadmap leak + member-doc-as-purpose): `firstSentence` strips `roadmap #NNN` after the sentence cut (164 leaks → 0); `filePurpose` suppresses a leading block whose offset equals the first declaration's doc comment.

**Verification:** `dart run tool/gen_capabilities.dart` → 1928 symbols / 393 files; `dart analyze tool/gen_capabilities.dart` clean; `flutter test test/tool/gen_capabilities_test.dart` → 11/11 pass.
