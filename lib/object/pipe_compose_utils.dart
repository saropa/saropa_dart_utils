/// Pipe (chain unary functions). Compose (f(g(x))). Once (run block only once). Roadmap #246-248.
R Function(T) pipe<T, R>(List<R Function(dynamic)> fns) {
  return (T x) {
    dynamic v = x;
    for (final R Function(dynamic) f in fns) v = f(v);
    if (v is R) return v;
    throw StateError('pipe: result is ${v.runtimeType}, expected $R');
  };
}

R Function(T) compose<T, M, R>(R Function(M) f, M Function(T) g) =>
    (T x) => f(g(x));

void Function() once(void Function() block) {
  bool isDone = false;
  return () {
    if (!isDone) {
      isDone = true;
      block();
    }
  };
}
