/// Hierarchy flattener and builder from flat list with parent ids — roadmap #556, #557.
library;

/// Node with id and optional parentId for tree building.
class HierarchyUtils {
  const HierarchyUtils(String id, [String? parentId]) : _id = id, _parentId = parentId;
  final String _id;

  /// Unique node identifier.
  String get id => _id;
  final String? _parentId;

  /// Parent node id; null for roots.
  String? get parentId => _parentId;

  @override
  String toString() => 'HierarchyUtils(id: $_id, parentId: ${_parentId ?? ""})';
}

/// Flattens tree: [nodes] has (id, parentId). Returns list of (id, level). Root level = 0.
List<(String, int)> flattenHierarchy(List<HierarchyUtils> nodes) {
  final Map<String, String?> parent = {for (final n in nodes) n.id: n.parentId};
  final List<(String, int)> out = <(String, int)>[];
  void visit(String id, int level) {
    out.add((id, level));
    for (final MapEntry<String, String?> e in parent.entries) {
      if (e.value == id) visit(e.key, level + 1);
    }
  }

  for (final n in nodes) {
    if ((n.parentId ?? '').isEmpty) visit(n.id, 0);
  }
  return out;
}

/// Builds parent map from flat list: id -> parentId (roots have null).
Map<String, String?> hierarchyFromParentIds(List<HierarchyUtils> nodes) {
  return {for (final n in nodes) n.id: n.parentId};
}
