# Deferred: R6 — pubspec version-upgrade nudge for `saropa_dart_utils`

**Status: Deferred — filed, owned by `saropa_lints`.**
**Origin:** [SAROPA_SUITE_INTEGRATION.md](../SAROPA_SUITE_INTEGRATION.md), requirement R6.
**Deferred 2026-06-14.**

## Why deferred (not built here)

When a project depends on an out-of-date `saropa_dart_utils`, it should see a single,
gated "a newer `saropa_dart_utils` is available — bump it" nudge. This package has no
VS Code extension and no `pubspec.yaml` scanner, so the nudge cannot live here. The
work belongs in `saropa_lints`, which owns the extension and the Package Vibrancy
subsystem that already scans `pubspec.yaml` and compares against the latest release.

There is therefore **nothing to build in this repo**. The requirement is a feature
request against a sibling, and is tracked as such.

## What was filed

`saropa_lints` feature request:
`D:\src\saropa_lints\bugs\feature_package_vibrancy_saropa_dart_utils_version_nudge.md`

It asks Package Vibrancy to track `saropa_dart_utils` as a watched package and raise a
once-gated bump nudge when the pinned version is behind latest — the dependency-version
mirror of the suite-discovery install nudge the extensions already ship (Lints R7). Gate
on the existing offered/dismissed pattern so it never nags.

## Grounding verified while filing

Package Vibrancy is a real subsystem (`extension/src/vibrancy/`) with a "behind latest"
comparator (`providers/sdk-diagnostics.ts`, currently SDK/Flutter-scoped) and a curated
package registry (`data/known_issues.json`, end-of-life-oriented). `saropa_dart_utils`
is in neither yet, so the ask is "apply the existing version-gap nudge to the suite's
own packages," gated once. The maintainer's open call: generalize the "behind latest"
comparator to a named pub dependency, rather than overload the end-of-life registry with
a healthy-but-stale package.

## Closes when

The nudge ships in `saropa_lints` (its changelog records the new watched package). At
that point this doc moves to `plans/history/<yyyy.mm>/<yyyy.mm.dd>/`. Until then there is
no action in `saropa_dart_utils`.
