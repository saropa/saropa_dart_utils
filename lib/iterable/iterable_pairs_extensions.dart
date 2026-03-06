import 'package:meta/meta.dart';

/// All pairs (i, j) with i < j.
extension IterablePairsExtensions<T> on Iterable<T> {
  /// All unordered pairs [(a, b)] where a appears before b in this iterable.
  @useResult
  List<(T, T)> allPairs() {
    final List<T> list = toList();
    final List<(T, T)> result = <(T, T)>[];
    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length; j++) {
        result.add((list[i], list[j]));
      }
    }
    return result;
  }
}
