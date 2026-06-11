/// Stream transformer that runs each event through Flutter's `compute()` (a
/// one-shot background isolate), keeping CPU-bound per-event work off the UI
/// thread. From Saropa Contacts.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// A generic [StreamTransformerBase] that runs each stream event through
/// Flutter's [compute] (a one-shot background isolate), keeping CPU-bound
/// per-event work off the UI thread.
///
/// Each incoming event is handed to [computeFunction] on a background isolate
/// via `compute()`; the result is emitted on the output stream. Events are
/// processed one at a time and IN ORDER — `asyncMap` awaits each `compute()`
/// before pulling the next event, so a later event that computes faster can
/// never overtake an earlier one.
///
/// [computeFunction] MUST be a top-level or static function (a `compute`
/// requirement — closures capturing state cannot be sent to an isolate). The
/// event payload must also be sendable across the isolate boundary (primitives,
/// strings, and lists/maps of those copy cleanly; arbitrary objects with native
/// handles do not).
///
/// If [onError] is supplied, an exception thrown while computing an event is
/// converted into a fallback output value instead of erroring the stream; when
/// [onError] is null the error is rethrown onto the output stream. [onError]
/// guards ONLY failures inside `compute()` — an error emitted by the SOURCE
/// stream passes through untouched, because that is not a compute failure.
///
/// Edge cases:
/// - Empty source stream → emits nothing and closes.
/// - Source error (not a callback throw) → forwarded as-is, even when [onError]
///   is set.
/// - [onError] itself throwing → that error surfaces on the stream (it is not
///   swallowed); a fallback callback must not throw if the stream is to survive.
/// - On web there is no real isolate: `compute()` runs the callback inline on
///   the main thread, so the transform still produces correct results but loses
///   the off-thread benefit.
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
  /// Creates a transformer that runs [computeFunction] on a background isolate
  /// for each event, optionally recovering compute failures via [onError].
  ComputeStreamTransformer({required this.computeFunction, this.onError});

  /// The top-level/static function applied to each event on a background
  /// isolate. A closure capturing state cannot be sent across the isolate
  /// boundary and will fail at `compute()` time — this is why the type is
  /// [ComputeCallback], not an arbitrary lambda.
  // ignore: prefer_correct_callback_field_name -- pure per-event transform, not a UI event handler, so the `on` prefix would mislead
  final ComputeCallback<TInput, TOutput> computeFunction;

  /// Optional recovery for a failure thrown while computing a single event.
  ///
  /// When non-null, a thrown error is mapped to a fallback [TOutput] (one
  /// fallback per failing event — failures are never collapsed or deduplicated)
  /// instead of erroring the stream. When null, the error is rethrown onto the
  /// output stream. If this callback itself throws, that error surfaces on the
  /// stream rather than being swallowed.
  final TOutput Function(Object error, StackTrace stackTrace)? onError;

  // asyncMap awaits each background computation before requesting the next
  // event, which is what preserves input order on the output even under varied
  // per-event latency. Each computation is short-lived and bounded by the
  // event's payload size, not a long-lived background task.
  @override
  Stream<TOutput> bind(Stream<TInput> stream) =>
      stream.asyncMap((TInput data) async {
        try {
          return await compute(computeFunction, data);
        } on Object catch (error, stackTrace) {
          // Recover ONLY background-computation failures. A null recovery
          // callback rethrows so the failure becomes a stream error; a non-null
          // one maps it to a fallback value. Source-stream errors never reach
          // this catch - asyncMap forwards them directly - so recovery cannot
          // intercept upstream errors.
          if (onError != null) {
            return onError!(error, stackTrace);
          }
          rethrow;
        }
      });
}
