# Progress — Full Codebase Review

Legend: ⬜ not started · 🟦 in progress · ✅ done

## Phase 0 — Baseline
- ⬜ analyze clean + test suite green (record counts)
- ⬜ dependency freshness review

## Phase 1 — Cross-cutting sweeps
- ✅ 1a web/JS 64-bit int model — 4 findings (#2 HLL, #3 stable_hash, #6 varint, + hex caveat); rolling_hash/bloom/checksum/simpleHash cleared
- ✅ 1b release-stripped asserts (40 / 22 files) — finding #7 FIXED in 18 files (commit 10d7ce8); 3 const ctors + 2 graceful fns kept by design
- ✅ 1c randomness & security (9 files) — 2 findings (#1 safe_temp_name S2, #5 map_extensions S4); 7 cleared
- ✅ 1d DateTime.now() race/testability (23 files) — clean; injectable-now pattern, single capture per call
- ⬜ 1e Unicode grapheme/rune/code-unit
- ⬜ 1f numeric edge cases
- ⬜ 1g inclusive/exclusive boundaries
- 🟦 1h unsafe collection access — quantified (~30 .first/.last/.single + 54 [0]); most provably safe, needs per-site triage during Phase 2 deep read (not a blanket fix)

## Phase 2 — Per-category deep read
- ⬜ 2.1 collections (64)
- ⬜ 2.2 graph (21)
- ⬜ 2.3 stats (22)
- ⬜ 2.4 string (78)
- ⬜ 2.5 datetime (57)
- ⬜ 2.6 parsing (37)
- ⬜ 2.7 async (34)
- ⬜ 2.8 num/int/double (31)
- ⬜ 2.9 iterable/list/map (52)
- ⬜ 2.10 validation (13)
- ⬜ 2.11 url (11)
- ⬜ 2.12 remaining singletons & small dirs

## Phase 3 — Docs/metadata
- ⬜ barrel exports · indexes · README · CHANGELOG · audit stamps · example/ · stale artifacts

## Phase 4 — Test quality
- ⬜ coverage gaps · weak/flaky assertions · hard-limit violations

## Phase 5 — Synthesis
- ⬜ severity-ranked bug list · fixes + regression tests · atomic commits
