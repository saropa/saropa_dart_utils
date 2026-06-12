/// Skip list: a probabilistic ordered set — roadmap #502.
///
/// Keeps elements in sorted order with `O(log n)` expected search, insert, and
/// delete, plus `O(1)` `floor`/`ceiling` neighbor lookups, without the
/// rotation bookkeeping a balanced BST needs. Each node is linked at one or
/// more levels; a node is promoted to the next level up with probability 1/2,
/// so on average half the nodes appear at each higher level and a search can
/// skip exponentially far ahead before dropping down — hence "skip list".
///
/// This is a SET: [add] returns false for a value already present (uniqueness
/// is decided by the supplied [Comparator] returning 0). Promotion uses an
/// injectable [Random] so tests can seed it for fully deterministic structure.
library;

import 'dart:math';

/// One skip-list node holding a [value] and forward links per level.
class _SkipNode<T> {
  /// Builds a data node carrying [value], linkable up to [level].
  /// Audited: 2026-06-12 11:26 EDT
  _SkipNode(T value, int level) : forward = List<_SkipNode<T>?>.filled(level + 1, null) {
    this.value = value;
  }

  /// Builds the head sentinel: it owns forward links at every level but never a
  /// value, so [value] is deliberately left unassigned and must never be read.
  /// Audited: 2026-06-12 11:26 EDT
  _SkipNode.head(int level) : forward = List<_SkipNode<T>?>.filled(level + 1, null);

  /// The stored value. Non-nullable for data nodes; on the head sentinel it is
  /// never assigned and never read (head traversal always starts at forward[0]).
  /// `late final` (not `T?`) is deliberate: a nullable field would force an
  /// `as T` cast at every read site for a value that is never actually null on
  /// the data nodes, trading one localized invariant here for unsafe casts
  /// throughout. The sentinel's value is structurally unreachable.
  // ignore: prefer_nullable_over_late -- see field doc: nullable would force unsafe casts everywhere
  late final T value;

  /// `forward[i]` is the next node at level `i`, or null at the tail.
  final List<_SkipNode<T>?> forward;
}

/// A probabilistic ordered set keyed by a [Comparator].
class SkipList<T> {
  /// Creates an empty set ordered by [compare]. Pass [random] (seeded) for
  /// deterministic level promotion; defaults to a fresh [Random].
  /// Audited: 2026-06-12 11:26 EDT
  SkipList(this._compare, {Random? random}) : _random = random ?? Random();

  final Comparator<T> _compare;
  final Random _random;

  /// Cap on levels; 32 supports far more elements than any in-memory set needs
  /// (a 32-level list addresses ~4 billion entries at the 1/2 promotion rate).
  static const int _maxLevel = 32;

  /// Head sentinel; its forward links are the entry points at each level.
  /// Audited: 2026-06-12 11:26 EDT
  final _SkipNode<T> _head = _SkipNode<T>.head(_maxLevel);

  /// Highest level currently in use (0-based).
  int _level = 0;
  int _length = 0;

  /// Number of elements in the set.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _length;

  /// Whether the set holds no elements.
  /// Audited: 2026-06-12 11:26 EDT
  bool get isEmpty => _length == 0;

  /// Draws a node level: keep promoting while a coin flip stays heads, capped at
  /// [_maxLevel]. Geometric distribution with p = 1/2 gives the `O(log n)`
  /// expected height.
  /// Audited: 2026-06-12 11:26 EDT
  int _randomLevel() {
    int level = 0;
    while (level < _maxLevel - 1 && _random.nextBool()) {
      level++;
    }
    return level;
  }

  /// Fills [update] with, for each level, the last node whose value is strictly
  /// less than [value]; returns the candidate node at level 0 (which holds
  /// [value] if present). Shared by [add], [remove], [contains].
  /// Audited: 2026-06-12 11:26 EDT
  _SkipNode<T>? _findPredecessors(T value, List<_SkipNode<T>?> update) {
    _SkipNode<T> current = _head;
    // Descend from the top level, walking right while the next value is < target.
    for (int i = _level; i >= 0; i--) {
      _SkipNode<T>? next = current.forward[i];
      while (next != null && _compare(next.value, value) < 0) {
        current = next;
        next = current.forward[i];
      }
      update[i] = current;
    }
    // forward always has at least level 0, so index 0 cannot be out of range.
    return current.forward[0];
  }

  /// Adds [value]; returns false (and changes nothing) if it is already present.
  ///
  /// Example:
  /// ```dart
  /// final SkipList<int> s = SkipList<int>((int a, int b) => a.compareTo(b));
  /// s.add(3); // true
  /// s.add(3); // false (already present)
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  bool add(T value) {
    final List<_SkipNode<T>?> update = List<_SkipNode<T>?>.filled(_maxLevel, null);
    final _SkipNode<T>? candidate = _findPredecessors(value, update);
    // Reject duplicates: a value comparing equal to the candidate already exists.
    if (candidate != null && _compare(candidate.value, value) == 0) {
      return false;
    }
    final int newLevel = _randomLevel();
    // New node is taller than the list: the head is the predecessor on the
    // fresh upper levels, so record it there before linking.
    if (newLevel > _level) {
      for (int i = _level + 1; i <= newLevel; i++) {
        update[i] = _head;
      }
      _level = newLevel;
    }
    final _SkipNode<T> node = _SkipNode<T>(value, newLevel);
    for (int i = 0; i <= newLevel; i++) {
      final _SkipNode<T> pred = update[i]!;
      node.forward[i] = pred.forward[i];
      pred.forward[i] = node;
    }
    _length++;
    return true;
  }

  /// Whether [value] is present.
  /// Audited: 2026-06-12 11:26 EDT
  bool contains(T value) {
    final List<_SkipNode<T>?> update = List<_SkipNode<T>?>.filled(_maxLevel, null);
    final _SkipNode<T>? candidate = _findPredecessors(value, update);
    return candidate != null && _compare(candidate.value, value) == 0;
  }

  /// Removes [value]; returns false (and changes nothing) if it was absent.
  /// Audited: 2026-06-12 11:26 EDT
  bool remove(T value) {
    final List<_SkipNode<T>?> update = List<_SkipNode<T>?>.filled(_maxLevel, null);
    final _SkipNode<T>? candidate = _findPredecessors(value, update);
    if (candidate == null || _compare(candidate.value, value) != 0) {
      return false;
    }
    // Unlink at every level the node participates in; stop at the first level
    // where the node is no longer the immediate successor (it was never linked
    // above its own height).
    for (int i = 0; i <= _level; i++) {
      final _SkipNode<T>? pred = update[i];
      if (pred == null || pred.forward[i] != candidate) break;
      pred.forward[i] = candidate.forward[i];
    }
    // Shrink the active level past now-empty top levels.
    while (_level > 0 && _head.forward[_level] == null) {
      _level--;
    }
    _length--;
    return true;
  }

  /// All values in ascending order.
  /// Audited: 2026-06-12 11:26 EDT
  Iterable<T> get values sync* {
    // forward always has level 0, so the head's first link is in range.
    _SkipNode<T>? node = _head.forward[0];
    while (node != null) {
      yield node.value;
      node = node.forward[0];
    }
  }

  /// The largest value `<= value`, or null if every value is greater.
  ///
  /// Example:
  /// ```dart
  /// final SkipList<int> s = SkipList<int>((int a, int b) => a.compareTo(b))
  ///   ..add(2)..add(5)..add(9);
  /// s.floor(7); // 5
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  T? floor(T value) {
    final List<_SkipNode<T>?> update = List<_SkipNode<T>?>.filled(_maxLevel, null);
    final _SkipNode<T>? candidate = _findPredecessors(value, update);
    // An exact match is its own floor.
    if (candidate != null && _compare(candidate.value, value) == 0) {
      return candidate.value;
    }
    // Otherwise the level-0 predecessor is the largest value strictly below;
    // when that predecessor is the head sentinel, nothing is <= value.
    final _SkipNode<T>? pred = update[0];
    if (pred == null || identical(pred, _head)) return null;
    return pred.value;
  }

  /// The smallest value `>= value`, or null if every value is smaller.
  /// Audited: 2026-06-12 11:26 EDT
  T? ceiling(T value) {
    final List<_SkipNode<T>?> update = List<_SkipNode<T>?>.filled(_maxLevel, null);
    final _SkipNode<T>? candidate = _findPredecessors(value, update);
    // The candidate at level 0 is the first value >= target (or null past the end).
    return candidate?.value;
  }

  @override
  String toString() => 'SkipList(length: $_length)';
}
