import 'dart:async';
import 'dart:developer' as dev;

/// Default initial backoff delay.
const Duration _defaultInitialDelay = Duration(milliseconds: 100);

/// Supplier of a single async result.
typedef FutureSupplier<T> = Future<T> Function();

/// Retry with backoff (exponential or linear). Roadmap #178.
Future<T> retryWithBackoff<T>(
  FutureSupplier<T> fn, {
  int maxAttempts = 3,
  Duration initialDelay = _defaultInitialDelay,
  bool isExponential = true,
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await fn();
    } on Object catch (e) {
      dev.log('retry attempt $attempt failed', error: e);
      attempt++;
      if (attempt >= maxAttempts) rethrow;
      final Duration delay = isExponential
          ? Duration(
              milliseconds: initialDelay.inMilliseconds * (1 << (attempt - 1)),
            )
          : Duration(
              milliseconds: initialDelay.inMilliseconds * attempt,
            );
      await Future<void>.delayed(delay);
    }
  }
}
