/// Async timeout with fallback — roadmap #669.
library;

import 'dart:async' show Future, TimeoutException;
import 'dart:developer' as developer;

/// Runs [fn] with [timeout]; on timeout returns [fallback] or rethrows.
Future<T> withTimeout<T>(Future<T> Function() fn, Duration timeout, {T? fallback}) async {
  try {
    return await fn().timeout(timeout);
  } on TimeoutException catch (e) {
    if (fallback != null) return fallback;
    developer.log('Timeout after $timeout', name: 'withTimeout', error: e);
    rethrow;
  }
}
