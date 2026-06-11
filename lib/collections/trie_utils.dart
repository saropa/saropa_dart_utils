/// Trie (prefix tree) with insert/delete/prefix search (roadmap #491).
library;

/// Simple trie for string keys: insert, delete, prefix search.
class TrieUtils {
  /// Creates an empty trie.
  TrieUtils() : _root = _TrieNode();

  final _TrieNode _root;

  /// Inserts [key] into the trie; empty key is ignored.
  void insert(String key) {
    if (key.isEmpty) return;
    _TrieNode node = _root;
    for (int i = 0; i < key.length; i++) {
      node = node.getOrCreateChild(key[i]);
    }
    node.isEnd = true;
  }

  /// True if [key] was inserted as a complete word (not merely a prefix).
  bool search(String key) {
    final _TrieNode? node = _find(key);
    return node != null && node.isEnd;
  }

  /// True if some key has [prefix] as a prefix.
  bool startsWith(String prefix) => _find(prefix) != null;

  /// Removes [key] from the trie if present.
  void delete(String key) {
    if (key.isEmpty) return;
    // ignore: saropa_lints/avoid_ignoring_return_values -- bool signals child-prune to caller; root is never pruned here
    _delete(_root, key, 0);
  }

  bool _delete(_TrieNode node, String key, int depth) {
    if (depth == key.length) {
      if (!node.isEnd) return false;
      node.isEnd = false; // ignore: saropa_lints/avoid_parameter_mutation
      return node.hasNoChildren;
    }
    final String c = key[depth];
    final _TrieNode? child = node.getChild(c);
    if (child == null) return false;
    final bool shouldRemove = _delete(child, key, depth + 1);
    if (shouldRemove) {
      node.removeChild(c); // ignore: saropa_lints/avoid_parameter_mutation
      return node.hasNoChildren && !node.isEnd;
    }
    return false;
  }

  _TrieNode? _find(String s) {
    _TrieNode? node = _root;
    for (int i = 0; i < s.length; i++) {
      if (node == null) return null;
      node = node.getChild(s[i]);
    }
    return node;
  }

  /// All keys with prefix [prefix].
  List<String> keysWithPrefix(String prefix) {
    final _TrieNode? start = _find(prefix);
    if (start == null) return <String>[];
    return _collect(start, prefix);
  }

  List<String> _collect(_TrieNode node, String path) {
    final List<String> out = <String>[];
    if (node.isEnd) out.add(path);
    for (final MapEntry<String, _TrieNode> e in node.childEntries) {
      // ignore: saropa_lints/prefer_spread_over_addall -- accumulates across loop iterations; spread would be O(n^2)
      out.addAll(_collect(e.value, path + e.key));
    }
    return out;
  }

  static const String _kToStringPrefix = 'TrieUtils()';

  @override
  String toString() => _kToStringPrefix;
}

class _TrieNode {
  final Map<String, _TrieNode> _children = <String, _TrieNode>{};
  bool _isEnd = false;

  bool get isEnd => _isEnd;
  // ignore: prefer_named_boolean_parameters - setters have a single positional parameter
  // ignore: saropa_lints/prefer_correct_setter_parameter_name -- positional setter param; 'value' not required
  set isEnd(bool isEndValue) => _isEnd = isEndValue;

  _TrieNode? getChild(String c) => _children[c];

  _TrieNode getOrCreateChild(String c) => _children.putIfAbsent(c, () => _TrieNode());

  void removeChild(String c) => _children.remove(c);

  bool get hasNoChildren => _children.isEmpty;

  Iterable<MapEntry<String, _TrieNode>> get childEntries => _children.entries;

  @override
  String toString() => '_TrieNode(isEnd: $_isEnd, children: ${_children.length})';
}
