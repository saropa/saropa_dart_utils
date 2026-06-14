# Saropa Suite Integration — Dart Utils side

**Created:** 2026-06-13
**Question answered:** How does `saropa_dart_utils` fit a suite whose other three members diagnose a
running Flutter app — when this package is a pure Dart library that never observes the app at all.

This is the **Saropa Dart Utils** half-step of a four-repo plan. The three diagnostic siblings:

- **Drift Advisor** — `D:\src\saropa_drift_advisor\plans\67-saropa-suite-integration.md`
  (repo `saropa/saropa_drift_advisor`). **Owns the canonical shared protocol** (the Saropa Diagnostic
  Envelope); this doc references it rather than restating the schema.
- **Saropa Lints** — `D:\src\saropa_lints\plans\SAROPA_SUITE_INTEGRATION.md`
  (repo `saropa/saropa_lints`).
- **Log Capture** — `D:\src\saropa-log-capture\plans\105_plan-saropa-suite-integration.md`
  (repo `saropa/saropa-log-capture`).

> **Honest framing first.** The other three are a triad of *lenses* on one app — static code, live
> DB, runtime behavior. `saropa_dart_utils` is **not a fourth lens**: it has no VS Code extension, no
> analyzer plugin, no debug server, and it inspects nothing. It is the **library the diagnoses point
> back at** — the dependency that ships the safe primitives the suite's quick fixes recommend. Its
> role is *remediation*, not *observation*. This doc deliberately does not pretend otherwise; padding
> it into a fake producer/consumer would misrepresent the package.

---

## The thesis: three lenses diagnose, one library remediates

| Tool | Role | Sees | Emits / ships |
|------|------|------|---------------|
| `saropa_lints` | diagnose (static) | code (AST) | findings |
| `saropa_drift_advisor` | diagnose (runtime data) | live DB + schema | issues |
| `saropa-log-capture` | diagnose (behavior) | logs, crashes | signals |
| `saropa_dart_utils` (this) | **remediate** | nothing — it is a dependency | safe primitives + tests |

The triad's flagship feedback loop (Drift Advisor doc, Section 5; Lints R3) ends at a recommendation:
*"this crash class is covered by rule X — enable it."* But enabling a rule only flags the next
occurrence; the developer still has to write the fix. `saropa_dart_utils` is where that fix already
lives. The crash families Log Capture parses and Lints attributes to rules — `.first`/`.single` on an
empty collection (`StateError`), `[index]` out of range (`RangeError`), unguarded parse, path
traversal — are exactly the classes this package's helpers exist to remove: the safe-accessor and
validation extensions across `lib/iterable`, `lib/list`, `lib/collections`, `lib/parsing`,
`lib/validation`, `lib/url`. So the loop has a fourth leg the triad cannot supply on its own: *rule →
the library symbol that fixes it.*

This package is also the suite's **dogfooding proving ground**: it dev-depends on `saropa_lints`
(`13.12.7`, [pubspec.yaml](../pubspec.yaml); see also
[PENDING_saropa_lints_bump.md](PENDING_saropa_lints_bump.md)) and runs the rules over its own source.
Every crash class the suite claims to prevent should have a safe helper here with a passing
edge-case test — emptiness, Unicode, extreme numbers, the cases `.claude/rules/testing.md` mandates.

---

## Shared protocol (canonical: Drift Advisor doc, Section 2)

`saropa_dart_utils` does **not** redefine the Saropa Diagnostic Envelope. It does not currently
produce or consume it — it has no diagnostics to emit and no IDE surface to render them in. Two ways
it can touch the protocol, in priority order:

- **R1 — Rule-to-remediation mapping (certain, owned here).** Ship a data table mapping a Lints
  `ruleId` ↔ the `saropa_dart_utils` symbol that remediates it (e.g. `geocoding_unchecked_first` ↔
  `IterableExtensions.firstOrNull`; an unchecked `[index]` rule ↔ `elementAtOrNull`; an unguarded
  parse rule ↔ the `lib/parsing` `tryParse*` helpers). This is the data that lets a sibling's
  `fix` upgrade from *"enable rule X"* to *"enable rule X and use `Y` from `saropa_dart_utils`."* The
  table is pinned by tests so it cannot drift from the real public API. It pairs with Lints R3 (the
  crash-signature ↔ rule table) to complete crash → rule → fix.

- **R2 — Dart-side envelope model (CLOSED — not needed; no Dart producer exists).** *Resolved
  2026-06-14 from the sibling changelogs.* Every producer and consumer of the Saropa Diagnostic
  Envelope is a TypeScript VS Code extension reading/writing JSON files on disk: Saropa Lints' changelog
  states *"the extension writes its current findings to `.saropa/diagnostics/lints.json` (the Saropa
  Diagnostic Envelope)"*; Drift Advisor's envelope/API types live in `extension/src/api-types.ts` (TS)
  and it reads "the sibling tools' diagnostics files"; Log Capture reads
  `.saropa/diagnostics/advisor.json` / `lints.json`. **No Dart code emits or consumes the envelope.**
  The gate the original requirement set — "only worth building once a concrete Dart producer exists" —
  is therefore answered NO. R2 is dropped from active scope; building a Dart envelope model now would be
  exactly the premature, consumer-less abstraction this repo's bars forbid. Re-open only if a Saropa
  **Dart** producer is ever introduced.

---

## Dart Utils requirements (what this package builds)

- **R1 — Rule-to-remediation mapping** (above) — **BUILT 2026-06-14.** Shipped as `kRuleRemediations`
  in [lib/suite/rule_remediation_map.dart](../lib/suite/rule_remediation_map.dart) (exported from the
  package barrel), with the pinning test at
  [test/suite/rule_remediation_map_test.dart](../test/suite/rule_remediation_map_test.dart). Each row
  joins a `saropa_lints` crash rule id to the owned safe primitive that removes the failure
  (`avoid_unsafe_reduce`→`sumBy`, `avoid_unsafe_where_methods`/`prefer_where_or_null`/`geocoding_unchecked_first`→`firstWhereOrElse`,
  `avoid_unsafe_collection_methods`→`singleOrNull`, `image_picker_multi_result_unchecked_empty`→`nullIfEmpty`,
  `require_null_safe_extensions`→`whereNotNull`, `prefer_try_parse_for_dynamic_data`→`toIntNullable`,
  `avoid_path_traversal`→`isPathSafe`). The test exercises every mapped symbol in compiled code, so a
  rename in `lib/` breaks the build; it also fails on two-way drift (mapped symbol with no probe, or
  probe for an unmapped symbol). Kept crash-focused: only rules whose remediation is a primitive this
  package owns appear — symbols like `firstOrNull`/`elementAtOrNull` are `package:collection`'s, not
  this library's, so they are deliberately not mapped here.
- **R2 — Dart envelope model** (above) — **CLOSED, not needed.** No Dart producer exists (Question 1,
  resolved 2026-06-14); do not build.
- **R3 — Remediation coverage audit.** For each crash family the suite enumerates (Lints R3's
  mapping table, Log Capture's parsed crash classes), assert a corresponding safe helper exists here
  with an edge-case test. A family with no helper is a **library backlog input** — the mirror of
  Lints' "observed in production, no static rule yet." Surface it in `CODE_INDEX.md` /
  [ROADMAP_TO_700.md](ROADMAP_TO_700.md) as "crash class observed by the suite, no safe primitive
  yet."
- **R4 — Dogfooding gate stays green.** Keep `dart run custom_lint` clean under the dev-dependency on
  `saropa_lints` so this package remains a credible reference implementation of the rules the suite
  ships. The pending `saropa_lints` bump ([PENDING_saropa_lints_bump.md](PENDING_saropa_lints_bump.md))
  is part of keeping that current.

- **R5 — Migration / "prefer `saropa_dart_utils`" detection.** The inverse of R1: where R1 maps a
  crash rule → the safe helper, R5 detects code in a *consumer* project that hand-rolls something this
  library already ships, and recommends the library symbol.
  **Delivery (what actually exists, 2026-06-13):** this lives in **`tool/suggest_saropa_utils.dart`**
  — a regex scanner (core logic in `tool/suggest_saropa_utils_lib.dart`, unit-tested) that walks a
  project's source and emits `Consider: <util> from <source>` suggestions. It was rebuilt this date to
  23 detectors, each audited against the real `lib/` API for a target that exists and is
  flow-analysis-safe. **It is a CLI tool, not an in-editor experience** — it does not surface as
  IDE quick fixes today.
  **Possible future enhancement (NOT built):** porting these patterns to a type-aware
  `saropa_dart_utils` rule pack inside `saropa_lints` (mirroring its per-library packs, gated on the
  resolved dependency via `kRulePackDependencyGates`) would give in-editor diagnostics + quick fixes
  without forcing a second lint toolchain on consumers. That is the natural next step if the CLI tool
  proves its value; it is not the current home.

  **Hard guardrail (learned 2026-06-13) — a migration suggestion must never recommend a util that
  defeats Dart flow analysis.** `String?.isNullOrEmpty` / `isNotNullOrEmpty` (and the equivalent
  `num?.isNullOrZero`) are the canonical anti-example: `if (s == null || s.isEmpty)` promotes `s` to
  non-null in the guarded scope, but `if (s.isNullOrEmpty)` does not — the analyzer cannot see the
  opaque getter implies `s != null`, so downstream code loses promotion and is pushed toward `!`. That
  whole `isNullOrX`-getter family is **excluded** as a suggestion target; the scanner instead carries a
  reverse detector that flags *use* of those getters. `isNullOrEmpty` itself is now `@Deprecated` in
  `lib/` (see [[isnullorempty-kills-null-promotion]]). The earlier rebuild also removed detectors that
  named utils which do not exist at all (`orZero`, `orNow`, `toIntOr`, `notNullOrEmpty`) — they
  suggested non-compiling code. Every detector must be vetted against the real API *and* the promotion
  test before it ships.

- **R6 — Pubspec version-upgrade nudge.** When a project depends on an out-of-date `saropa_dart_utils`,
  prompt to bump it. **Delivery:** rides `saropa_lints`' existing **Package Vibrancy** ("version-gap
  PR triage" / dependency-health scanning) — no new code path and no new extension. This is the
  mirror of the suite-discovery nudge the Lints doc already specifies (its R7). Gate once with the
  existing offered/dismissed pattern so it never nags.

The only NEW artifact either requirement creates is Dart rule code + a dependency-gate entry inside
`saropa_lints`; everything user-facing reuses the Saropa Lints extension that already exists. There is
deliberately **no** producer/consumer/deep-link/commit-stamp requirement and **no dedicated VS Code
extension** for this library — those would be padding the honest-framing note above rejects.

---

## The Drift Health loop (this package's part)

Defined in full in the Drift Advisor doc, Section 5; the static leg in the Lints doc. `saropa_dart_utils`
is not *in* the loop (it observes nothing), but it is the loop's **terminal**: when Lints' leg 3
confirms a static Drift rule covers the observed slow query or bad write, the remediation that rule's
quick fix steers toward — a guarded write, a bounded read, a safe accessor — is library code this
package can own where it generalizes beyond a single app. Where the safe pattern is Drift-specific it
stays in the rule's quick fix; where it is a general Dart primitive (collection/parse/validation
safety) it belongs here and is referenced by R1's mapping.

---

## Shared infrastructure (cross-repo)

The three TypeScript extensions extract `saropa-vscode-i18n`, `saropa-vscode-ui`, and
`saropa-release-tools` (see the identical Section 7 in the Drift Advisor doc and the matching section
in the Lints and Log Capture docs). `saropa_dart_utils`'s participation is **partial and honest**:

- **`saropa-vscode-i18n`** — **N/A.** Pure Dart library, no VS Code i18n, no NLLB pipeline. Does not
  participate.
- **`saropa-vscode-ui`** — **N/A.** No webview, no dashboard. Does not participate.
- **`saropa-release-tools`** (Python, language-agnostic) — **participates as a consumer.** The
  changelog conventions, the write-time American-English gate, and the publish guard apply to a Dart
  pub package as much as to the three extensions. This package's release flow should adopt the shared
  Python tooling rather than keep a parallel one. (It already shares the constraint that bit the
  others — `dart pub publish --dry-run` fails locally on this Windows machine; packaging is verified
  in CI, not locally.)

So the shared-infra story for this repo is one-of-three, not three-of-three. Recording the two N/As
explicitly keeps the cross-repo Section honest from this entry point instead of implying alignment
that does not exist.

---

## Phasing

1. **R5 — migration / "prefer" rule pack in `saropa_lints`.** Blocked on selecting a user-vetted,
   flow-analysis-safe target (the `isNullOrEmpty` family is disqualified — see R5's guardrail). Once a
   target is approved, build it type-aware end-to-end — detection + quick fix + dependency gate + test
   — to prove the pack pattern; remaining inline-shape rules are added against the same scaffold.
2. **R1 — rule-to-remediation mapping + pinning test. DONE 2026-06-14.** Pure data, zero runtime risk,
   immediately useful to Lints R3. `kRuleRemediations` in `lib/suite/rule_remediation_map.dart` +
   pinning test in `test/suite/rule_remediation_map_test.dart` (analyze clean, 4/4 tests pass).
3. **R6 — pubspec version-upgrade nudge** via Package Vibrancy (no new code path).
4. **R3 — remediation coverage audit.** Turns the suite's crash enumeration into a library backlog;
   feeds ROADMAP.
5. **R4 — keep the dogfooding gate green** (ongoing; unblock via the pending `saropa_lints` bump).
6. **R2 — Dart envelope model** — **CLOSED 2026-06-14, not needed.** The envelope is produced and
   consumed entirely by the TypeScript extensions; no Dart producer exists. Re-open only if one is
   introduced.
7. **Shared infra — adopt `saropa-release-tools`** once it is extracted (Python; consumer only).

---

## Open questions — both RESOLVED 2026-06-14 (from the sibling changelogs)

1. **Is there a Dart-side envelope producer? → NO. Settled.** Every producer and consumer of the
   Saropa Diagnostic Envelope is a TypeScript VS Code extension: Saropa Lints' extension *writes*
   `.saropa/diagnostics/lints.json` (the envelope); Drift Advisor's envelope/API types are in
   `extension/src/api-types.ts` and it reads the sibling diagnostics files; Log Capture reads
   `advisor.json` / `lints.json`. No Dart code touches the envelope. → **R2 is dropped from scope.**
2. **Who owns the rule ↔ symbol mapping master copy? → Proposal confirmed.** The siblings built the
   crash → rule half exactly as proposed (Log Capture emits stable crash-family signatures so Saropa
   Lints can map them to the rule that would have prevented them); neither built a rule → util-symbol
   table. So: Lints owns rule → crash-signature, **this repo owns rule → util-symbol**, joined on
   `ruleId`. → **R1 is unblocked.**

---

## Related plans

- Sibling (canonical protocol + Drift Health loop): `saropa_drift_advisor` —
  `D:\src\saropa_drift_advisor\plans\67-saropa-suite-integration.md`
- Sibling: `saropa_lints` — `D:\src\saropa_lints\plans\SAROPA_SUITE_INTEGRATION.md`
  (R3 crash-to-rule attribution is this doc's direct counterpart)
- Sibling: `saropa-log-capture` — `D:\src\saropa-log-capture\plans\105_plan-saropa-suite-integration.md`
- Internal: [PENDING_saropa_lints_bump.md](PENDING_saropa_lints_bump.md) (keeps the dogfooding gate
  current), [ROADMAP_TO_700.md](ROADMAP_TO_700.md) (where R3's backlog inputs land),
  `CODE_INDEX.md` (the capability index the rule-to-remediation mapping is checked against).
