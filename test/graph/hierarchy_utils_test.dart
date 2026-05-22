import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/hierarchy_utils.dart';

void main() {
  group('HierarchyUtils (node)', () {
    test('constructor with parentId exposes id and parentId', () {
      const HierarchyUtils node = HierarchyUtils('child', 'root');
      expect(node.id, 'child');
      expect(node.parentId, 'root');
    });

    test('constructor without parentId yields null parentId (root)', () {
      const HierarchyUtils node = HierarchyUtils('root');
      expect(node.id, 'root');
      expect(node.parentId, isNull);
    });

    test('toString renders id and parentId', () {
      expect(const HierarchyUtils('a', 'b').toString(), 'HierarchyUtils(id: a, parentId: b)');
    });

    test('toString renders empty parentId for root', () {
      expect(const HierarchyUtils('a').toString(), 'HierarchyUtils(id: a, parentId: )');
    });
  });

  group('flattenHierarchy', () {
    test('flattens a two-level tree with correct levels', () {
      // root -> a, root -> b
      final List<(String, int)> result = flattenHierarchy(<HierarchyUtils>[
        const HierarchyUtils('root'),
        const HierarchyUtils('a', 'root'),
        const HierarchyUtils('b', 'root'),
      ]);
      // root first at level 0, then its children at level 1 (encounter order)
      expect(result, <(String, int)>[('root', 0), ('a', 1), ('b', 1)]);
    });

    test('flattens a three-level chain with increasing levels', () {
      final List<(String, int)> result = flattenHierarchy(<HierarchyUtils>[
        const HierarchyUtils('root'),
        const HierarchyUtils('mid', 'root'),
        const HierarchyUtils('leaf', 'mid'),
      ]);
      expect(result, <(String, int)>[('root', 0), ('mid', 1), ('leaf', 2)]);
    });

    test('multiple roots are each emitted at level 0', () {
      final List<(String, int)> result = flattenHierarchy(<HierarchyUtils>[
        const HierarchyUtils('r1'),
        const HierarchyUtils('r2'),
      ]);
      expect(result, <(String, int)>[('r1', 0), ('r2', 0)]);
    });

    test('single root node returns just itself at level 0', () {
      expect(
        flattenHierarchy(<HierarchyUtils>[const HierarchyUtils('only')]),
        <(String, int)>[('only', 0)],
      );
    });

    test('empty node list returns empty', () {
      expect(flattenHierarchy(<HierarchyUtils>[]), <(String, int)>[]);
    });

    test('empty-string parentId is treated as a root', () {
      // root detection uses (parentId ?? '').isEmpty, so '' counts as root.
      final List<(String, int)> result = flattenHierarchy(<HierarchyUtils>[
        const HierarchyUtils('r', ''),
        const HierarchyUtils('c', 'r'),
      ]);
      expect(result, <(String, int)>[('r', 0), ('c', 1)]);
    });
  });

  group('hierarchyFromParentIds', () {
    test('builds id -> parentId map', () {
      final Map<String, String?> map = hierarchyFromParentIds(<HierarchyUtils>[
        const HierarchyUtils('root'),
        const HierarchyUtils('a', 'root'),
        const HierarchyUtils('b', 'a'),
      ]);
      expect(map, <String, String?>{'root': null, 'a': 'root', 'b': 'a'});
    });

    test('empty node list yields empty map', () {
      expect(hierarchyFromParentIds(<HierarchyUtils>[]), <String, String?>{});
    });

    test('single root maps id to null', () {
      expect(
        hierarchyFromParentIds(<HierarchyUtils>[const HierarchyUtils('x')]),
        <String, String?>{'x': null},
      );
    });
  });
}
