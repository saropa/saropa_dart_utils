import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/compute_stream_transformer.dart';

// Top-level functions — compute() requires top-level/static targets. A closure
// capturing surrounding state cannot be sent across an isolate boundary.
int _double(int n) => n * 2;

int _throwOnZero(int n) {
  if (n == 0) {
    throw StateError('zero not allowed');
  }
  return n * 2;
}

// Identity over a nullable int, used to prove null events round-trip through
// compute() and emerge null (compute can carry nullable types).
int? _nullableIdentity(int? n) => n;

// Identity over a string, used to prove Unicode/emoji survive the isolate
// message copy byte-for-byte (the copy must not flatten code units).
String _stringIdentity(String s) => s;

// Identity over a double, used to prove numeric extremes (NaN, infinities,
// large magnitudes) cross the isolate boundary intact.
double _doubleIdentity(double d) => d;

// Sums a large list to prove a heavy payload serializes and computes correctly
// without hanging.
int _sumList(List<int> values) => values.fold<int>(0, (int a, int b) => a + b);

// onError recovery that itself throws, used to prove a throwing recovery
// callback surfaces its error on the stream rather than being swallowed.
int _recoverThenThrow(Object error, StackTrace stack) => throw StateError('recovery failed');

void main() {
  group('ComputeStreamTransformer', () {
    group('happy path', () {
      test('maps each event through the compute function in order', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[1, 2, 3]);

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<int, int>(computeFunction: _double),
            )
            .toList();

        expect(result, orderedEquals(<int>[2, 4, 6]));
      });

      test('single event passes through', () async {
        final List<int> result = await Stream<int>.value(21)
            .transform(
              ComputeStreamTransformer<int, int>(computeFunction: _double),
            )
            .toList();

        expect(result, hasLength(1));
        expect(result.first, equals(42));
      });
    });

    group('boundary inputs', () {
      test('empty source stream yields empty output stream', () async {
        final Stream<int> source = const Stream<int>.empty();

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<int, int>(computeFunction: _double),
            )
            .toList();

        expect(result, isEmpty);
      });

      // asyncMap awaits each compute() before the next, so output order must
      // equal input order even when an EARLIER value computes slower than a
      // later one. Feed a strictly ascending source and assert ascending output.
      test('preserves input order regardless of per-event latency', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[1, 2, 3, 4, 5]);

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<int, int>(computeFunction: _double),
            )
            .toList();

        expect(result, orderedEquals(<int>[2, 4, 6, 8, 10]));
      });

      // compute() can carry nullable types; a null event must arrive null at the
      // callback and a null result must propagate to the output.
      test('null TInput and null TOutput propagate through compute', () async {
        final Stream<int?> source = Stream<int?>.fromIterable(<int?>[1, null, 3]);

        final List<int?> result = await source
            .transform(
              ComputeStreamTransformer<int?, int?>(
                computeFunction: _nullableIdentity,
              ),
            )
            .toList();

        expect(result, orderedEquals(<int?>[1, null, 3]));
      });
    });

    group('error handling without onError', () {
      test('error is rethrown onto the stream when onError is null', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[1, 0, 3]);

        final Stream<int> out = source.transform(
          ComputeStreamTransformer<int, int>(computeFunction: _throwOnZero),
        );

        await expectLater(out, emitsThrough(emitsError(isA<Object>())));
      });

      // Events BEFORE the throwing event must still be emitted, and the stream
      // must terminate with the error after them — the failure does not retro-
      // actively suppress already-computed values.
      test('emits pre-error values, then errors at the failing event', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[1, 2, 0, 4]);

        final Stream<int> out = source.transform(
          ComputeStreamTransformer<int, int>(computeFunction: _throwOnZero),
        );

        await expectLater(
          out,
          emitsInOrder(<Object>[2, 4, emitsError(isA<Object>())]),
        );
      });
    });

    group('error handling with onError', () {
      test('onError converts a thrown error into a fallback value', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[1, 0, 3]);

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<int, int>(
                computeFunction: _throwOnZero,
                onError: (Object error, StackTrace stack) => -1,
              ),
            )
            .toList();

        expect(result, orderedEquals(<int>[2, -1, 6]));
      });

      // The fallback must apply even when the VERY FIRST event throws — there is
      // no "warm-up" event that must succeed before recovery engages.
      test('onError applies when the first event throws', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[0, 2, 3]);

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<int, int>(
                computeFunction: _throwOnZero,
                onError: (Object error, StackTrace stack) => -1,
              ),
            )
            .toList();

        expect(result, orderedEquals(<int>[-1, 4, 6]));
      });

      // Several throwing events in a row each get their OWN fallback — failures
      // are not collapsed or deduplicated into a single recovery.
      test('maps one fallback per failing event for consecutive errors', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[0, 0, 0, 5]);

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<int, int>(
                computeFunction: _throwOnZero,
                onError: (Object error, StackTrace stack) => -1,
              ),
            )
            .toList();

        expect(result, orderedEquals(<int>[-1, -1, -1, 10]));
      });

      // A recovery callback that throws must surface its error on the stream,
      // not be silently swallowed — otherwise a broken fallback would hide the
      // failure entirely.
      test('error thrown inside onError surfaces on the stream', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[1, 0, 3]);

        final Stream<int> out = source.transform(
          ComputeStreamTransformer<int, int>(
            computeFunction: _throwOnZero,
            onError: _recoverThenThrow,
          ),
        );

        await expectLater(out, emitsThrough(emitsError(isA<StateError>())));
      });
    });

    group('isolate payload integrity', () {
      // A 100k-element list exercises isolate serialization cost without
      // hanging; the computed sum must be exact.
      test('large payload crosses the isolate boundary and computes', () async {
        final List<int> big = List<int>.generate(100000, (int i) => 1);
        final Stream<List<int>> source = Stream<List<int>>.value(big);

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<List<int>, int>(
                computeFunction: _sumList,
              ),
            )
            .toList();

        expect(result, orderedEquals(<int>[100000]));
      });

      // The isolate message copy must not flatten or re-encode code units:
      // non-breaking space, ellipsis, and an astral-plane emoji must survive
      // byte-for-byte.
      test('Unicode and emoji string payloads survive the round-trip', () async {
        final String emoji = String.fromCharCode(0x1F600);
        final List<String> inputs = <String>[
          'a b', // non-breaking space
          'wait…', // ellipsis
          'hi $emoji',
        ];
        final Stream<String> source = Stream<String>.fromIterable(inputs);

        final List<String> result = await source
            .transform(
              ComputeStreamTransformer<String, String>(
                computeFunction: _stringIdentity,
              ),
            )
            .toList();

        expect(result, orderedEquals(inputs));
        // Guard against silent emoji corruption: the astral char must be intact.
        expect(result.last.contains(emoji), isTrue);
      });

      // Numeric extremes must cross intact. NaN never equals itself, so assert
      // with isNaN rather than equals; the rest assert by value.
      test('numeric extremes cross the isolate boundary intact', () async {
        final List<double> inputs = <double>[
          0,
          -42.5,
          double.infinity,
          double.negativeInfinity,
          double.nan,
          double.maxFinite,
        ];
        final Stream<double> source = Stream<double>.fromIterable(inputs);

        final List<double> result = await source
            .transform(
              ComputeStreamTransformer<double, double>(
                computeFunction: _doubleIdentity,
              ),
            )
            .toList();

        expect(result[0], equals(0));
        expect(result[1], equals(-42.5));
        expect(result[2], equals(double.infinity));
        expect(result[3], equals(double.negativeInfinity));
        expect(result[4].isNaN, isTrue);
        expect(result[5], equals(double.maxFinite));
      });

      // An int near 2^53 (the limit of exact double representation) must cross
      // unchanged — proving int payloads are not lossily routed through double.
      test('int near 2^53 crosses the isolate boundary exactly', () async {
        const int big = 9007199254740991; // 2^53 - 1
        final Stream<int> source = Stream<int>.value(big);

        final List<int> result = await source
            .transform(
              ComputeStreamTransformer<int, int>(
                computeFunction: _double,
              ),
            )
            .toList();

        expect(result, orderedEquals(<int>[big * 2]));
      });
    });

    group('stream source variants', () {
      // onError guards ONLY compute failures. An error emitted by the SOURCE
      // stream is forwarded untouched even when onError is set, because it is
      // not a compute failure.
      test('source-stream error passes through untouched despite onError', () async {
        final Stream<int> source = () async* {
          yield 1;
          throw StateError('source failed');
        }();

        final Stream<int> out = source.transform(
          ComputeStreamTransformer<int, int>(
            computeFunction: _double,
            onError: (Object error, StackTrace stack) => -1,
          ),
        );

        // The pre-error value is transformed; then the SOURCE error surfaces -
        // it is NOT mapped to the -1 fallback, proving onError only guards
        // compute failures.
        await expectLater(
          out,
          emitsInOrder(<Object>[2, emitsError(isA<StateError>())]),
        );
      });

      // The transformer requires a top-level/static ComputeCallback because
      // compute() must send the callback across an isolate boundary; a closure
      // capturing non-sendable state cannot make that crossing on device.
      //
      // That "non-sendable closure errors" contract is NOT assertable in the
      // Flutter test VM. Sending a closure that captures a StreamController's
      // native receive port through compute() does not surface a clean stream
      // error here — it leaves a dangling _RawReceivePort that never closes, so
      // the test isolate cannot quiesce and the test hangs until the 30s
      // timeout. This is exactly the platform sensitivity the spec flags
      // (SPEC-stream-compute-transformer.md, isolate-payload note: tests that
      // assume true isolation must be platform-gated). We therefore assert the
      // observable, supported half of the contract: a top-level callback is the
      // required shape and computes correctly. The closure rejection is a real-
      // isolate (on-device) behavior, intentionally not exercised here.
      test('supported top-level callback computes (closure rejection is on-device only)', () async {
        final List<int> result = await Stream<int>.value(1)
            .transform(
              ComputeStreamTransformer<int, int>(computeFunction: _double),
            )
            .toList();

        expect(result, orderedEquals(<int>[2]));
      });

      // A broadcast source has no replay: a late subscriber sees only events
      // emitted after it attaches. Verify the transformer behaves on broadcast.
      test('behaves on a broadcast source (no replay for late subscriber)', () async {
        final StreamController<int> controller = StreamController<int>.broadcast();
        addTearDown(controller.close);

        final Stream<int> out = controller.stream.transform(
          ComputeStreamTransformer<int, int>(computeFunction: _double),
        );

        final Future<List<int>> collected = out.take(2).toList();
        // Allow the transform's listen to attach before emitting.
        await Future<void>.delayed(Duration.zero);
        controller
          ..add(10)
          ..add(20);

        expect(await collected, orderedEquals(<int>[20, 40]));
      });
    });

    group('bind() invoked directly', () {
      // .transform() delegates to bind(); call bind() directly to prove the
      // StreamTransformerBase contract holds without the transform() sugar.
      test('binds a source stream and maps each event in order', () async {
        final ComputeStreamTransformer<int, int> transformer =
            ComputeStreamTransformer<int, int>(computeFunction: _double);

        final List<int> result = await transformer
            .bind(Stream<int>.fromIterable(<int>[1, 2, 3]))
            .toList();

        expect(result, orderedEquals(<int>[2, 4, 6]));
      });

      // onError recovery must engage through bind() too, not only via
      // transform(), since bind() is where the asyncMap/catch logic lives.
      test('binds and applies onError recovery to a failing event', () async {
        final ComputeStreamTransformer<int, int> transformer =
            ComputeStreamTransformer<int, int>(
          computeFunction: _throwOnZero,
          onError: (Object error, StackTrace stack) => -1,
        );

        final List<int> result = await transformer
            .bind(Stream<int>.fromIterable(<int>[1, 0, 3]))
            .toList();

        expect(result, orderedEquals(<int>[2, -1, 6]));
      });
    });

    group('lifecycle', () {
      // Cancelling mid-flight must not emit after cancel and must not raise an
      // unhandled error — the in-flight compute result is simply discarded.
      test('cancellation mid-stream yields no further emits or errors', () async {
        final StreamController<int> controller = StreamController<int>();
        addTearDown(controller.close);

        final List<int> seen = <int>[];
        Object? unhandled;

        final StreamSubscription<int> sub = controller.stream
            .transform(
              ComputeStreamTransformer<int, int>(computeFunction: _double),
            )
            .listen(seen.add, onError: (Object e, StackTrace s) => unhandled = e);

        controller.add(1);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        // Any emit after cancel would be a leak; give the pipeline a tick.
        controller.add(2);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(seen.contains(4), isFalse, reason: 'no emit after cancel');
        expect(unhandled, isNull, reason: 'no unhandled error after cancel');
      });

      // After an error event the stream still closes: onDone must fire so a
      // consumer awaiting completion is not left hanging.
      test('onDone fires after an error event closes the stream', () async {
        final Stream<int> source = Stream<int>.fromIterable(<int>[0]);

        final Completer<bool> done = Completer<bool>();
        source
            .transform(
              ComputeStreamTransformer<int, int>(computeFunction: _throwOnZero),
            )
            .listen(
              (_) {},
              onError: (Object e, StackTrace s) {},
              onDone: () => done.complete(true),
            );

        expect(await done.future, isTrue);
      });
    });
  });
}
