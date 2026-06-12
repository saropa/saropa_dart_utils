/// Priority map (priority -> queues) — roadmap #528.
library;

import 'package:collection/collection.dart';

/// Buckets values by a priority key, draining buckets in the order each
/// priority was FIRST added (insertion order), and FIFO within a bucket.
///
/// IMPORTANT: this does NOT order buckets by comparing the [K] priority value —
/// `K` is not constrained to `Comparable`, so `removeFirst` returns the
/// first-inserted priority bucket, not the numerically lowest. Adding priority
/// `2` before priority `1` drains `2` first. For value-ordered priority,
/// pre-sort additions by priority, or use a structure backed by a
/// `SplayTreeMap`/heap with a `Comparable` key.
class PriorityMapUtils<K extends Object, V extends Object> {
  final Map<K, List<V>> _queues = <K, List<V>>{};

  /// Enqueues [value] under [priority], creating the bucket if needed.
  /// Audited: 2026-06-12 11:26 EDT
  void add(K priority, V value) {
    _queues.putIfAbsent(priority, () => <V>[]).add(value);
  }

  /// Removes and returns the next item: FIFO from the first-added priority
  /// bucket (NOT the lowest priority value — see the class doc), or null when
  /// the map is empty. Emptied buckets are pruned.
  /// Audited: 2026-06-12 11:26 EDT
  V? removeFirst() {
    if (_queues.isEmpty) return null;
    final entry = _queues.entries.firstOrNull;
    if (entry == null) return null;
    final List<V> q = entry.value;
    final V v = q.removeAt(0);
    final K key = entry.key;
    if (q.isEmpty) _queues.remove(key);
    return v;
  }

  /// True when no items remain.
  /// Audited: 2026-06-12 11:26 EDT
  bool get isEmpty => _queues.isEmpty;

  @override
  String toString() => 'PriorityMapUtils(priorities: ${_queues.length})';
}
