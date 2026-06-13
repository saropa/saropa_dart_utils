/// Dependency resolver with version constraints — roadmap #540.
///
/// Given a universe of available package versions (each with its own dependency
/// constraints) and a set of root requirements, pick one concrete version per
/// package that satisfies every accumulated constraint, then return a
/// topological install order (dependencies before dependents). Reuses the
/// existing `compareVersions` for version ordering and `topologicalSort` for the
/// install order + cycle detection.
///
/// Resolution is greedy highest-version over a fixpoint worklist: constraints
/// accumulate monotonically and each package's chosen version only ever moves
/// DOWN its candidate list as more constraints arrive, so it terminates. It does
/// NOT backtrack — a constraint contributed by a later-superseded version is not
/// retracted — so a pathological diamond can over-constrain. This matches simple
/// lock-file resolution, not a full SAT solver.
library;

import 'package:collection/collection.dart';
import 'package:saropa_dart_utils/graph/topological_sort_utils.dart';
import 'package:saropa_dart_utils/parsing/version_compare_utils.dart';
import 'package:saropa_dart_utils/parsing/version_parse_utils.dart';

/// One available package version and the constraints it places on its own
/// dependencies (`depName → constraint string`, e.g. `'^1.2.0'`).
class PackageManifest {
  /// Creates a manifest for [name] at [version] depending on [dependencies].
  /// Audited: 2026-06-12 11:26 EDT
  const PackageManifest(
    this.name,
    this.version, {
    this.dependencies = const <String, String>{},
  });

  /// The package name.
  final String name;

  /// This package's version (dotted/semver string).
  final String version;

  /// Constraints this version imposes: dependency name → constraint string.
  final Map<String, String> dependencies;
}

/// The outcome of a successful resolution: the chosen [versions] per package and
/// an [installOrder] with dependencies ahead of the packages that need them.
class DependencyResolution {
  /// Creates a resolution result.
  /// Audited: 2026-06-12 11:26 EDT
  const DependencyResolution(this.versions, this.installOrder);

  /// Resolved package name → chosen version.
  final Map<String, String> versions;

  /// Package names ordered so every dependency precedes its dependents.
  final List<String> installOrder;
}

/// Thrown when resolution cannot complete: an unknown package, no version
/// satisfying the constraints, or a dependency cycle.
class DependencyResolutionException implements Exception {
  /// Creates an exception describing why resolution failed.
  /// Audited: 2026-06-12 11:26 EDT
  const DependencyResolutionException(this.message);

  /// Human-readable failure reason.
  final String message;

  @override
  String toString() => 'DependencyResolutionException: $message';
}

/// Resolves [root] (`depName → constraint`) against [universe] (every available
/// package version), returning the chosen versions and a topological install
/// order. Throws [DependencyResolutionException] on an unknown package, an
/// unsatisfiable constraint set, or a cycle.
/// Audited: 2026-06-12 11:26 EDT
DependencyResolution resolveDependencies({
  required Map<String, String> root,
  required List<PackageManifest> universe,
}) {
  final Map<String, List<PackageManifest>> byName = <String, List<PackageManifest>>{};
  for (final PackageManifest m in universe) {
    byName.putIfAbsent(m.name, () => <PackageManifest>[]).add(m);
  }
  final Map<String, List<String>> constraints = <String, List<String>>{};
  final Map<String, String> chosen = <String, String>{};
  final List<String> queue = <String>[];
  root.forEach((String dep, String constraint) {
    constraints.putIfAbsent(dep, () => <String>[]).add(constraint);
    queue.add(dep);
  });
  while (queue.isNotEmpty) {
    _resolveOne(queue.removeAt(0), byName, constraints, chosen, queue);
  }
  return DependencyResolution(chosen, _installOrder(chosen, byName));
}

/// Resolves one package off the worklist: picks the highest version satisfying
/// all of its accumulated constraints and, when that choice changes, enqueues
/// its dependencies so their constraints propagate.
/// Audited: 2026-06-12 11:26 EDT
void _resolveOne(
  String name,
  Map<String, List<PackageManifest>> byName,
  Map<String, List<String>> constraints,
  Map<String, String> chosen,
  List<String> queue,
) {
  final List<PackageManifest>? versions = byName[name];
  if (versions == null) {
    throw DependencyResolutionException('no package "$name" in the universe');
  }
  final List<String> active = constraints[name] ?? const <String>[];
  final PackageManifest? best = _highestSatisfying(versions, active);
  if (best == null) {
    throw DependencyResolutionException('no version of "$name" satisfies ${active.join(', ')}');
  }
  // A stable choice means nothing new to propagate; avoid re-enqueuing forever.
  if (chosen[name] == best.version) {
    return;
  }
  chosen[name] = best.version;
  best.dependencies.forEach((String dep, String constraint) {
    constraints.putIfAbsent(dep, () => <String>[]).add(constraint);
    queue.add(dep);
  });
}

/// The highest [PackageManifest] in [versions] whose version satisfies every
/// constraint in [active], or null if none qualifies.
/// Audited: 2026-06-12 11:26 EDT
PackageManifest? _highestSatisfying(List<PackageManifest> versions, List<String> active) {
  PackageManifest? best;
  for (final PackageManifest m in versions) {
    if (!active.every((String c) => _satisfies(m.version, c))) {
      continue;
    }
    if (best == null || compareVersions(m.version, best.version) > 0) {
      best = m;
    }
  }
  return best;
}

/// Builds the dependency graph over the [chosen] packages and topologically
/// sorts it (dependencies first), throwing on a cycle.
/// Audited: 2026-06-12 11:26 EDT
List<String> _installOrder(Map<String, String> chosen, Map<String, List<PackageManifest>> byName) {
  final List<String> names = chosen.keys.toList();
  final Map<String, int> index = <String, int>{
    for (int i = 0; i < names.length; i++) names[i]: i,
  };
  final List<List<int>> adjacency = List<List<int>>.generate(names.length, (_) => <int>[]);
  for (int nameIndex = 0; nameIndex < names.length; nameIndex++) {
    final String name = names[nameIndex];
    final PackageManifest? manifest = byName[name]?.firstWhereOrNull(
      (PackageManifest m) => m.version == chosen[name],
    );
    // Edge dependency → dependent, so Kahn emits the dependency first. Only
    // edges between resolved packages matter; a dep outside `chosen` is skipped.
    for (final String dep in manifest?.dependencies.keys ?? const <String>[]) {
      final int? depIndex = index[dep];
      if (depIndex != null) {
        adjacency[depIndex].add(nameIndex);
      }
    }
  }
  final List<int>? sorted = topologicalSort(adjacency);
  if (sorted == null) {
    throw const DependencyResolutionException('dependency cycle detected');
  }
  return sorted.map((int i) => names[i]).toList();
}

/// Whether [version] satisfies one [constraint]. Supports `*`/`any`/empty (all),
/// caret (`^1.2.0`), the comparison operators `>= <= > < == =`, a bare exact
/// version, and space-separated compound constraints (logical AND).
/// Audited: 2026-06-12 11:26 EDT
bool _satisfies(String version, String constraint) {
  final String c = constraint.trim();
  if (c.isEmpty || c == '*' || c == 'any') {
    return true;
  }
  if (c.contains(' ')) {
    return c.split(RegExp(r'\s+')).every((String part) => _satisfies(version, part));
  }
  if (c.startsWith('^')) {
    return _satisfiesCaret(version, c.substring(1));
  }
  for (final String op in const <String>['>=', '<=', '>', '<', '==', '=']) {
    if (c.startsWith(op)) {
      return _matchesOperator(op, compareVersions(version, c.substring(op.length).trim()));
    }
  }
  return compareVersions(version, c) == 0;
}

/// Maps a comparison [op] and the sign of `compareVersions` ([cmp]) to a result.
/// Audited: 2026-06-12 11:26 EDT
bool _matchesOperator(String op, int cmp) {
  switch (op) {
    case '>=':
      return cmp >= 0;
    case '<=':
      return cmp <= 0;
    case '>':
      return cmp > 0;
    case '<':
      return cmp < 0;
    default:
      return cmp == 0; // '==' and '='
  }
}

/// Caret semantics: `>= base` and below the next version that changes the
/// left-most non-zero component (`^1.2.3` → `<2.0.0`, `^0.2.3` → `<0.3.0`,
/// `^0.0.3` → `<0.0.4`).
/// Audited: 2026-06-12 11:26 EDT
bool _satisfiesCaret(String version, String base) {
  final (int, int, int)? parsed = parseVersion(base);
  if (parsed == null || compareVersions(version, base) < 0) {
    return false;
  }
  final (int major, int minor, int patch) = parsed;
  // The caret upper bound is the next version that changes the left-most
  // non-zero component. Spelled out as a chained conditional rather than a
  // nested ternary, which the project style rules disallow.
  final String upper;
  if (major > 0) {
    upper = '${major + 1}.0.0';
  } else if (minor > 0) {
    upper = '0.${minor + 1}.0';
  } else {
    upper = '0.0.${patch + 1}';
  }
  return compareVersions(version, upper) < 0;
}
