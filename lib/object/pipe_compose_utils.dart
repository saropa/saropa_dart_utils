/// Pipe (chain unary functions). Compose (f(g(x))). Once (run block only once). Roadmap #246-248.
library;

/// Builds a function that threads its input left-to-right through [fns],
/// passing each result to the next. Throws a [StateError] if the final value
/// is not assignable to [R].
///
/// Example:
/// ```dart
/// final f = pipe<int, int>([(x) => x + 1, (x) => x * 2]);
/// f(3); // 8
/// ```
/// Audited: 2026-06-12 11:26 EDT
R Function(T) pipe<T, R>(List<R Function(dynamic)> fns) => (T x) {
  dynamic v = x;
  for (final R Function(dynamic) f in fns) {
    v = f(v);
  }
  if (v is R) return v;
  throw StateError('pipe: result is ${v.runtimeType}, expected $R');
};

/// Returns the mathematical composition `f(g(x))`: applies [g] first, then [f].
///
/// Example:
/// ```dart
/// final f = compose<int, int, String>((m) => 'v$m', (t) => t + 1);
/// f(2); // 'v3'
/// ```
/// Audited: 2026-06-12 11:26 EDT
R Function(T) compose<T, M, R>(R Function(M) f, M Function(T) g) =>
    (T x) => f(g(x));

/// Returns a callable that runs [block] only on its first invocation and is a
/// no-op thereafter. Useful for one-time initialization guards.
///
/// Example:
/// ```dart
/// final init = once(() => print('setup'));
/// init(); // prints 'setup'
/// init(); // does nothing
/// ```
/// Audited: 2026-06-12 11:26 EDT
void Function() once(void Function() block) {
  bool isDone = false;
  return () {
    if (!isDone) {
      isDone = true;
      block();
    }
  };
}
