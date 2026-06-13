/// Hierarchy flattener and builder from flat list with parent ids — roadmap #556, #557.
library;

/// Node with id and optional parentId for tree building.
class HierarchyUtils {
  /// Creates a node with the given [id] and optional [parentId] (null for a
  /// root node).
  /// Audited: 2026-06-12 11:26 EDT
  const HierarchyUtils(String id, [String? parentId]) : _id = id, _parentId = parentId;
  final String _id;

  /// Unique node identifier.
  /// Audited: 2026-06-12 11:26 EDT
  String get id => _id;
  final String? _parentId;

  /// Parent node id; null for roots.
  /// Audited: 2026-06-12 11:26 EDT
  String? get parentId => _parentId;

  @override
  String toString() => 'HierarchyUtils(id: $_id, parentId: ${_parentId ?? ''})';
}

/// Flattens tree: [nodes] has (id, parentId). Returns list of (id, level). Root level = 0.
///
/// Assumes an acyclic parent graph: a cycle among [nodes] causes unbounded
/// recursion. Recursion depth equals the tree height.
/// Audited: 2026-06-12 11:26 EDT
List<(String, int)> flattenHierarchy(List<HierarchyUtils> nodes) {
  final Map<String, String?> parent = {for (final n in nodes) n.id: n.parentId};
  final List<(String, int)> out = <(String, int)>[];
  void visit(String id, int level) {
    out.add((id, level));
    for (final MapEntry<String, String?> e in parent.entries) {
      if (e.value == id) visit(e.key, level + 1);
    }
  }

  final Set<String> ids = parent.keys.toSet();
  for (final root in nodes) {
    final String? p = root.parentId;
    // Treat a node as a root when it has no parent OR names a parent that does
    // not exist in the set: otherwise an orphan (dangling parentId) and its whole
    // subtree are never reached by recursion and silently vanish from the output.
    if (p == null || p.isEmpty || !ids.contains(p)) visit(root.id, 0);
  }
  return out;
}

/// Builds parent map from flat list: id -> parentId (roots have null).
/// Audited: 2026-06-12 11:26 EDT
Map<String, String?> hierarchyFromParentIds(List<HierarchyUtils> nodes) => {
  for (final n in nodes) n.id: n.parentId,
};
