/// Debounce a stream: emit an item only after a quiet gap. Roadmap #185.
///
/// Where `debounceCallback` (see debounce_utils.dart) wraps a function, this
/// wraps a Stream — the classic use is a search-box value stream where you
/// want to fire the query only once the user pauses typing, not on every
/// keystroke. Only the LATEST value in a burst survives; earlier values in the
/// same window are dropped.
library;

import 'dart:async' show Stream, StreamController, StreamSubscription, Timer;

/// Returns a stream that re-emits values from [source], but suppresses any
/// value that is followed by another within [duration]. Each value resets the
/// timer; the value is forwarded only once [duration] elapses with no newer
/// value.
///
/// If [source] closes while a value is still pending, that final value is
/// emitted immediately before the stream closes — otherwise the last keystroke
/// of a burst would be lost. Errors are forwarded as they arrive (not
/// debounced), so failures surface promptly.
///
/// The returned stream mirrors [source]'s single/broadcast nature is NOT
/// preserved: it is a single-subscription stream. Listen to it once.
///
/// Example:
/// ```dart
/// // Only the last query in each 300ms typing burst reaches the server.
/// debounceStream(queryStream, const Duration(milliseconds: 300))
///     .listen(runSearch);
/// ```
Stream<T> debounceStream<T>(Stream<T> source, Duration duration) =>
    _debounce(source, duration, emitFirstImmediately: false);

/// Shared debounce engine for [debounceStream] and
/// [StreamDebounceExtensions.debounceAfterFirst].
///
/// The controller defers the upstream `listen()` to `onListen` and is
/// single-subscription. This is load-bearing, not incidental: an earlier
/// broadcast-controller version that subscribed to [source] eagerly dropped the
/// first emission whenever the consumer subscribed late (e.g. a `StreamBuilder`
/// inside a visibility-gated panel), leaving the UI stuck in
/// `ConnectionState.waiting` forever. Deferring the upstream listen until a
/// consumer actually attaches guarantees the late subscriber still sees the
/// first value. Do not switch this to a broadcast controller or an eager
/// `source.listen`.
///
/// When [emitFirstImmediately] is `true`, the very first value from [source] is
/// forwarded the instant it arrives and only subsequent values are debounced —
/// the correct shape for a `.watch()` stream that emits current state on
/// subscribe (Drift; Isar's `fireImmediately: true`), where the initial render
/// must be instant but bulk writes should coalesce.
Stream<T> _debounce<T>(
  Stream<T> source,
  Duration duration, {
  required bool emitFirstImmediately,
}) {
  late StreamController<T> controller;
  StreamSubscription<T>? subscription;
  Timer? timer;
  bool hasPending = false;
  bool firstSeen = false;
  late T pending;

  void emitPending() {
    if (hasPending) {
      hasPending = false;
      controller.add(pending);
    }
  }

  controller = StreamController<T>(
    onListen: () {
      subscription = source.listen(
        (T value) {
          // Emit the leading value instantly when configured, so a watch-style
          // stream renders current state without waiting out the quiet gap.
          if (emitFirstImmediately && !firstSeen) {
            firstSeen = true;
            controller.add(value);
            return;
          }

          // Remember the newest value and restart the quiet-gap timer; any
          // prior pending value in this burst is intentionally discarded.
          pending = value;
          hasPending = true;
          timer?.cancel();
          timer = Timer(duration, emitPending);
        },
        // Flush the trailing value before closing so a burst's last item is
        // not silently dropped when the source ends mid-window.
        onDone: () {
          timer?.cancel();
          emitPending();
          controller.close();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      timer?.cancel();
      await subscription?.cancel();
    },
  );
  return controller.stream;
}

/// Chainable debounce variants on any [Stream], so reactive pipelines read as
/// `stream.debounce(d).map(...)` instead of wrapping with the free function.
extension StreamDebounceExtensions<T> on Stream<T> {
  /// Debounces this stream: see [debounceStream]. Only the latest value of each
  /// [duration]-bounded burst survives.
  ///
  /// Single-subscription; listen once. A late subscriber still receives the
  /// first value (the upstream listen is deferred until subscription).
  Stream<T> debounce(Duration duration) => debounceStream(this, duration);

  /// Debounces this stream AND suppresses consecutive equal values.
  ///
  /// Debounce runs first (so only the surviving value of each burst is tested),
  /// then `distinct` drops it if it equals the previously emitted value. Pass
  /// [equals] for a custom equality; otherwise `==` is used. Useful for a watch
  /// stream that re-emits identical snapshots after unrelated writes.
  Stream<T> debounceDistinct(
    Duration duration, {
    bool Function(T previous, T next)? equals,
  }) => debounceStream(this, duration).distinct(equals);

  /// Emits the FIRST value immediately, then debounces the rest by [duration].
  ///
  /// The right shape for a database `.watch()` stream that emits current state
  /// on subscribe: the initial render is instant, while a following burst of
  /// writes is coalesced to its last value. Single-subscription; the late
  /// subscriber still gets that first value.
  Stream<T> debounceAfterFirst(Duration duration) =>
      _debounce(this, duration, emitFirstImmediately: true);
}
