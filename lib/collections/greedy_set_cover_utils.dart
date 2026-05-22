/// Greedy set cover approximation — roadmap #447.
library;

/// Returns subset of indices into [sets] that covers [universe].
/// [sets] is list of sets; [universe] is the full set of elements to cover.
List<int> greedySetCover(List<Set<Object>> sets, Set<Object> universe) {
  final Set<Object> remaining = Set<Object>.of(universe);
  final List<int> cover = [];
  while (remaining.isNotEmpty) {
    int best = -1;
    int bestCount = 0;
    for (int i = 0; i < sets.length; i++) {
      final int count = sets[i].intersection(remaining).length;
      if (count > bestCount) {
        bestCount = count;
        best = i;
      }
    }
    if (best < 0) break;
    cover.add(best);
    remaining.removeAll(sets[best]);
  }
  return cover;
}
