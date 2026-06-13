import 'dart:async';
import 'dart:developer' as dev;

import 'package:saropa_dart_utils/async/async_semaphore_utils.dart' show AsyncAction;

/// Default initial backoff delay.
/// Audited: 2026-06-12 11:26 EDT
const Duration _defaultInitialDelay = Duration(milliseconds: 100);

/// Retry with backoff (exponential or linear). Roadmap #178.
/// Audited: 2026-06-12 11:26 EDT
Future<T> retryWithBackoff<T>(
  AsyncAction<T> fn, {
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
              // Clamp the shift to 30 (matching exponential_backoff_utils /
              // retry_policy_utils): an unclamped `1 << (attempt-1)` overflows the
              // web's 32-bit shift at high attempt counts and yields a wrong
              // (small/negative) delay.
              milliseconds: initialDelay.inMilliseconds * (1 << (attempt - 1).clamp(0, 30)),
            )
          : Duration(
              milliseconds: initialDelay.inMilliseconds * attempt,
            );
      await Future<void>.delayed(delay);
    }
  }
}
