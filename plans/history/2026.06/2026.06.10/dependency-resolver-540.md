# Dependency resolver with version constraints (roadmap #540)

Item 10 (final) of the "next 10" roadmap-utilities batch. Resolves package version constraints to a concrete version per package plus a topological install order — the install/build-ordering problem, built on the existing semver compare and topological sort.

## Finish Report (2026-06-10)

**Scope:** (A) Dart library. New `lib/collections/dependency_resolver_utils.dart` (`resolveDependencies`, `PackageManifest`, `DependencyResolution`, `DependencyResolutionException`), new test, barrel export, CHANGELOG entry.

**Design:** `resolveDependencies(root, universe)` indexes the universe by name, then runs a fixpoint worklist (`_resolveOne`): for each package it picks the highest version satisfying ALL accumulated constraints; when that choice changes it enqueues that version's dependencies so their constraints propagate. Termination holds because constraints accumulate monotonically and a package's chosen version can only move DOWN its finite candidate list. After resolution, `_installOrder` builds the dependency graph over chosen packages and runs `topologicalSort` (dependency → dependent edges, so Kahn emits dependencies first); a null result signals a cycle.

**Reuse:** `compareVersions` (version ordering, highest-satisfying selection), `parseVersion` (caret upper-bound math), `topologicalSort` (install order + cycle detection), `firstWhereOrNull` (locating the chosen manifest). No new version/graph machinery.

**Constraint grammar:** `*`/`any`/empty (all), caret with correct 0.x semantics (`^1.2.3`→`<2.0.0`, `^0.2.3`→`<0.3.0`, `^0.0.3`→`<0.0.4`), `>= <= > < == =`, bare exact, and space-separated AND compounds.

**Honest scope:** greedy, no backtracking — a constraint from a later-superseded version is not retracted, so a pathological diamond can over-constrain. Documented in the library header as simple-lock-file resolution, not a SAT solver. This is the standard trade-off for a small resolver and is stated, not hidden.

**Tests:** 11 cases — simple chain with ordering, highest-version selection, diamond constraint intersection (>=1.0.0 ∧ <1.5.0 → 1.4.0), transitive chain ordering (c→b→a), unsatisfiable conflict throws, missing package throws, cycle throws, and constraint matching for compound operators, 0.x caret, exact bare version, and `*`. All pass; `flutter analyze` clean.

**Reviewer notes:** `_installOrder` iterates by index and null-checks `index[dep]` instead of using `!`, satisfying the avoid-null-assertion / nullable-safe-accessor rule. The fixpoint's "stable choice → return" guard prevents infinite re-enqueue. Functions ≤20 lines (the two resolver helpers take 5/6 params by necessity — they thread the shared mutable resolution state).

No bug archive — task did not close a bugs/*.md file.
