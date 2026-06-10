/// Stream join/zip/combineLatest operators — roadmap #661.
library;

import 'dart:async';

/// Pairs [a] and [b] by index, emitting `combine(aᵢ, bᵢ)` for each index until
/// either stream completes (the standard "zip" operator).
///
/// Unlike [combineLatestStreams], a value is consumed from BOTH streams before
/// each emission, so the two streams advance in lock-step. A trailing value
/// from the longer stream that has no partner is dropped. Both source
/// subscriptions are cancelled when the result stream is done or cancelled.
///
/// Example:
/// ```dart
/// zipStreams(Stream.fromIterable([1, 2, 3]),
///            Stream.fromIterable(['a', 'b']),
///            (int n, String s) => '$n$s'); // 1a, 2b
/// ```
Stream<R> zipStreams<A, B, R>(Stream<A> a, Stream<B> b, R Function(A, B) combine) async* {
  final StreamIterator<A> ia = StreamIterator<A>(a);
  final StreamIterator<B> ib = StreamIterator<B>(b);
  try {
    // moveNext is awaited for BOTH before yielding, so a half-pair at the end
    // (one stream still has a value, the other is exhausted) is never emitted.
    while (await ia.moveNext() && await ib.moveNext()) {
      yield combine(ia.current, ib.current);
    }
  } finally {
    await ia.cancel();
    await ib.cancel();
  }
}

/// Emits `combine(latestA, latestB)` whenever EITHER [a] or [b] emits, but only
/// once both have produced at least one value (the standard "combineLatest").
///
/// The result stream errors-forward from either source and completes when BOTH
/// sources have completed. Source subscriptions start when the result stream is
/// first listened to (not eagerly) and are cancelled on cancel, so no events
/// are buffered before a listener exists.
///
/// Example:
/// ```dart
/// // a: 1 .. 2 ..      b: .. x .. y
/// // emits: 1x, 2x, 2y
/// ```
Stream<R> combineLatestStreams<A, B, R>(Stream<A> a, Stream<B> b, R Function(A, B) combine) {
  late final StreamController<R> controller;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  // A holder cell preserves each value's real type (so combine takes A/B with
  // no cast) and doubles as the "have we seen one yet?" flag via null.
  _Cell<A>? cellA;
  _Cell<B>? cellB;
  int openCount = 2;

  void emit() {
    final _Cell<A>? ca = cellA;
    final _Cell<B>? cb = cellB;
    // Hold emission until BOTH sides have produced a value at least once.
    if (ca != null && cb != null) controller.add(combine(ca.value, cb.value));
  }

  void onSourceDone() {
    // The controller-close Future is intentionally not awaited; errors while
    // closing are not actionable here, and unawaited documents the intent.
    if (--openCount == 0) unawaited(controller.close());
  }

  controller = StreamController<R>(
    onListen: () {
      subA = a.listen(
        (A v) {
          cellA = _Cell<A>(v);
          emit();
        },
        onError: controller.addError,
        onDone: onSourceDone,
      );
      subB = b.listen(
        (B v) {
          cellB = _Cell<B>(v);
          emit();
        },
        onError: controller.addError,
        onDone: onSourceDone,
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );
  return controller.stream;
}

/// Single-value holder that keeps a stream's latest value at its real static
/// type, so a downstream combine never needs an `as` cast and a null cell
/// cleanly means "no value yet".
class _Cell<T> {
  _Cell(this.value);

  final T value;
}
