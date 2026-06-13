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

- **R2 — Dart-side envelope model (proposed, conditional).** *If* any Saropa **Dart** code needs to
  emit the envelope — e.g. Drift Advisor's in-app runtime component that backs `GET /api/issues`, or
  a future self-diagnostic an app ships — the canonical Dart serialization (a record/class
  conforming to Drift Advisor Section 2.1/2.2, with `fromJson`/`toJson` and `schemaVersion`
  handling) belongs here as one shared type rather than re-implemented per app. **Gated:** this is
  only worth building once a concrete Dart producer exists. The three diagnostic tools are TypeScript
  VS Code extensions; whether Advisor's `/api/issues` payload is assembled in Dart or TS decides
  whether R2 is real. Confirm before building — do not speculatively add an envelope model with no
  consumer (that would violate this repo's "no premature abstraction" / "minimal viable shape" bars).

---

## Dart Utils requirements (what this package builds)

- **R1 — Rule-to-remediation mapping** (above). Colocated with a test that asserts every mapped
  symbol resolves to a real export, so a rename in `lib/` or an upstream rule rename breaks the build
  rather than shipping a dead suggestion.
- **R2 — Dart envelope model** (above) — **only when a Dart producer is confirmed.**
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

There is deliberately **no** producer/consumer/deep-link/commit-stamp requirement here — those are
IDE-extension concerns this package has no surface for. Inventing them would be the padding the
honest-framing note above rejects.

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

1. **R1 — rule-to-remediation mapping + pinning test.** Pure data, zero runtime risk, immediately
   useful to Lints R3. Do first.
2. **R3 — remediation coverage audit.** Turns the suite's crash enumeration into a library backlog;
   feeds ROADMAP.
3. **R4 — keep the dogfooding gate green** (ongoing; unblock via the pending `saropa_lints` bump).
4. **R2 — Dart envelope model** — only after a concrete Dart producer is confirmed. May never be
   needed.
5. **Shared infra — adopt `saropa-release-tools`** once it is extracted (Python; consumer only).

---

## Open questions to settle before building

1. **Is there a Dart-side envelope producer?** Decides whether R2 is ever real. Owner: Drift Advisor
   (does its `/api/issues` runtime component assemble the payload in Dart or in TypeScript?).
2. **Who owns the rule ↔ symbol mapping master copy** — this repo (keyed by util symbol) or Lints
   (keyed by rule id)? Proposal: Lints owns rule → crash-signature; this repo owns rule → util-symbol;
   the two are joined on `ruleId`. Confirm with the Lints doc's R3 owner.

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
