/// Sum, count, average for iterable of num. Roadmap #135.
extension NumIterableSumExtensions on Iterable<num> {
  /// Sum of elements.
  num get sum => fold<num>(0, (num a, num b) => a + b);

  /// Count of elements.
  int get count => toList().length;

  /// Average (mean). Returns null if empty.
  double? get average {
    final List<num> list = toList();
    if (list.isEmpty) return null;
    return sum.toDouble() / list.length;
  }
}
