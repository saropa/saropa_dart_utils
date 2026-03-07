/// Retry policy (fixed, backoff, jitter) — roadmap #656.
library;

import 'dart:async' show Future; // ignore: require_ios_deployment_target_consistency
import 'dart:developer' show log;
import 'dart:math' show Random;

/// Default delay between retry attempts.
const Duration retryPolicyDefaultDelay = Duration(milliseconds: 100);

/// Default base delay for exponential backoff in [retryWithJitter].
const Duration retryPolicyDefaultBackoffBase = Duration(milliseconds: 100);

/// Default jitter range for [retryWithJitter].
const Duration retryPolicyDefaultBackoffJitter = Duration(milliseconds: 50);

/// Retries [fn] up to [maxAttempts] with [delay] between attempts. Optional [onRetry].
Future<T> retryWithPolicy<T>(
  Future<T> Function() fn, {
  int maxAttempts = 3,
  Duration delay = retryPolicyDefaultDelay,
  void Function(Object error, int attempt)? onRetry,
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await fn();
    } on Object catch (e, st) {
      log('retryWithPolicy attempt $attempt', error: e);
      attempt++;
      if (attempt >= maxAttempts) Error.throwWithStackTrace(e, st);
      onRetry?.call(e, attempt);
      await Future<void>.delayed(delay);
    }
  }
}

/// Exponential backoff with jitter: delay = base * 2^attempt + random(0, jitter).
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
      if (attempt >= maxAttempts) Error.throwWithStackTrace(e, st);
      final int ms = base.inMilliseconds * (1 << attempt) + r.nextInt(jitter.inMilliseconds);
      await Future<void>.delayed(Duration(milliseconds: ms));
    }
  }
}
