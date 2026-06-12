/// Retry policy (fixed, backoff, jitter) — roadmap #656.
library;

import 'dart:async' show Future;
import 'dart:developer' show log;
import 'dart:math' show Random;

/// Default delay between retry attempts.
/// Audited: 2026-06-12 11:26 EDT
const Duration retryPolicyDefaultDelay = Duration(milliseconds: 100);

/// Default base delay for exponential backoff in [retryWithJitter].
/// Audited: 2026-06-12 11:26 EDT
const Duration retryPolicyDefaultBackoffBase = Duration(milliseconds: 100);

/// Default jitter range for [retryWithJitter].
/// Audited: 2026-06-12 11:26 EDT
const Duration retryPolicyDefaultBackoffJitter = Duration(milliseconds: 50);

/// Retries [fn] up to [maxAttempts] with [delay] between attempts.
///
/// [retryIf] decides whether a given error is even worth retrying: when it
/// returns `false` the error is rethrown immediately, without consuming the
/// remaining attempts or waiting [delay]. This is how you retry only transient
/// failures (a timeout, a 503) and fail fast on permanent ones (a 400, an
/// `ArgumentError`). When [retryIf] is `null` (default) every error is retried.
///
/// [onRetry] is invoked after each failed attempt that will be retried, with
/// the error and the 1-based attempt number — useful for logging or metrics. It
/// does NOT fire on the final attempt (which rethrows) or on a [retryIf]-vetoed
/// error.
/// Audited: 2026-06-12 11:26 EDT
Future<T> retryWithPolicy<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = retryPolicyDefaultDelay,
  bool Function(Object error)? retryIf,
  void Function(Object error, int attempt)? onRetry,
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await fn();
    } on Object catch (e, st) {
      log('retryWithPolicy attempt $attempt', error: e);
      attempt++;
      // Non-retryable error: surface it now rather than burning attempts and
      // delaying on something that will never succeed.
      // ignore: saropa_lints/avoid_ignoring_return_values -- throwWithStackTrace returns Never; there is no value to capture
      if (retryIf != null && !retryIf(e)) Error.throwWithStackTrace(e, st);
      // ignore: saropa_lints/avoid_ignoring_return_values -- throwWithStackTrace returns Never; there is no value to capture
      if (attempt >= maxAttempts) Error.throwWithStackTrace(e, st);
      onRetry?.call(e, attempt);
      await Future<void>.delayed(delay);
    }
  }
}

/// Exponential backoff with jitter: delay = base * 2^attempt + random(0, jitter).
/// Audited: 2026-06-12 11:26 EDT
Future<T> retryWithJitter<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration base = retryPolicyDefaultBackoffBase,
  Duration jitter = retryPolicyDefaultBackoffJitter,
  Random? random,
}) async {
  final Random r = random ?? Random();
  int attempt = 0;
  while (true) {
    try {
      return await fn();
    } on Object catch (e, st) {
      log('retryWithJitter attempt $attempt', error: e);
      attempt++;
      // ignore: saropa_lints/avoid_ignoring_return_values -- throwWithStackTrace returns Never; there is no value to capture
      if (attempt >= maxAttempts) Error.throwWithStackTrace(e, st);
      // Clamp the shift so a large maxAttempts cannot overflow `1 << attempt`,
      // and guard a zero jitter: nextInt(0) throws RangeError, so a caller
      // asking for no jitter (Duration.zero) must add nothing instead.
      final int backoff = base.inMilliseconds * (1 << attempt.clamp(0, 30));
      final int jitterMs = jitter.inMilliseconds;
      final int ms = backoff + (jitterMs > 0 ? r.nextInt(jitterMs) : 0);
      await Future<void>.delayed(Duration(milliseconds: ms));
    }
  }
}
