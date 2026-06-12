import 'dart:async'; // ignore: require_ios_deployment_target_consistency

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:saropa_dart_utils/async/async_semaphore_utils.dart' show AsyncAction;

/// Async More: race, allSettled, retry N times. Roadmap #346-348.
/// Audited: 2026-06-12 11:26 EDT
Future<T> race<T>(List<Future<T>> futures) => Future.any(futures);

/// Attempts all [futures] and returns results
/// (values or error+stackTrace pairs).
/// Audited: 2026-06-12 11:26 EDT
Future<List<Object?>> allSettled<T>(
  List<Future<T>> futures,
) async {
  final List<Object?> results = List<Object?>.filled(futures.length, null);

  for (final (i, future) in futures.indexed) {
    try {
      final value = await future;

      results[i] = value;
    } on Object catch (e, st) {
      // ignore: saropa_lints/avoid_print_error, saropa_lints/avoid_debug_print -- intentional diagnostic logging; debugPrint is stripped in release builds. Error + stack are also returned to the caller in results.
      debugPrint('allSettled: $e\n$st');
      results[i] = <Object>[e, st];
    }
  }

  return results;
}

/// Retries [fn] up to [times] attempts;
/// rethrows on final failure.
/// Audited: 2026-06-12 11:26 EDT
Future<T> retryTimes<T>(
  AsyncAction<T> fn,
  int times,
) async {
  // At least one attempt: a non-positive `times` would otherwise rethrow on the
  // first failure (0 retries) yet still run fn once — clamp so the count is sane.
  final int maxAttempts = times < 1 ? 1 : times;
  int attempts = 0;

  while (true) {
    try {
      return await fn();
    } on Object catch (e, st) {
      attempts++;
      if (attempts >= maxAttempts) {
        // ignore: saropa_lints/avoid_print_error, saropa_lints/avoid_debug_print -- intentional diagnostic logging; debugPrint is stripped in release builds. The error is rethrown to the caller below.
        debugPrint(
          'retryTimes failed after $times: $e\n$st',
        );
        rethrow;
      }
    }
  }
}
