import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/graph/tree_utils.dart';

void main() {
  group('lowestCommonAncestor', () {
    // Tree:        0 (root)
    //            /   \
    //           1     2
    //          / \
    //         3   4
    // parent array indexed by node: 0->-1, 1->0, 2->0, 3->1, 4->1
    const List<int> parent = <int>[-1, 0, 0, 1, 1];

    test('LCA of two siblings is their parent', () {
      expect(lowestCommonAncestor(parent, 3, 4), 1);
    });

    test('LCA of nodes in different subtrees is the root', () {
      expect(lowestCommonAncestor(parent, 3, 2), 0);
    });

    test('LCA of a node and its ancestor is the ancestor', () {
      expect(lowestCommonAncestor(parent, 3, 1), 1);
    });

    test('LCA of a node with itself is the node', () {
      expect(lowestCommonAncestor(parent, 4, 4), 4);
    });

    test('LCA involving the root is the root', () {
      expect(lowestCommonAncestor(parent, 0, 4), 0);
    });

    test('single-node tree: LCA of root with itself is root', () {
      expect(lowestCommonAncestor(<int>[-1], 0, 0), 0);
    });
  });

  group('treeDepths', () {
    test('computes depth of each node (root = 0)', () {
      // 0 root; 1,2 children of 0; 3,4 children of 1
      const List<int> parent = <int>[-1, 0, 0, 1, 1];
      expect(treeDepths(parent), <int>[0, 1, 1, 2, 2]);
    });

    test('linear chain has increasing depths', () {
      // 0 -> 1 -> 2 -> 3
      const List<int> parent = <int>[-1, 0, 1, 2];
      expect(treeDepths(parent), <int>[0, 1, 2, 3]);
    });

    test('single root has depth 0', () {
      expect(treeDepths(<int>[-1]), <int>[0]);
    });

    test('empty parent array returns empty depths', () {
      expect(treeDepths(<int>[]), <int>[]);
    });

    test('forest with two roots: each subtree depth measured from its root', () {
      // Two roots 0 and 1; 2 child of 0; 3 child of 1
      const List<int> parent = <int>[-1, -1, 0, 1];
      expect(treeDepths(parent), <int>[0, 0, 1, 1]);
    });
  });
}
