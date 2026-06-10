/// Sampling helpers (stratified, systematic) — roadmap #584.
library;

import 'dart:math' show Random;

/// Systematic sampling: take every [step]-th element starting at [start].
List<T> systematicSample<T>(List<T> list, int step, {int start = 0}) {
  if (step < 1) return <T>[];
  final List<T> out = <T>[];
  for (int i = start; i < list.length; i += step) {
    out.add(list[i]);
  }
  return out;
}

/// Stratified: [strata] gives group id per index; sample [perGroup] from each.
List<int> stratifiedSampleIndices(List<Object?> strata, int perGroup, [Random? random]) {
  // Accept an injected Random so tests can seed it for deterministic samples;
  // default to a fresh source otherwise.
  final Random r = random ?? Random();
  // Bucket the original indices by their stratum id, preserving which position
  // each belongs to (the function returns indices, not the strata values).
  final Map<Object?, List<int>> groups = <Object?, List<int>>{};
  for (int i = 0; i < strata.length; i++) {
    groups.putIfAbsent(strata[i], () => <int>[]).add(i);
  }
  final List<int> out = <int>[];
  // Within each stratum, shuffle then take from the front so the perGroup picks
  // are random; the `j < indices.length` bound takes the whole group when it is
  // smaller than perGroup rather than over-drawing.
  for (final List<int> indices in groups.values) {
    indices.shuffle(r);
    for (int j = 0; j < perGroup && j < indices.length; j++) {
      out.add(indices[j]);
    }
  }
  return out;
}
