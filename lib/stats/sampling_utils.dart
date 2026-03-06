/// Sampling helpers (stratified, systematic) — roadmap #584.
library;

import 'dart:math' show Random;

/// Systematic sampling: take every [step]-th element starting at [start].
List<T> systematicSample<T>(List<T> list, int step, {int start = 0}) {
  if (step < 1) return [];
  final List<T> out = [];
  for (int i = start; i < list.length; i += step) out.add(list[i]);
  return out;
}

/// Stratified: [strata] gives group id per index; sample [perGroup] from each.
List<int> stratifiedSampleIndices(List<Object?> strata, int perGroup, [Random? random]) {
  final Random r = random ?? Random();
  final Map<Object?, List<int>> groups = <Object?, List<int>>{};
  for (int i = 0; i < strata.length; i++) {
    groups.putIfAbsent(strata[i], () => []).add(i);
  }
  final List<int> out = [];
  for (final List<int> indices in groups.values) {
    indices.shuffle(r);
    for (int j = 0; j < perGroup && j < indices.length; j++) out.add(indices[j]);
  }
  return out;
}
