/// Sequential async map (one after another). Roadmap #181.
/// Audited: 2026-06-12 11:26 EDT
Future<List<B>> mapSequential<A, B>(Iterable<A> items, Future<B> Function(A) fn) async {
  final List<B> out = <B>[];
  for (final A item in items) {
    out.add(await fn(item));
  }
  return out;
}
