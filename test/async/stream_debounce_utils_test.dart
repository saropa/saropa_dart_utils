import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/stream_debounce_utils.dart';

void main() {
  group('debounceStream', () {
    // Timing behavior uses fakeAsync for deterministic virtual time.
    test('emits only the latest value of a burst after the quiet gap', () {
      fakeAsync((FakeAsync async) {
        final StreamController<int> source = StreamController<int>();
        final List<int> results = <int>[];
        debounceStream(source.stream, const Duration(milliseconds: 100)).listen(results.add);

        source
          ..add(1)
          ..add(2)
          ..add(3);
        async.flushMicrotasks();
        // Mid-window: nothing emitted yet because the timer keeps resetting.
        async.elapse(const Duration(milliseconds: 50));
        expect(results, isEmpty);

        // 100ms of silence after the last value -> the latest (3) is emitted.
        async.elapse(const Duration(milliseconds: 100));
        expect(results, <int>[3]);

        source.close();
        async.flushMicrotasks();
      });
    });

    test('values separated by more than the gap each emit', () {
      fakeAsync((FakeAsync async) {
        final StreamController<int> source = StreamController<int>();
        final List<int> results = <int>[];
        debounceStream(source.stream, const Duration(milliseconds: 30)).listen(results.add);

        source.add(1);
        async.elapse(const Duration(milliseconds: 40));
        source.add(2);
        async.elapse(const Duration(milliseconds: 40));
        expect(results, <int>[1, 2]);

        source.close();
        async.flushMicrotasks();
      });
    });

    // Close/done propagation uses the real event loop: a StreamController
    // closed from inside a source's onDone does not surface its done event
    // under fakeAsync, but does under real async (verified behavior).
    test('flushes the trailing pending value when the source closes early', () async {
      final StreamController<int> source = StreamController<int>();
      final List<int> results = <int>[];
      final Future<void> drained =
          debounceStream(source.stream, const Duration(milliseconds: 100)).forEach(results.add);

      source.add(7);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      // Close before the debounce window elapses.
      await source.close();
      // drained completes only when the debounced stream itself closes, which
      // proves the done event propagated after the trailing value.
      await drained;

      expect(results, <int>[7]);
    });

    test('forwards errors without debouncing them', () async {
      final StreamController<int> source = StreamController<int>();
      final List<Object> errors = <Object>[];
      final StreamSubscription<int> sub =
          debounceStream(source.stream, const Duration(milliseconds: 100))
              .listen((_) {}, onError: errors.add);

      source.addError(StateError('boom'));
      // Errors are forwarded immediately, not held for the debounce window.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(errors, hasLength(1));

      await sub.cancel();
      await source.close();
    });
  });
}
