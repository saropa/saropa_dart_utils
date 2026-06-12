/// Callback that transforms an item asynchronously.
typedef AsyncMapper<A, T> = Future<T> Function(A item);

/// Batch async (e.g. 5 at a time). Roadmap #182.
/// Audited: 2026-06-12 11:26 EDT
Future<List<T>> mapBatched<A, T>(
  Iterable<A> items,
  AsyncMapper<A, T> fn, {
  int batchSize = 5,
}) async {
  // A non-positive batch size would make `i += batchSize` never advance (or go
  // backward) and hang forever; treat anything below 1 as a batch of 1.
  final int size = batchSize < 1 ? 1 : batchSize;
  final List<A> list = items.toList();
  final List<T> out = <T>[];
  for (int i = 0; i < list.length; i += size) {
    final batch = list.skip(i).take(size).map(fn);
    final List<T> results = await Future.wait(batch, eagerError: false);
    // ignore: prefer_spread_over_addall -- accumulates across loop iterations; rebuilding via spread each pass would be O(n^2)
    out.addAll(results);
  }
  return out;
}
