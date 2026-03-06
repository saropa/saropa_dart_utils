/// Sequential async map (one after another). Roadmap #181.
Future<List<B>> mapSequential<A, B>(Iterable<A> items, Future<B> Function(A) fn) async {
  final List<B> out = <B>[];
  for (final A item in items) {
    out.add(await fn(item));
  }
  return out;
}
