# Bug Report Guide

How to file, investigate, and close bugs in `saropa_dart_utils`.

This project is a **Dart utility library** (280+ extension methods). Bugs fall into two kinds, and both live under `bugs/`:

1. **Library bugs** — a utility method or extension behaves wrong (data loss, off-by-one, undocumented edge case, missing test). Use the [`BUG-NNN-...` naming](#file-naming) and the [Bug Report Template](#bug-report-template).
2. **Lint-rule exclusion decisions** — a `saropa_lints` rule (a consumed dev dependency, configured in `analysis_options*.yaml`) fires on code that is correct here, and the team decides to exclude it. Use the [rule-name naming](#file-naming) and the [Lint Exclusion Template](#lint-exclusion-template). **The rule itself is not fixed here** — `saropa_lints` is an external package; see [Attribution: library bug vs consumed dependency](#attribution-library-bug-vs-consumed-dependency).

---

## File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Library bug | `BUG-NNN-method-short-description.md` | `BUG-010-mapToMapStringDynamic-silent-data-loss.md` |
| Lint exclusion decision | `rule_name.md` | `require_test_description_convention.md` |

Use lowercase with underscores/hyphens. `NNN` is the next free number (check the highest existing `BUG-NNN-*` file). Check existing files before creating.

---

## Attribution: library bug vs consumed dependency

**Before filing, prove where the bug lives.** A bug surfaced while working in this repo does not mean the defect is in this repo. This library consumes `saropa_lints`, `jiffy`, `collection`, and `characters`. A diagnostic's `source` / `owner` label in the VS Code Problems panel is not attribution — it is a label the emitter chose.

### Library bug — defect is in `saropa_dart_utils`

Confirm the method or extension lives here:

```bash
grep -rn "methodName" lib/
# Expected: lib/<category>/<category>_<type>.dart:NN: ... methodName ...
```

If the grep lands in `lib/`, file a [library bug](#bug-report-template) here.

### Lint false positive — rule lives in `saropa_lints`

If a `saropa_lints` diagnostic fires on correct code, the **rule fix belongs upstream in the `saropa_lints` repo**, not here. Two outcomes, and you may do both:

- **Fix upstream:** file a false-positive bug in `saropa_lints/bugs/` (that repo has its own guide and the `lib/src/rules/` machinery). Confirm the rule is actually defined there: `grep -rn "'rule_name'" ../saropa_lints/lib/src/rules/`.
- **Exclude locally:** if this project should simply not enforce the rule, record the decision here with the [Lint Exclusion Template](#lint-exclusion-template) and add the exclusion to `analysis_options_custom.yaml`.

**Reverse case:** if the diagnostic label resembles `saropa_lints` but the grep in `../saropa_lints/lib/src/rules/` returns nothing, the emitter is another plugin/extension. Name the suspected emitter, paste the positive grep from that repo, and file it there — do not open a bug here on the theory that "saropa_lints probably registers it somehow."

### Why this section exists

We have had bugs misattributed in both directions — a library logic bug blamed on a lint rule, and a lint false positive logged as a library bug. In every case the fix agent saw a label, assumed a location, and either punted the work as "somebody else's" or shipped a fix in the wrong tree. The only defense is grep evidence pasted directly in the report.

---

## Bug Report Template

For library bugs. Copy the block below into a new `BUG-NNN-...md` file.

````markdown
# BUG-NNN: `methodName()` — Short, Specific Title

**File:** `lib/<category>/<category>_<type>.dart`
**Severity:** 🔴 High / 🟡 Medium / 🟢 Low
**Category:** Data Loss / Logic Error / Edge Case / Missing Test / Documentation
**Status:** Open

<!-- Status values: Open → Investigating → Fix Ready → Closed -->

---

## Summary

One or two sentences: what happens, what should happen instead.

---

## Attribution Evidence

Grep proof that the defect lives in `saropa_dart_utils`. See "Attribution" in the guide.

```bash
grep -rn "methodName" lib/
# Expected: lib/<category>/<category>_<type>.dart:NN: ... methodName ...
```

If the behavior comes from a `saropa_lints` rule rather than this library's code, this is the wrong template — see [Lint Exclusion Template](#lint-exclusion-template).

---

## Reproduction

Minimal Dart code that triggers the bug. This is the single most important section.

```dart
// Paste the smallest code that reproduces the issue.
// Mark expected vs actual with comments.
final result = SomeClass.method(input);
print(result); // ACTUAL: wrong value — EXPECTED: correct value
```

**Frequency:** Always / Only with specific patterns / Intermittent

---

## Expected vs Actual

| | Behavior |
|---|---|
| **Expected** | ... |
| **Actual** | ... |

---

## Root Cause

<!-- Fill in during investigation. Explain the *mechanism*: which line / branch
     evaluates wrong, and why. Reference specific lines in the lib file. -->

```dart
// lib/<category>/<category>_<type>.dart ~line NN
// Show the offending code and annotate the defect.
```

---

## Impact

- Who hits this, under what real-world input (Unicode, empty, null, extreme numbers, timezone, off-by-one).
- Why the failure mode matters (silent data loss is worse than throwing, etc.).

---

## Suggested Fix

```dart
// Describe the code change. Keep within project limits:
// functions ≤20 lines, ≤3 params, ≤2 nesting levels.
```

---

## Missing Tests

What test cases are absent. Tests live in `test/<category>/<category>_<type>_test.dart`.

```dart
group('methodName edge cases', () {
  test('should ... when ...', () {
    expect(SomeClass.method(input), equals(expected));
  });
});
```

---

## Changes Made

<!-- Fill in when a fix is written. -->

### `lib/<category>/<category>_<type>.dart` (line NN)

**Before:**
```dart
old code
```

**After:**
```dart
new code
```

---

## Commits

<!-- Add commit hashes as fixes land. -->
- `abcdef0` fix: description

---

## Environment

- saropa_dart_utils version:
- Dart SDK version:
- Triggering input / call site:
````

---

## Lint Exclusion Template

For recording a decision to exclude a `saropa_lints` rule in this project. Copy into a new `rule_name.md` file. (Matches the existing files in this folder, e.g. `require_test_description_convention.md`.)

````markdown
# rule_name

## NNN violations | Severity: info/warning/error

### Rule Description
What the rule enforces.

### Assessment
- **False Positive**: Yes/No — explain whether the rule flags genuinely correct code here.
- **Should Exclude**: Yes/No — cost/benefit of complying vs excluding.

### Affected Files
- N files across `<dir>/`

### Recommended Action
EXCLUDE — add `rule_name: false` to `analysis_options_custom.yaml`, with one-line reason.
or
FIX UPSTREAM — file false-positive bug in `saropa_lints/bugs/` (rule defect, not a local style choice).
or
COMPLY — change the flagged code; the rule is correct.
````

---

## What Makes a Good Bug Report

### Title

- Start with the bug number and method in backticks: `` BUG-NNN: `methodName()` ``
- Classify the failure: "silent data loss", "off-by-one", "undocumented edge case"
- Be specific: "loses data on key collision after `toString()`" beats "wrong behavior"

### Reproduction

- **Smallest possible code** that triggers the bug — strip everything unrelated
- Mark expected vs actual inline with comments
- If the bug only triggers with specific input (empty, null, Unicode, leap year, scientific notation), include that input
- If it comes from a real call site, anonymize but preserve the structure that matters

### Root Cause

- Explain the **mechanism**: which line / branch evaluates wrong, and why
- Reference specific line numbers in the lib source file
- Name the input class that exposes it (empty, null, collision, boundary)

---

## Bug Categories

### Data Loss

A method silently drops or overwrites data.

**Investigation focus:**
- Where does the value get discarded (overwrite, `putIfAbsent`, truncation)?
- Is the loss silent (no exception, no log)? Silent loss is worse than throwing.
- Should the method throw, return nullable, or surface a count?

### Logic Error

The method returns a wrong result for valid input.

**Investigation focus:**
- Which branch / operator is wrong (`firstIndexOf` vs `lastIndexOf`, `<=` vs `<`)?
- Does the contract in the dartdoc match the implementation?
- Is there an off-by-one at a boundary?

### Edge Case

The method mishandles a boundary the docs don't mention.

**Investigation focus:**
- Empty string `''`, null, Unicode `'世界'`, emoji `'👋'`, very long input
- Zero, negative, `double.infinity`, `NaN`, max/min int
- Leap years, DST transitions, end of month/year, min/max `DateTime`
- Scientific notation, locale-dependent formatting

### Missing Test

Logic is correct but untested, so regressions are undetected.

**Investigation focus:**
- Which scenarios in `test/<category>/...` are absent?
- Does the new test fail before the fix and pass after?

### Documentation

Behavior is correct but the dartdoc misleads or omits an edge case.

**Investigation focus:**
- Does the doc describe what happens for empty / null / collision input?
- Does a parameter name imply a guarantee the method doesn't keep?

---

## Investigation Checklist

Use this when diagnosing a new bug.

- [ ] **Attribution grep** — `grep -rn "methodName" lib/` lands in `lib/`. If the behavior is a `saropa_lints` diagnostic, this is an exclusion decision, not a library bug
- [ ] **Reproduce it** — create a minimal Dart snippet that triggers the behavior
- [ ] **Read the source** — find the method and trace the logic line by line
- [ ] **Check the contract** — does the dartdoc match what the code does?
- [ ] **Test the edges** — empty, null, Unicode, emoji, zero, negative, extremes, boundaries
- [ ] **Check existing tests** — does `test/<category>/...` cover this? If not, that is the test gap
- [ ] **Run the test** — `dart test test/<category>/<category>_<type>_test.dart` to confirm current behavior
- [ ] **Check CODE_INDEX.md** — is there already a utility that does this correctly, making the buggy one redundant?

---

## Common Pitfalls

These patterns have caused bugs before. Check for them during investigation.

| Pitfall | Why It Breaks | Correct Pattern |
|---------|---------------|-----------------|
| Attributing behavior by its Problems-panel label | `source: "saropa_lints"` does not mean the defect is in this repo | Grep `lib/` for the method; attribution is `file:line`, not a label |
| Silent overwrite on `toString()` key collision | `1` (int) and `'1'` (String) both stringify to `'1'` | Detect collision, throw or keep-first explicitly, document it |
| `lastIndexOf` where `firstIndexOf` is meant | Returns the wrong span for repeated delimiters | Match the operator to the documented contract |
| Off-by-one at a boundary | `<=` vs `<` on length / index | Test the exact boundary value, not just interior values |
| Counterintuitive zero / empty behavior | `take(0)` returning everything instead of nothing | Decide the contract, document it, test the zero case |
| Stringifying without grapheme awareness | `length` counts code units, not user-perceived characters | Use `characters` package for grapheme-cluster operations |
| Scientific-notation numbers | `num.toString()` yields `1e+21`, breaks digit counting | Handle the exponent form or document the limit |
| Nullable return masking an error | Returning `null` for both "empty" and "failed" | Distinguish the cases or document which `null` means what |
| Test asserts the bug, not the fix | Test was written against current (wrong) output | Write the test to assert *correct* behavior; watch it fail first |

---

## Fix Requirements

Every bug fix must satisfy these before it can be closed.

### Code

- [ ] Fix addresses the **root cause**, not just the symptom
- [ ] Fix includes a comment explaining what was wrong and why the new code is correct
- [ ] Functions stay ≤20 lines, ≤3 parameters, ≤2 levels of nesting, files ≤200 lines
- [ ] No `// ignore:` comments added to suppress diagnostics
- [ ] Reuse checked against `CODE_INDEX.md` before adding new code

### Tests

- [ ] Test added in `test/<category>/<category>_<type>_test.dart` reproducing the exact case
- [ ] Test fails against the old code, passes against the fix
- [ ] Edge cases covered: empty, null, Unicode, emoji, extremes, boundaries
- [ ] Existing tests still pass: `dart test`

### Quality Gates

- [ ] `dart analyze --fatal-infos` — zero issues
- [ ] `dart format` — no changes needed
- [ ] `dart test` — all tests pass

### Documentation

- [ ] `CHANGELOG.md` updated under `## [Unreleased]` → `### Fixed`
- [ ] `CODE_INDEX.md` / `CODEBASE_INDEX.md` updated if capabilities or structure changed
- [ ] `README.md` examples updated if user-facing behavior changed
- [ ] Bug report file updated with root cause, changes, and commit hashes
- [ ] Status updated to `Closed`

---

## Lifecycle

```
Open
  │
  ▼
Investigating       ← actively diagnosing, root cause section being filled in
  │
  ▼
Fix Ready           ← code written, tests pass, awaiting commit
  │
  ▼
Closed              ← merged, verified, file moved to history
```

### Moving to History

When a bug is closed, move its file:

```
bugs/BUG-NNN-method-description.md
  → bugs/history/YYYYMMDD/BUG-NNN-method-description.md
```

Use the date the bug was closed. Create the date folder if it does not exist.

---

## Severity Guide

| Severity | Meaning | Examples |
|----------|---------|---------|
| 🔴 High | Silent data loss, wrong result on common input, forces caller workarounds | Key-collision data loss, off-by-one in a parsing helper |
| 🟡 Medium | Undocumented edge case, wrong result on uncommon input | Counterintuitive zero behavior, scientific-notation miscount |
| 🟢 Low | Cosmetic, missing test on already-correct logic, doc gap | Duplicate test, dartdoc omits an edge case |

---

## Linking

- Reference bugs from commits: `fix: description (BUG-NNN)`
- Reference bugs from docs: `[bug file](bugs/BUG-NNN-method-description.md)`
- Reference related history: `Related: bugs/history/YYYYMMDD/filename.md`

---

## Policy Note

Do not log project-specific bug findings directly in this guide.

- This file is process documentation only.
- Every concrete issue must live in a separate file under `bugs/` using the naming rules above.
- If you discover this happened, move the content into dedicated bug files immediately and leave only this policy note.
