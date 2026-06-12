/// Data binning helpers: width, quantile, boundary, counts (roadmap #585).
///
/// Binning groups continuous values into a small set of buckets for
/// histograms, bucketed metrics, or feature discretization. Width binning
/// uses uniform intervals; quantile binning uses cut points so each bucket
/// holds a similar count.
library;

/// Assign each value in [values] to an equal-width bin over `[min, max]`.
///
/// The range is split into [bins] intervals of equal width. Values below
/// [min] clamp into bin 0 and values at or above [max] clamp into the last
/// bin, so out-of-range data is never dropped or out of index. Result indices
/// are in `0..bins-1`.
List<int> binByWidth(
  List<num> values, {
  required num min,
  required num max,
  required int bins,
}) {
  assert(bins >= 1, 'binByWidth requires bins >= 1');
  assert(max > min, 'binByWidth requires max > min');
  final double width = (max - min) / bins;
  return values.map((num v) => _widthBin(v.toDouble(), min.toDouble(), width, bins)).toList();
}

/// Bin index for one value; clamps below 0 and above bins-1.
int _widthBin(double value, double min, double width, int bins) {
  final int raw = ((value - min) / width).floor();
  // Clamp so out-of-range values land in the edge bins rather than out of index.
  return raw.clamp(0, bins - 1);
}

/// The [bins]-1 internal cut points splitting sorted [values] into [bins]
/// roughly equal-count groups (quantile boundaries).
///
/// Returns an empty list when [bins] < 2 or [values] is empty (no internal
/// cut exists). Each boundary is the value at the corresponding quantile
/// position in the ascending-sorted data.
List<num> quantileBoundaries(List<num> values, int bins) {
  assert(bins >= 1, 'quantileBoundaries requires bins >= 1');
  // One bin (or fewer) and empty input both have no internal cut points.
  if (bins < 2 || values.isEmpty) return <num>[];
  final List<double> sorted = values.map((num v) => v.toDouble()).toList()..sort();
  final List<num> cuts = <num>[];
  // The k-th cut sits at the k/bins fraction of the sorted data.
  for (int k = 1; k < bins; k++) {
    final int index = (sorted.length * k / bins).floor().clamp(0, sorted.length - 1);
    cuts.add(sorted[index]);
  }
  return cuts;
}

/// Assign each value in [values] to a bin using ascending [boundaries].
///
/// A value goes to the index of the first boundary it does not exceed
/// (upper-bound search): values `<= boundaries[0]` go to bin 0, and values
/// greater than every boundary go to bin `boundaries.length`. Result indices
/// are in `0..boundaries.length`.
List<int> binByBoundaries(List<num> values, List<num> boundaries) =>
    values.map((num v) => _upperBoundBin(v.toDouble(), boundaries)).toList();

/// Index of the first boundary not exceeded by [value]; boundaries.length if none.
int _upperBoundBin(double value, List<num> boundaries) {
  int lo = 0;
  int hi = boundaries.length;
  // Binary search for the first boundary >= value; ties land in the lower bin.
  while (lo < hi) {
    final int mid = (lo + hi) >> 1;
    if (boundaries[mid].toDouble() < value) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  return lo;
}

/// Frequency of each bin index in [binIndices], over [bins] buckets.
///
/// Returns a list of length [bins]; indices outside `0..bins-1` are ignored
/// so a stray out-of-range index cannot grow or corrupt the histogram.
List<int> binCounts(List<int> binIndices, int bins) {
  assert(bins >= 1, 'binCounts requires bins >= 1');
  final List<int> counts = List<int>.filled(bins, 0);
  for (final int index in binIndices) {
    // Skip out-of-range indices defensively rather than throwing on bad input.
    if (index >= 0 && index < bins) counts[index]++;
  }
  return counts;
}
