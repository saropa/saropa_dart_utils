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
      final Future<void> drained = debounceStream(
        source.stream,
        const Duration(milliseconds: 100),
      ).forEach(results.add);

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
      final StreamSubscription<int> sub = debounceStream(
        source.stream,
        const Duration(milliseconds: 100),
      ).listen((_) {}, onError: errors.add);

      source.addError(StateError('boom'));
      // Errors are forwarded immediately, not held for the debounce window.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(errors, hasLength(1));

      await sub.cancel();
      await source.close();
    });
  });

  group('StreamDebounceExtensions', () {
    test('debounce() matches the free function (latest of a burst)', () {
      fakeAsync((FakeAsync async) {
        final StreamController<int> source = StreamController<int>();
        final List<int> results = <int>[];
        source.stream.debounce(const Duration(milliseconds: 100)).listen(results.add);

        source
          ..add(1)
          ..add(2)
          ..add(3);
        async.elapse(const Duration(milliseconds: 100));
        expect(results, <int>[3]);

        source.close();
        async.flushMicrotasks();
      });
    });

    // The documented production bug-fix: a consumer that subscribes AFTER the
    // source already has a value queued must still receive that first value.
    // The deferred-listen single-subscription controller guarantees this.
    test('late subscriber still receives the first emission', () async {
      final StreamController<int> source = StreamController<int>();
      final Stream<int> debounced = source.stream.debounce(
        const Duration(milliseconds: 50),
      );

      // Value is added to the source before anyone listens to the debounced
      // stream. Because the upstream listen is deferred to onListen, nothing is
      // consumed yet, so the value is not lost.
      source.add(99);

      final List<int> results = <int>[];
      final Future<void> drained = debounced.forEach(results.add);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await source.close();
      await drained;

      expect(results, <int>[99]);
    });

    group('debounceAfterFirst', () {
      test('emits the first value immediately, then coalesces the burst', () {
        fakeAsync((FakeAsync async) {
          final StreamController<int> source = StreamController<int>();
          final List<int> results = <int>[];
          source.stream
              .debounceAfterFirst(const Duration(milliseconds: 100))
              .listen(results.add);

          // First value is forwarded instantly, before any quiet gap.
          source.add(1);
          async.flushMicrotasks();
          expect(results, <int>[1]);

          // A following burst is debounced to its last value.
          source
            ..add(2)
            ..add(3)
            ..add(4);
          async.elapse(const Duration(milliseconds: 100));
          expect(results, <int>[1, 4]);

          source.close();
          async.flushMicrotasks();
        });
      });

      test('flushes a trailing pending value when the source closes early', () async {
        final StreamController<int> source = StreamController<int>();
        final List<int> results = <int>[];
        final Future<void> drained = source.stream
            .debounceAfterFirst(const Duration(milliseconds: 100))
            .forEach(results.add);

        source
          ..add(1) // emitted immediately
          ..add(2); // pending in the debounce window
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await source.close();
        await drained;

        expect(results, <int>[1, 2]);
      });
    });

    group('debounceDistinct', () {
      test('suppresses an equal value that survives debouncing', () {
        fakeAsync((FakeAsync async) {
          final StreamController<int> source = StreamController<int>();
          final List<int> results = <int>[];
          source.stream
              .debounceDistinct(const Duration(milliseconds: 30))
              .listen(results.add);

          source.add(5);
          async.elapse(const Duration(milliseconds: 40));
          // Same value again after a gap -> debounced through, then dropped by
          // distinct because it equals the previously emitted 5.
          source.add(5);
          async.elapse(const Duration(milliseconds: 40));
          source.add(6);
          async.elapse(const Duration(milliseconds: 40));
          expect(results, <int>[5, 6]);

          source.close();
          async.flushMicrotasks();
        });
      });

      test('honors a custom equals', () {
        fakeAsync((FakeAsync async) {
          final StreamController<String> source = StreamController<String>();
          final List<String> results = <String>[];
          // Case-insensitive equality: 'A' and 'a' are treated as duplicates.
          source.stream
              .debounceDistinct(
                const Duration(milliseconds: 30),
                equals: (String a, String b) => a.toLowerCase() == b.toLowerCase(),
              )
              .listen(results.add);

          source.add('A');
          async.elapse(const Duration(milliseconds: 40));
          source.add('a');
          async.elapse(const Duration(milliseconds: 40));
          source.add('B');
          async.elapse(const Duration(milliseconds: 40));
          expect(results, <String>['A', 'B']);

          source.close();
          async.flushMicrotasks();
        });
      });
    });
  });
}
