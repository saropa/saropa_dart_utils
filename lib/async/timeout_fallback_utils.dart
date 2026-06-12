import 'dart:async';
import 'dart:developer' as dev;

const String _kLogNameTimeoutWithFallback = 'timeoutWithFallback';

/// Timeout with fallback value. Roadmap #179.
/// Audited: 2026-06-12 11:26 EDT
Future<T> timeoutWithFallback<T>({
  required Future<T> future,
  required Duration timeout,
  required T fallback,
}) async {
  try {
    return await future.timeout(timeout);
  } on TimeoutException catch (e) {
    dev.log(
      'Timeout after $timeout; returning fallback.',
      name: _kLogNameTimeoutWithFallback,
      error: e,
    );
    return fallback;
  }
}
