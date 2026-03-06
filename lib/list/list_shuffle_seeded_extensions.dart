import 'dart:math';
import 'package:meta/meta.dart';

/// Shuffle with seed (reproducible).
extension ListShuffleSeededExtensions<T> on List<T> {
  /// Returns a new list with elements shuffled using [seed]. Same seed => same order.
  @useResult
  List<T> shuffleWithSeed(int seed) {
    final List<T> copy = toList();
    copy.shuffle(Random(seed));
    return copy;
  }
}
