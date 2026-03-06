import 'dart:async'; // ignore: require_ios_deployment_target_consistency

import 'package:flutter/foundation.dart' show debugPrint;

/// Async More: race, allSettled, retry N times. Roadmap #346-348.
Future<T> race<T>(List<Future<T>> futures) => Future.any(futures);

Future<List<Object?>> allSettled<T>(List<Future<T>> futures) async {
  final List<Object?> results = <Object?>[];
  for (final Future<T> f in futures) {
    try {
      results.add(await f);
    } on Object catch (e, st) {
      debugPrint('allSettled: $e\n$st');
      results.add(<Object>[e, st]);
    }
  }
  return results;
}

Future<T> retryTimes<T>(Future<T> Function() fn, int times) async {
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
