/// Timebox: run within time budget — roadmap #618.
library;

import 'dart:async'
    show Future, Completer, Timer; // ignore: require_ios_deployment_target_consistency
import 'dart:developer' as developer;

const String _kTimeboxExceeded = 'Timebox exceeded';

/// Runs [fn]; if not completed in [timeout], returns [onTimeout] result (or throws).
Future<T> timebox<T>(Future<T> Function() fn, Duration timeout, {T? onTimeout}) async {
  final Completer<T> c = Completer<T>();
  Timer? t;
  t = Timer(timeout, () {
    if (!c.isCompleted) {
      if (onTimeout != null)
        c.complete(onTimeout);
      else
        c.completeError(TimeboxException(_kTimeboxExceeded), StackTrace.current);
    }
  });
  try {
    final T result = await fn();
    if (!c.isCompleted) c.complete(result);
    return await c.future;
  } on Object catch (e, st) {
    developer.log('Timebox caught error', name: 'timebox', error: e, stackTrace: st);
    if (!c.isCompleted) c.completeError(e, st);
    rethrow;
  } finally {
    t.cancel();
  }
}

/// Thrown when [timebox] exceeds the allowed duration and no [onTimeout] was provided.
class TimeboxException implements Exception {
  TimeboxException(String message) : _message = message;
  final String _message;

  /// Description of the timeout.
  String get message => _message;

  @override
  String toString() => 'TimeboxException($_message)';
}
