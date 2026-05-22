/// Race with cancellation (first success wins, cancel rest) — roadmap #667.
library;

import 'dart:async' show Completer, Future, unawaited;

// ignore_for_file: saropa_lints/prefer_await_over_then -- raceFirst deliberately uses .then/.catchError to launch all producers concurrently; awaiting would serialize them and defeat the race

const String _kErrAllFailed = 'All failed';

/// Returns result of first future that completes successfully; others are not cancelled (fire-and-forget).
Future<T> raceFirst<T>(List<Future<T> Function()> producers) {
  final Completer<T> c = Completer<T>();
  int pending = producers.length;
  for (final Future<T> Function() fn in producers) {
    // Launch every producer concurrently and race them: the first success
    // completes the shared completer; later results are dropped. The
    // .then/.catchError chain is deliberate — awaiting would serialize the
    // producers and defeat the race. Failures are counted; the aggregate error
    // surfaces only once the last outstanding producer has also failed.
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
