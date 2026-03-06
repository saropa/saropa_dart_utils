/// Reservoir sampling for streaming data (roadmap #452).
library;

import 'dart:math';

final Random _rand = Random();

/// Takes a sample of [k] items from [items] with equal probability per item (single pass).
/// If [items].length <= k, returns a copy of [items]; otherwise returns k random items.
List<T> reservoirSample<T>(List<T> items, int k, [Random? random]) {
  final Random r = random ?? _rand;
  if (items.isEmpty || k < 1) return <T>[];
  if (items.length <= k) return List<T>.of(items);
  final List<T> reservoir = List<T>.of(items.take(k));
  for (int i = k; i < items.length; i++) {
    final int j = r.nextInt(i + 1);
    if (j < k) reservoir[j] = items[i];
  }
  return reservoir;
}
