/// Observability helpers: wrap operations with timing and outcome hooks —
/// roadmap #680.
///
/// Every app eventually sprinkles `final sw = Stopwatch()..start(); … log(...)`
/// around the same operations. These wrappers centralize that: run the work,
/// measure how long it took, hand the duration and the outcome to optional
/// hooks (for logging, metrics, tracing), and return the result unchanged — or
/// rethrow the original error after reporting it. The wrappers add timing only;
/// they never swallow a failure.
library;

/// Runs the async [operation], measures its wall-clock duration, and reports
/// the outcome through the optional hooks, then returns the result (or rethrows
/// the operation's error after [onError]).
///
/// [onSuccess] receives the elapsed time and the result; [onError] receives the
/// elapsed time, the error, and its stack trace. The error is always rethrown
/// so the wrapper is transparent to callers.
///
/// Example:
/// ```dart
/// await observeAsync(
///   () => repository.load(id),
///   onSuccess: (d, _) => log('load ok in ${d.inMilliseconds}ms'),
///   onError: (d, e, _) => log('load failed in ${d.inMilliseconds}ms: $e'),
/// );
/// ```
Future<T> observeAsync<T>(
  Future<T> Function() operation, {
  void Function(Duration elapsed, T result)? onSuccess,
  void Function(Duration elapsed, Object error, StackTrace stackTrace)? onError,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  try {
    final T result = await operation();
    stopwatch.stop();
    onSuccess?.call(stopwatch.elapsed, result);
    return result;
  } on Object catch (error, stackTrace) {
    // Catch-all is intentional: an observability wrapper must time and report
    // EVERY failure mode, then rethrow so it never changes the control flow.
    stopwatch.stop();
    onError?.call(stopwatch.elapsed, error, stackTrace);
    rethrow;
  }
}

/// Synchronous counterpart of [observeAsync]: times [operation], reports the
/// outcome through the optional hooks, and returns the result (or rethrows
/// after [onError]).
T observeSync<T>(
  T Function() operation, {
  void Function(Duration elapsed, T result)? onSuccess,
  void Function(Duration elapsed, Object error, StackTrace stackTrace)? onError,
}) {
  final Stopwatch stopwatch = Stopwatch()..start();
  try {
    final T result = operation();
    stopwatch.stop();
    onSuccess?.call(stopwatch.elapsed, result);
    return result;
  } on Object catch (error, stackTrace) {
    // Catch-all is intentional (see observeAsync): time and report every
    // failure, then rethrow so the wrapper never alters control flow.
    stopwatch.stop();
    onError?.call(stopwatch.elapsed, error, stackTrace);
    rethrow;
  }
}
