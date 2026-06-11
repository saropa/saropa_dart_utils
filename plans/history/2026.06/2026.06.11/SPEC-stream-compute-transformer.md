# SPEC: ComputeStreamTransformer — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/async/compute_stream_transformer.dart
**Portability:** Flutter (depends on `package:flutter/foundation.dart` for `compute()` and `ComputeCallback`). Also uses `dart:async` (`StreamTransformerBase`). No external pub packages. NOT pure Dart — it intentionally offloads per-event work to a background isolate via Flutter's `compute()`, which is unavailable in plain `dart:isolate` form here.

## Purpose — what it does + why it is general-purpose (not proprietary)

`ComputeStreamTransformer<TInput, TOutput>` is a generic `StreamTransformerBase` that runs each incoming stream event through Flutter's `compute()` (a one-shot background isolate) and emits the result. It exists to keep CPU-bound per-event conversions (model mapping, parsing, serialization, decoding) off the UI thread so the stream's consumer never janks. It is a thin, type-parametric wrapper over `stream.asyncMap((data) => compute(fn, data))` with an optional error-recovery callback.

This is general-purpose: it carries no knowledge of what `TInput`/`TOutput` are. Any caller supplies a top-level `ComputeCallback<TInput, TOutput>` and gets a transformer that applies it per event in the background. The same shape serves DB-model conversion, JSON decoding, image-byte processing, or any heavy synchronous transform driven by a stream.

### Excluded members (proprietary / app-specific — NOT proposed)

| Member | Why excluded |
|---|---|
| `ContactDBListConversionParams` | Contact-domain DTO; bundles `ContactFilters`, privacy-settings, `excludeDeceased` — all Saropa contact logic. |
| `convertContactDBListToModels(...)` | Operates on `ContactDBModel` → `ContactModel`, applies `ContactFilters`, privacy processing, deceased-exclusion. Pure app domain; also calls `debugException` (Crashlytics reporting). |
| `ContactDBStreamTransformer` | Hardwired to `List<ContactDBModel>` → `List<ContactModel>?` with contact filters. App-specific specialization of the generic transformer below. |
| `ContactDBStreamExtensions.transformToContactModels(...)` | Extension on `Stream<List<ContactDBModel>>`; contact-domain. |

Only the trailing generic `ComputeStreamTransformer<TInput, TOutput>` is general-purpose. The contact-specific members are exactly what `ComputeStreamTransformer` plus a caller-supplied callback replaces.

## Source (from Saropa Contacts) — verbatim general-purpose member (debug logging stripped)

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

/// A generic [StreamTransformerBase] that runs each stream event through
/// Flutter's [compute] (a one-shot background isolate), keeping CPU-bound
/// per-event work off the UI thread.
///
/// [computeFunction] MUST be a top-level or static function (a `compute`
/// requirement — closures capturing state cannot be sent to an isolate).
///
/// If [onError] is supplied, an exception thrown while computing an event is
/// converted into a fallback output value instead of erroring the stream; when
/// [onError] is null the error is rethrown onto the output stream.
///
/// Example:
/// ```dart
/// // Top-level function — required by compute().
/// List<Foo> _decode(List<int> bytes) => FooCodec.decode(bytes);
///
/// sourceStream.transform(
///   ComputeStreamTransformer<List<int>, List<Foo>>(
///     computeFunction: _decode,
///   ),
/// );
/// ```
class ComputeStreamTransformer<TInput, TOutput>
    extends StreamTransformerBase<TInput, TOutput> {
  ComputeStreamTransformer({required this.computeFunction, this.onError});

  final ComputeCallback<TInput, TOutput> computeFunction;
  final TOutput Function(Object error, StackTrace stackTrace)? onError;

  @override
  Stream<TOutput> bind(Stream<TInput> stream) {
    // Short-lived foreground compute() per event - not a long-lived
    // background task. Work is bounded by each event's payload size.
    return stream.asyncMap((TInput data) async {
      try {
        return await compute(computeFunction, data);
      } on Object catch (error, stackTrace) {
        if (onError != null) {
          return onError!(error, stackTrace);
        }
        rethrow;
      }
    });
  }
}
```

## Test cases — proposed (no existing test found)

No `*_test.dart` covering `ComputeStreamTransformer` exists under `d:/src/contacts/test`. The following are proposed.

Note: real `compute()` spawns an isolate and the callback must be a top-level/static function whose argument is sendable across isolate boundaries. Keep payloads simple (ints, strings, lists of primitives) in tests so they serialize cleanly.

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/compute_stream_transformer.dart';

// Top-level functions — compute() requires top-level/static targets.
int _double(int n) => n * 2;
int _throwOnZero(int n) {
  if (n == 0) {
    throw StateError('zero not allowed');
  }
  return n * 2;
}

void main() {
  group('ComputeStreamTransformer', () {
    test('maps each event through the compute function in order', () async {
      final Stream<int> source = Stream<int>.fromIterable(<int>[1, 2, 3]);

      final List<int> result = await source
          .transform(
            ComputeStreamTransformer<int, int>(computeFunction: _double),
          )
          .toList();

      expect(result, orderedEquals(<int>[2, 4, 6]));
    });

    test('empty source stream yields empty output stream', () async {
      final Stream<int> source = const Stream<int>.empty();

      final List<int> result = await source
          .transform(
            ComputeStreamTransformer<int, int>(computeFunction: _double),
          )
          .toList();

      expect(result, isEmpty);
    });

    test('error is rethrown onto the stream when onError is null', () async {
      final Stream<int> source = Stream<int>.fromIterable(<int>[1, 0, 3]);

      final Stream<int> out = source.transform(
        ComputeStreamTransformer<int, int>(computeFunction: _throwOnZero),
      );

      await expectLater(out, emitsThrough(emitsError(isA<Object>())));
    });

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
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

- **Empty stream** — `Stream.empty()` emits no events; transformer must emit none (covered above; keep).
- **Single event** — boundary of "at least one" (covered above; keep).
- **Order preservation under varied latency** — because `asyncMap` awaits each `compute()` before the next, output order must equal input order even when later payloads compute faster. Add a callback whose duration is inversely proportional to the value and assert ordered output.
- **Null TInput / null TOutput** — instantiate `ComputeStreamTransformer<int?, int?>`; feed `null` events; assert the callback receives null and a null result propagates (compute can carry nullable types).
- **Error WITHOUT onError mid-stream** — confirm events BEFORE the throwing event are still emitted and the stream terminates with the error after them (covered partially; assert the pre-error emit too).
- **Error WITH onError on the FIRST event** — fallback must apply even when the very first event throws.
- **onError itself throws** — document/define behavior: the thrown error should surface on the stream, not be swallowed. Add a test asserting it propagates.
- **Multiple consecutive errors** — several throwing events in a row, each individually mapped to a fallback via `onError`; assert one fallback per failing event (no collapsing/dedup).
- **Large payload** — a `List<int>` of e.g. 100k elements to exercise isolate serialization cost without hanging; assert correct transform.
- **Unicode / emoji string payloads** — feed strings containing ` ` (non-breaking space), `…` (ellipsis), and an emoji built via `String.fromCharCode(0x1F600)`; assert the value survives the isolate round-trip byte-for-byte (isolate message copy must not flatten code units).
- **Numeric extremes in payload** — `0`, negative, `double.infinity`, `double.nan`, `double.maxFinite`, `int` near 2^53 — confirm they cross the isolate boundary intact (NaN must remain NaN: assert with `isNaN`, not `equals`).
- **Non-sendable computeFunction (closure)** — passing a closure that captures state should fail at `compute()` time; add a test asserting the error surfaces rather than silently misbehaving (documents the top-level-function requirement).
- **Broadcast vs single-subscription source** — verify the transformer behaves on a broadcast stream (e.g. via `StreamController.broadcast`) — late subscribers, no replay.
- **Source error (not callback error)** — when the SOURCE stream emits an error (vs the callback throwing), confirm it passes through untouched (`onError` only guards compute failures, not upstream errors).
- **Cancellation mid-compute** — subscriber cancels while a `compute()` is in flight; assert no emit after cancel and no unhandled error.
- **Done immediately after error** — error event followed by stream close; assert `onDone` still fires.
- **web / no-isolate platform note** — `compute()` runs synchronously on web (no real isolate). Add a note that on web the transform degrades to inline execution; tests that assume true isolation should be platform-gated or use payloads valid in both modes.
