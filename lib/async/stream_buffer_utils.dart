/// Stream buffering (bufferCount, bufferTime-style) — roadmap #664.
library;

import 'dart:async' show Stream, StreamController, StreamSubscription;

/// Buffers [stream] into lists of size [count].
Stream<List<T>> bufferCount<T>(Stream<T> stream, int count) {
  late StreamController<List<T>> ctrl;
  StreamSubscription<T>? sub;
  List<T> buf = <T>[];
  ctrl = StreamController<List<T>>(
    onListen: () {
      sub = stream.listen(
        (T data) {
          buf.add(data);
          if (buf.length >= count) {
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
