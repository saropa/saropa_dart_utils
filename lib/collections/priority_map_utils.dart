/// Priority map (priority -> queues) — roadmap #528.
library;

import 'package:collection/collection.dart';

/// Map of priority (lower = higher priority) to queue of items.
class PriorityMapUtils<K extends Object, V extends Object> {
  final Map<K, List<V>> _queues = <K, List<V>>{};

  void add(K priority, V value) {
    _queues.putIfAbsent(priority, () => []).add(value);
  }

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
  bool get isEmpty => _queues.isEmpty;

  @override
  String toString() => 'PriorityMapUtils(priorities: ${_queues.length})';
}
