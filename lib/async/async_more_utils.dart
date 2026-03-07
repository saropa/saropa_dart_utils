import 'dart:async'; // ignore: require_ios_deployment_target_consistency

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:saropa_dart_utils/async/async_semaphore_utils.dart'
    show AsyncAction;

/// Async More: race, allSettled, retry N times. Roadmap #346-348.
Future<T> race<T>(List<Future<T>> futures) => Future.any(futures);

/// Attempts all [futures] and returns results (values or error+stackTrace pairs).
Future<List<Object?>> allSettled<T>(List<Future<T>> futures) async {
  final List<Object?> results = List<Object?>.filled(futures.length, null);
  for (int i = 0; i < futures.length; i++) {
    try {
      final value = await futures[i];
      results[i] = value;
    } on Object catch (e, st) {
      debugPrint('allSettled: $e\n$st');
      results[i] = <Object>[e, st];
    }
  }
  return results;
}

/// Retries [fn] up to [times] attempts; rethrows on final failure.
Future<T> retryTimes<T>(AsyncAction<T> fn, int times) async {
  int attempts = 0;
  while (true) {
    try {
      return await fn();
    } on Object catch (e, st) {
      attempts++;
      if (attempts >= times) {
        debugPrint('retryTimes failed after $times: $e\n$st');
        rethrow;
      }
    }
  }
}
