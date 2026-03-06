/// Deterministic shuffler with seed — roadmap #529.
library;

import 'dart:math' show Random;

/// Returns a new list with elements shuffled using [seed].
List<T> shuffleWithSeed<T>(List<T> list, int seed) {
  final List<T> out = List<T>.of(list);
  final Random r = Random(seed);
  for (int i = out.length - 1; i > 0; i--) {
    final int j = r.nextInt(i + 1);
    final T t = out[i];
    out[i] = out[j];
    out[j] = t;
  }
  return out;
}
