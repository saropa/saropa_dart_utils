/// BK-tree for approximate string matching — roadmap #493.
///
/// A BK-tree indexes strings under a metric distance (default:
/// Damerau–Levenshtein) so that "all words within edit distance `k` of a
/// query" can be answered without comparing the query to every word. It relies
/// on the triangle inequality: if a stored word `w` is distance `d` from the
/// query, any acceptable match must be a child of `w` reached by an edge whose
/// label lies in `[d - k, d + k]`, so whole subtrees outside that band are
/// pruned.
///
/// The distance function MUST be a true metric (non-negative, symmetric,
/// satisfies the triangle inequality) for the pruning to stay correct;
/// Damerau–Levenshtein and Levenshtein both qualify.
library;

import 'damerau_levenshtein_utils.dart';

/// Distance between two strings; must be a metric for correct pruning.
typedef StringDistance = int Function(String a, String b);

class _BkNode {
  _BkNode(this.word);
  final String word;

  /// Children keyed by their edit distance from this node's word. At most one
  /// child per distance value — collisions descend into that child instead.
  final Map<int, _BkNode> children = <int, _BkNode>{};
}

/// An approximate-match index over a set of strings.
class BkTree {
  /// Creates an index using [distance] (defaults to Damerau–Levenshtein).
  /// Audited: 2026-06-12 11:26 EDT
  BkTree([StringDistance? distance]) : _distance = distance ?? damerauLevenshteinDistance;

  final StringDistance _distance;
  _BkNode? _root;
  int _size = 0;

  /// Number of distinct words stored (duplicates are ignored).
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _size;

  /// Inserts [word]. A word already present (distance 0 to an existing node) is
  /// ignored, keeping the tree a set rather than a multiset.
  ///
  /// Example:
  /// ```dart
  /// final BkTree t = BkTree()..add('book')..add('books')..add('cake');
  /// t.search('boo', 2); // ['book', 'books']
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  void add(String word) {
    final _BkNode? root = _root;
    if (root == null) {
      _root = _BkNode(word);
      _size++;
      return;
    }
    _BkNode node = root;
    // Descend until we find a free distance slot; reuse the slot's child on
    // collision so equidistant words still get a home.
    while (true) {
      final int d = _distance(node.word, word);
      if (d == 0) return; // already present
      final _BkNode? child = node.children[d];
      if (child == null) {
        node.children[d] = _BkNode(word);
        _size++;
        return;
      }
      node = child;
    }
  }

  /// Returns every stored word within edit distance [maxDistance] of [query],
  /// in no particular order. Requires `maxDistance >= 0`.
  /// Audited: 2026-06-12 11:26 EDT
  List<String> search(String query, int maxDistance) {
    assert(maxDistance >= 0, 'maxDistance ($maxDistance) must be >= 0');
    final List<String> matches = <String>[];
    final _BkNode? root = _root;
    if (root == null) return matches;
    // Explicit stack avoids deep recursion on long word chains.
    final List<_BkNode> stack = <_BkNode>[root];
    while (stack.isNotEmpty) {
      final _BkNode node = stack.removeLast();
      final int d = _distance(node.word, query);
      if (d <= maxDistance) matches.add(node.word);
      // ignore: saropa_lints/prefer_spread_over_addall -- appends candidates into the persistent work stack, not a one-shot list build
      stack.addAll(_candidates(node, d, maxDistance));
    }
    return matches;
  }

  // Children whose edge distance falls in the triangle-inequality band
  // [d - maxDistance, d + maxDistance]; the rest cannot hold a match.
  List<_BkNode> _candidates(_BkNode node, int d, int maxDistance) {
    final int low = d - maxDistance;
    final int high = d + maxDistance;
    return <_BkNode>[
      for (final MapEntry<int, _BkNode> e in node.children.entries)
        if (e.key >= low && e.key <= high) e.value,
    ];
  }

  @override
  String toString() => 'BkTree(length: $_size)';
}
