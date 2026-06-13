/// Async timeout with fallback — roadmap #669.
library;

import 'dart:async' show Future, TimeoutException;
import 'dart:developer' as developer;

/// Runs [fn] with [timeout]; on timeout returns [fallback], or rethrows the
/// [TimeoutException] when no fallback was supplied.
///
/// Limitation: a non-null [fallback] is required to recover. Because the
/// parameter is `T?` defaulting to null, a null is read as "no fallback" — so
/// for a nullable `T` you cannot use `null` itself as the recovery value (it
/// rethrows instead). Use [timeout_fallback_utils] (required non-null fallback)
/// when `T` is non-nullable, or wrap the value if you genuinely need a null
/// fallback.
/// Audited: 2026-06-12 11:26 EDT
Future<T> withTimeout<T>(Future<T> Function() fn, Duration timeout, {T? fallback}) async {
  try {
    return await fn().timeout(timeout);
  } on TimeoutException catch (e) {
    if (fallback != null) return fallback;
    developer.log('Timeout after $timeout', name: 'withTimeout', error: e);
    rethrow;
  }
}
