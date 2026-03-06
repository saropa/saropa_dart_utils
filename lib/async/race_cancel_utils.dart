/// Race with cancellation (first success wins, cancel rest) — roadmap #667.
library;

import 'dart:async'
    show Completer, Future, unawaited; // ignore: require_ios_deployment_target_consistency

const String _kErrAllFailed = 'All failed';

/// Returns result of first future that completes successfully; others are not cancelled (fire-and-forget).
Future<T> raceFirst<T>(List<Future<T> Function()> producers) {
  final Completer<T> c = Completer<T>();
  int pending = producers.length;
  for (final Future<T> Function() fn in producers) {
    unawaited(
      fn()
          .then((T v) {
            if (!c.isCompleted) c.complete(v);
          })
          .catchError((Object _, StackTrace st) {
            pending--;
            if (pending == 0 && !c.isCompleted) {
              c.completeError(StateError(_kErrAllFailed), st);
            }
          }),
    );
  }
  return c.future;
}
