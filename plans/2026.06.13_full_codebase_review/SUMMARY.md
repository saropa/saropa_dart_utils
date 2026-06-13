# Full Codebase Review — Synthesis Report

**Package:** saropa_dart_utils (v1.6.1 at start) · **Scope:** all 476 `lib/` files + tests, docs,
changelog, plans/history · **Date:** 2026-06-13

## Method

- **Phase 1** — eight cross-cutting sweeps (web-int model, release-stripped asserts, randomness,
  `DateTime.now()` races, Unicode, numeric edges, boundaries, unsafe collection access).
- **Phase 2** — exhaustive per-file read of every `lib/` file. The algorithm-dense core was read
  directly; breadth was covered by 11 independent subagent audits, **every flagged finding then
  re-verified against the live code** before any change. Web-int claims anchored to the official
  Dart number-representation reference.
- **Phases 3–5** — docs/metadata, test quality, this synthesis.
- Every fix shipped with a regression test; `dart analyze` kept clean throughout; ~18 commits.

## Headline

The v1.6.0 self-audit was genuinely thorough on **algorithm correctness** — every textbook
algorithm verified (quickselect, Gale-Shapley, knapsack, LIS, Damerau, LCS, Fenwick, Welford,
min-max heap, A*, Floyd-Warshall, MST, PageRank, all stats formulas, semver, cron, Luhn/ISBN, CSV,
JSON-path, RFC-6570 templates, WCAG contrast). The bugs that survived were almost entirely
**cross-cutting**: the web/JS 53-bit int model, release-stripped precondition asserts,
grapheme-vs-code-unit slicing, RNG choice, and doc drift — plus a few bespoke-logic slips
(path traversal, ordinal teens, renameKeys). That is exactly the profile this review targeted.

## Findings fixed (by severity)

### S1 — security
1. **`isPathSafe` directory-traversal bypass** — escape check measured filesystem-root depth, so a
   path could climb above the supplied root undetected (`isPathSafe('../secret','home/user')` →
   `true`). Now rejects climbing above the root directory.

### S2 — silently-wrong / hang / crash
- **18-file release-stripped precondition asserts** → `if`-throw (÷0 / hang / silent-wrong cases).
- **`stableHash` & `HyperLogLog` web-safety** — 64-bit math reworked to 32-bit limbs; VM output
  proven identical over 200k/500k inputs vs a BigInt ground truth; web now matches the VM.
- **`int.ordinal()`** — `111`→`111st`, negatives wrong; now last-two-digit teen test + `abs()`.
- **`dijkstra*` negative-cycle hang** — added a settled set (terminates; non-negative results unchanged).
- **6 grapheme-vs-code-unit slicers** — `removeFirstLastChar`, `removeMatchingWrappingBrackets`,
  `removePrefix`/`removeSuffix`, `cleanJsonResponse`, `isImageUri`/`fileExtension`.
- **`hasInvalidUnicode`/`removeInvalidUnicode`** — wrong constant (0xDC07 → U+FFFD).
- **`safeTempName`** — non-secure RNG → `Random.secure()` + length guard.
- **`AsyncSemaphore.release()`** — over-release now throws instead of corrupting the permit count.
- **`pathExtension`/`pathWithoutExtension`** — dot in a directory name treated as the extension.
- **`Map.renameKey`/`renameKeys`** — chained-rename data loss + null-value drop.

### S3 — contract / doc-vs-code / robustness
- `deepMerge` shared nested values by reference (now deep-cloned) · `parseIpv4` accepted
  sign/whitespace/leading-zero octets · `parseQueryString` didn't decode `+` · `flattenHierarchy`
  dropped orphan-parent nodes · `formatNumberLocale`/`formatFileSize` formatting bugs ·
  `retryWithBackoff` unclamped shift · `num.isNotZeroOrNegative`/`isZeroOrNegative` NaN ·
  doc corrections: `hexToInt`, `varint`, `html_sanitizer` (not an allowlist), `withTimeout`.

### S4 — quality / style
- `roundToSignificantDigits` power-of-ten edge · `FenwickTree(size)` constructor assert →
  throw · `prettyPrint` indentation · `rangeDouble` float drift + zero-step infinite loop ·
  `map.getRandomListExcept` injectable RNG · docs: `toPercentage`, `topKIndices` · de-nested
  ternary in `dependency_resolver`.

### Feature added (non-breaking)
- `debounceCancelable` / `throttleCancelable` + `CancelableCallback` — fixes the
  fire-after-dispose / Timer-leak in the plain `debounce`/`throttle` closures.

## Accepted as-is (verified, deliberately not changed)
- NaN passed to `clampToInt`/`roundToMultiple`/`clampNonNegative`/`truncateToDecimals` throws
  `UnsupportedError` — acceptable caller-error signal; guarding would change semantics.
- `getSwipeSpeed` `fast: 2000` is informational (fast is the catch-all rung).
- `mapToggleValue`/etc no-op on a null element (V usually non-null; documented).
- `bin_packing` over-capacity item, `quantile_summary` nearest-rank median, `interleave` /
  `list_nullable_string_sort` doc wording, `pipe` uniform-type typing — minor, documented.

## Notes / optional follow-ups (no action taken)
- Local untracked clutter (`custom_lint.log` 6 MB, `lint_report.log`, `nul`, `*.bak`) — gitignored,
  does not ship; optional local cleanup only.
- `CAPABILITIES.md` is auto-generated (`tool/gen_capabilities.dart`) — regenerate to pick up the new
  `debounceCancelable`/`throttleCancelable`/`CancelableCallback` API before release.
- Test coverage is broad via **aggregated** test files; pure-data files (entity tables, enums) need
  no direct test. No genuine coverage hole found among audited logic.

## Verification
- `dart analyze`: clean. Full `flutter test`: green (synthesis gate). Every fix has a regression test.
- Backward compatibility: all signatures preserved; the only additions are the two cancelable
  functions + `CancelableCallback`. `stableHash` VM output is unchanged (web now matches it).

## Final certification (2026-06-13)
- `flutter test` (full suite): **8222 passed, 2 skipped, 0 failed** (real exit code 0).
- `dart analyze`: clean.
- All ~33 fixes ship with regression tests; signatures preserved; `stableHash` VM output unchanged.
- Review status: COMPLETE.
