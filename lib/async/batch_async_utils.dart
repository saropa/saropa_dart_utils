/// Callback that transforms an item asynchronously.
typedef AsyncMapper<A, T> = Future<T> Function(A item);

/// Batch async (e.g. 5 at a time). Roadmap #182.
Future<List<T>> mapBatched<A, T>(
  Iterable<A> items,
  AsyncMapper<A, T> fn, {
  int batchSize = 5,
}) async {
  final List<A> list = items.toList();
  final List<T> out = <T>[];
  for (int i = 0; i < list.length; i += batchSize) {
    final batch = list.skip(i).take(batchSize).map(fn);
    final results = await Future.wait(batch, eagerError: false);
    out.addAll(results);
  }
  return out;
}
