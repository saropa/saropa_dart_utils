/// Stream buffering (bufferCount, bufferTime-style) — roadmap #664.
library;

import 'dart:async' show Stream, StreamController, StreamSubscription;

/// Buffers [stream] into lists of size [count].
/// Audited: 2026-06-12 11:26 EDT
Stream<List<T>> bufferCount<T>(Stream<T> stream, int count) {
  // A non-positive count would flush a one-element list on every event; treat
  // anything below 1 as a buffer of 1 so the size is at least meaningful.
  final int size = count < 1 ? 1 : count;
  late StreamController<List<T>> ctrl;
  StreamSubscription<T>? sub;
  List<T> buf = <T>[];
  ctrl = StreamController<List<T>>(
    onListen: () {
      sub = stream.listen(
        (T data) {
          buf.add(data);
          if (buf.length >= size) {
            ctrl.add(List<T>.of(buf));
            buf = <T>[];
          }
        },
        onDone: () {
          if (buf.isNotEmpty) ctrl.add(buf);
          ctrl.close();
        },
        onError: ctrl.addError,
      );
    },
    onCancel: () async {
      await sub?.cancel();
    },
  );
  return ctrl.stream;
}
