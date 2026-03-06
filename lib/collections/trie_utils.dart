/// Trie (prefix tree) with insert/delete/prefix search (roadmap #491).
library;

/// Simple trie for string keys: insert, delete, prefix search.
class Trie {
  Trie() : _root = _Node();

  final _Node _root;

  /// Inserts [key] into the trie; empty key is ignored.
  void insert(String key) {
    if (key.isEmpty) return;
    _Node node = _root;
    for (int i = 0; i < key.length; i++) {
      node = node.getOrCreateChild(key[i]);
    }
    node.isEnd = true;
  }

  bool search(String key) {
    _Node? node = _find(key);
    return node != null && node.isEnd;
  }

  /// True if some key has [prefix] as a prefix.
  bool startsWith(String prefix) => _find(prefix) != null;

  /// Removes [key] from the trie if present.
  void delete(String key) {
    if (key.isEmpty) return;
    _delete(_root, key, 0);
  }

  bool _delete(_Node node, String key, int depth) {
    if (depth == key.length) {
      if (!node.isEnd) return false;
      node.isEnd = false; // ignore: saropa_lints/avoid_parameter_mutation
      return node.hasNoChildren;
    }
    final String c = key[depth];
    final _Node? child = node.getChild(c);
    if (child == null) return false;
    final bool shouldRemove = _delete(child, key, depth + 1);
    if (shouldRemove) {
      node.removeChild(c); // ignore: saropa_lints/avoid_parameter_mutation
      return node.hasNoChildren && !node.isEnd;
    }
    return false;
  }

  _Node? _find(String s) {
    _Node? node = _root;
    for (int i = 0; i < s.length; i++) {
      if (node == null) return null;
      node = node.getChild(s[i]);
    }
    return node;
  }

  /// All keys with prefix [prefix].
  List<String> keysWithPrefix(String prefix) {
    final _Node? start = _find(prefix);
    if (start == null) return <String>[];
    return _collect(start, prefix);
  }

  List<String> _collect(_Node node, String path) {
    final List<String> out = <String>[];
    if (node.isEnd) out.add(path);
    for (final MapEntry<String, _Node> e in node.childEntries) {
      out.addAll(_collect(e.value, path + e.key));
    }
    return out;
  }

  static const String _kToStringPrefix = 'Trie()';

  @override
  String toString() => _kToStringPrefix;
}

class _Node {
  final Map<String, _Node> _children = <String, _Node>{};
  bool _isEnd = false;

  bool get isEnd => _isEnd;
  // ignore: prefer_named_boolean_parameters - setters have a single positional parameter
  set isEnd(bool isEndValue) => _isEnd = isEndValue;

  _Node? getChild(String c) => _children[c];

  _Node getOrCreateChild(String c) => _children.putIfAbsent(c, () => _Node());

  void removeChild(String c) => _children.remove(c);

  bool get hasNoChildren => _children.isEmpty;

  Iterable<MapEntry<String, _Node>> get childEntries => _children.entries;

  @override
  String toString() => '_Node(isEnd: $_isEnd, children: ${_children.length})';
}
