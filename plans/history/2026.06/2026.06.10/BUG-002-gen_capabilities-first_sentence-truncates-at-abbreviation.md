# BUG-002: `gen_capabilities.first_sentence()` — truncates at the first `. `, dropping the example after `e.g.` / inline abbreviations

**File:** `tool/gen_capabilities.py`
**Severity:** 🟡 Medium
**Category:** Logic Error (catalog descriptions truncated)
**Status:** Fixed in `tool/gen_capabilities.dart` (the generator is now the Dart AST version; the Python file was removed). `firstSentence` now uses `sentenceEnd`, which treats a period as a sentence boundary only when it is outside backticks and balanced parentheses, is followed by a space/end-of-string, and is not an abbreviation (`e.g.`, `i.e.`, `vs.`) or single-letter dot. Regression test: `test/tool/gen_capabilities_test.dart`.

<!-- Tooling bug, not a lib/ method bug — defect is in the CAPABILITIES.md generator. -->

---

## Summary

`first_sentence()` keeps text up to the first period that is followed by whitespace or end-of-string (`\.(\s|$)`). Dart docs routinely contain `e.g.`, `i.e.`, abbreviations, and periods inside backticks/parentheses, so the cut lands mid-phrase — most often right after `(e.g.`, discarding the concrete example that is the most useful part of the description.

---

## Attribution Evidence

```
tool/gen_capabilities.py:62-70   def first_sentence(doc): ... m = re.search(r"\.(\s|$)", text); text = text[: m.start()+1]
```

The truncated rows are visible throughout `CAPABILITIES.md` (every description ending in `(e.g.` or a dangling clause).

---

## Reproduction

```dart
/// Target false positive rate (e.g. 0.01 for 1%).
final double falsePositiveRate;
// CATALOG: | `falsePositiveRate` | ... | Target false positive rate (e.g. |
// EXPECTED: full sentence incl. "0.01 for 1%)."

/// Capitalizes the first letter after sentence boundaries (start or after `. ? !`).
String capitalizeSentences() { ... }
// CATALOG: ...after sentence boundaries (start or after `.        <-- cut inside backticks

/// Splits [text] into sentences (split on . ! ?).
List<String> tokenizeSentences(String text) { ... }
// CATALOG: Splits [text] into sentences (split on .              <-- cut after "on ."

/// Normalize path (resolve . and .. segments).
String pathNormalize(String path) { ... }
// CATALOG: Normalize path (resolve .                              <-- cut after "resolve ."
```

**Frequency:** Always, whenever the first sentence contains `. ` before its true end (very common: `e.g.`, `i.e.`, `vs.`, single-letter `.`, `.` inside backticks/parens).

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | The full first sentence (or first paragraph) is kept; abbreviations and inline periods do not end it. |
| **Actual** | Text is cut at the first `. `, so any description with an inline period loses everything after it. |

---

## Root Cause

```python
# tool/gen_capabilities.py:62-70
def first_sentence(doc):
    text = re.sub(r"\s+", " ", " ".join(doc)).strip()
    text = text.split("```")[0].strip()
    m = re.search(r"\.(\s|$)", text)   # <-- matches the `.` in "e.g.", "i.e.",
    if m:                              #     "(split on .", "resolve .", etc.
        text = text[: m.start() + 1]
    ...
```

`\.(\s|$)` treats every "period + space" as a sentence boundary. There is no allowlist for abbreviations and no awareness of periods inside backticks or unbalanced parentheses.

---

## Impact

- Adopters reading the catalog lose the example/qualifier that disambiguates each util (`(e.g. 0.01 for 1%)`, `(split on . ! ?)`, `(resolve . and .. segments)`).
- The loss is silent and pervasive — it affects DateTime, Number, String, Parsing, Collections descriptions throughout.

---

## Suggested Fix

Stop cutting at abbreviation periods. Options, cheapest first:

- Keep the first **paragraph** (split on blank line / first `///`-block) rather than the first sentence, and only fall back to a length cap (the existing `len > 160` clamp already bounds it).
- If a single-sentence cut is still wanted, exclude common abbreviations (`e.g.`, `i.e.`, `etc.`, `vs.`, single letters) and do not treat a `.` inside backticks or an unbalanced `(` as a boundary.

The 160-char clamp at `:68-69` already prevents runaway length, so taking more text is safe.

---

## Missing Tests

```dart
expect(firstSentence(['Target false positive rate (e.g. 0.01 for 1%).']),
       equals('Target false positive rate (e.g. 0.01 for 1%).'));
expect(firstSentence(['Splits [text] into sentences (split on . ! ?).']),
       equals('Splits [text] into sentences (split on . ! ?).'));
```

---

## Environment

- Generator: `tool/gen_capabilities.py` (`first_sentence`, line 62)
- Triggering output: `CAPABILITIES.md` descriptions ending in `(e.g.` or a dangling clause


## Finish Report (2026-06-10)

**Scope:** (C) docs/tooling only — `tool/gen_capabilities.dart` (the Dart AST generator that replaced the removed `tool/gen_capabilities.py` mid-session), the regenerated `CAPABILITIES.md`, `CHANGELOG.md`, and a new `test/tool/gen_capabilities_test.dart`. No `lib/` API change.

**Context note:** This bug was originally written against `tool/gen_capabilities.py`. During the session a parallel workstream replaced that Python generator with an analyzer-AST Dart generator (commit `43b0484`, v1.4.0 prep). The fixes were therefore applied to `tool/gen_capabilities.dart`, where the same defects were present (BUG-002 and BUG-003) or already resolved by the AST rewrite (BUG-001).

**Fix summary:**
- BUG-001 (wrong symbol names / private leaks): resolved by the AST rewrite — names/kinds come straight from the analyzer. Verified: `memoizeFuture`/`sortBy`/`onFlush` correct, zero `Function`/`RegExp`/`Duration`/`static` rows.
- BUG-002 (sentence truncation): `firstSentence` now uses `sentenceEnd`, which ignores periods inside backticks/balanced parens, abbreviations, and single-letter dots.
- BUG-003 (roadmap leak + member-doc-as-purpose): `firstSentence` strips `roadmap #NNN` after the sentence cut (164 leaks → 0); `filePurpose` suppresses a leading block whose offset equals the first declaration's doc comment.

**Verification:** `dart run tool/gen_capabilities.dart` → 1928 symbols / 393 files; `dart analyze tool/gen_capabilities.dart` clean; `flutter test test/tool/gen_capabilities_test.dart` → 11/11 pass.
