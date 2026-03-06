/// Batch async (e.g. 5 at a time). Roadmap #182.
Future<List<T>> mapBatched<A, T>(
  Iterable<A> items,
  Future<T> Function(A) fn, {
  int batchSize = 5,
}) async {
  final List<A> list = items.toList();
  final List<T> out = <T>[];
  for (int i = 0; i < list.length; i += batchSize) {
    final List<Future<T>> batch = list.skip(i).take(batchSize).map((A a) => fn(a)).toList();
    out.addAll(await Future.wait(batch));
  }
  return out;
}
