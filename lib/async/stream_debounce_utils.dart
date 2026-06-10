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
Stream<T> debounceStream<T>(Stream<T> source, Duration duration) {
  late StreamController<T> controller;
  StreamSubscription<T>? subscription;
  Timer? timer;
  bool hasPending = false;
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
