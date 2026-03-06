/// Stream windowing (time- and count-based) — roadmap #660.
library;

import 'dart:async' show Stream, StreamController, StreamSubscription;

/// Buffers [stream] into lists of [count] elements.
Stream<List<T>> windowCount<T>(Stream<T> stream, int count) {
  late StreamController<List<T>> ctrl;
  StreamSubscription<T>? sub;
  List<T> buf = [];
  ctrl = StreamController<List<T>>(
    onListen: () {
      sub = stream.listen(
        (T data) {
          buf.add(data);
          if (buf.length >= count) {
            ctrl.add(List<T>.of(buf));
            buf = [];
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
