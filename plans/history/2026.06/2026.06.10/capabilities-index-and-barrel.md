# Team-facing capabilities index, barrel completeness, and publish auto-gen

`CAPABILITIES.md` did not cover every method and the barrel was missing exports. Goal: give external teams one discoverable, complete, always-current catalog of every utility, make every util reachable through the single advertised import, and auto-generate the index at publish time (no gate).

## Finish Report (2026-06-10)

### Scope

- **(A)** Dart library: `lib/saropa_dart_utils.dart` (barrel) gained 16 exports; `test/barrel_exports_test.dart` added.
- **(C)** Docs/scripts: `CAPABILITIES.md` (new, generated), `tool/gen_capabilities.py` (new generator), `scripts/publish.py` + `scripts/modules/{version_changelog,constants}.py` (auto-gen wiring, bundled with a pre-existing v2.8 release-intro feature), `README.md`, `CHANGELOG.md`, `ROADMAP_TO_400.md` (archived).

### What shipped (commits)

- `dcb649f` — `CAPABILITIES.md` per-symbol index + `tool/gen_capabilities.py`; archived completed `ROADMAP_TO_400.md` to `plans/history/2026.06/2026.06.10/` (400/400).
- `47c52e1` — exported 16 file-only utilities from the barrel; added `test/barrel_exports_test.dart`.
- `17209d7` — extended the generator to also capture fields, enum values, and setters (index now 1,391 symbols / 352 files).
- `b404431` — wired `tool/gen_capabilities.py` into `publish.py` as step 4 (auto-regenerate, non-fatal, staged by the release commit); bundled and completed the uncommitted v2.8 release-intro feature so `publish.py`'s `vc.has_release_intro`/`vc.update_log_link` references resolve.

### Deep review notes

- **Barrel completeness:** the 16 unexported files were genuine public utilities; the names that *looked* like collisions were not (`groupByTransform`/`sortByThenBy`, not `groupBy`/`sortBy`). `html/html_entity_data.dart` was deliberately left unexported — it is an internal const data table, not a util.
- **Index correctness:** the generator keys off the project invariant that every public member is documented. Verified that invariant holds — `public_member_api_docs` enabled repo-wide reports **zero** undocumented public members — so "documented declaration" == "public API" with no misses. Initial version captured only callables; extended to fields/enum-values/setters after confirming `CronSchedule.minutes` (a field) was missing.
- **Publish wiring safety:** regeneration runs after the working-tree check (tree already clean) and before the commit, so it never trips the clean-tree gate; `git add -A` in the release commit stages it. Made non-fatal so a docs-index hiccup cannot block a release.
- **Entanglement handled:** staging `publish.py` swept in another workstream's uncommitted v2.8 edits; the first commit referenced helpers still uncommitted in `version_changelog.py` (a broken intermediate). Amended the (unpushed) commit to include `version_changelog.py` + `constants.py` and rewrote the message to describe both bundled changes.

### Testing

- **Audit:** no existing test pinned the barrel's export list; the change is purely additive. Confirmed by the full-suite run below.
- **New:** `test/barrel_exports_test.dart` imports ONLY the barrel and exercises one symbol from each newly-exported file — it would fail to compile on any top-level or extension-method ambiguity. It passes.
- **Commands & results:**
  - `dart analyze lib test` → **No issues found.**
  - `flutter test test/barrel_exports_test.dart` → **4 passed.**
  - `flutter test` (full) → **5986 passed** (~2 pre-existing skips).
  - `python -m py_compile scripts/publish.py scripts/modules/version_changelog.py scripts/modules/constants.py` → OK.

### l10n

SKIPPED [A-NOT-IN-SCOPE] — pure Dart utility library; no Flutter UI, no user-facing strings, no ARB.

### Maintenance

CHANGELOG updated (Added: CAPABILITIES.md; Fixed: barrel exports; Changed: publish auto-gen + roadmap archive). README updated (quality banner + `CAPABILITIES.md` pointer in "What's Included"). `ROADMAP_TO_400.md` archived to history at 400/400; `ROADMAP_TO_700.md` remains active. No `docs/launch/LAUNCH_TEST.md` in this repo (library, not the Contacts app) — N/A. No bug archive — task did not close a `bugs/*.md` file.

### Finish report saved

`plans/history/2026.06/2026.06.10/capabilities-index-and-barrel.md` (this file).

### Outstanding / not mine

`analysis_options.yaml`, `pubspec.yaml` (saropa_lints 13.10.3→13.12.3 bump), `CHANGELOG_HISTORY.md`, and `ROADMAP_TO_700.md` remain uncommitted — a separate workstream, intentionally left untouched.
