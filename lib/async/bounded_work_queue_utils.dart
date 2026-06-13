/// Bounded async work queue with backpressure — roadmap #654.
///
/// A fixed-capacity producer/consumer channel: `push` enqueues an item but, when
/// the buffer is full, returns a future that doesn't complete until a consumer
/// frees a slot — so a fast producer is throttled to the consumer's pace instead
/// of growing memory without bound. `pull` symmetrically waits when the buffer is
/// empty. Hand-off is FIFO and direct (a waiting consumer gets a pushed item
/// without it touching the buffer).
///
/// Use this to bridge a burst source to a rate-limited sink (the backpressure is
/// the point); for fire-and-forget concurrency use `TaskScheduler` instead.
library;

import 'dart:async' show Completer;
import 'dart:collection' show ListQueue;

/// A bounded FIFO channel of [T] with blocking [push]/[pull] and backpressure.
class BoundedWorkQueue<T> {
  /// Creates a queue holding at most [maxSize] buffered items ([maxSize] ≥ 1).
  /// Audited: 2026-06-12 11:26 EDT
  BoundedWorkQueue({required int maxSize}) : maxSize = _validatedMaxSize(maxSize);

  // Enforced in release (an assert strips): maxSize < 1 leaves no buffer slot, so
  // push/pull deadlock under backpressure. A static helper in the initializer
  // keeps the throw out of the constructor body (avoid_exception_in_constructor).
  static int _validatedMaxSize(int maxSize) {
    if (maxSize < 1) {
      throw ArgumentError.value(maxSize, 'maxSize', 'must be >= 1');
    }
    return maxSize;
  }

  /// Maximum number of items buffered before [push] starts applying backpressure.
  final int maxSize;

  final ListQueue<T> _buffer = ListQueue<T>();

  /// Producers blocked on a full buffer: their item plus the completer that
  /// resolves once the item is admitted.
  /// Audited: 2026-06-12 11:26 EDT
  final ListQueue<(T, Completer<void>)> _pushWaiters = ListQueue<(T, Completer<void>)>();

  /// Consumers blocked on an empty buffer, in arrival order.
  /// Audited: 2026-06-12 11:26 EDT
  final ListQueue<Completer<T>> _pullWaiters = ListQueue<Completer<T>>();

  bool _isClosed = false;

  /// Buffered (not-yet-pulled) item count.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _buffer.length;

  /// Whether the buffer is at capacity (the next [push] will block).
  /// Audited: 2026-06-12 11:26 EDT
  bool get isFull => _buffer.length >= maxSize;

  /// Producers currently blocked waiting for a free slot.
  /// Audited: 2026-06-12 11:26 EDT
  int get pendingProducers => _pushWaiters.length;

  /// Consumers currently blocked waiting for an item.
  /// Audited: 2026-06-12 11:26 EDT
  int get pendingConsumers => _pullWaiters.length;

  /// Whether [close] has been called.
  // ignore: saropa_lints/prefer_correct_handler_name -- isClosed is a boolean state getter, not an event handler; the rule only matches the "Closed" suffix
  bool get isClosed => _isClosed;

  /// Enqueues [item], returning a future that completes once it is buffered (or
  /// handed directly to a waiting consumer). When the buffer is full the future
  /// stays pending until a [pull] frees a slot — the backpressure signal. The
  /// future completes with [StateError] if the queue is (or becomes) closed.
  /// Audited: 2026-06-12 11:26 EDT
  Future<void> push(T item) {
    if (_isClosed) {
      return Future<void>.error(StateError('cannot push to a closed BoundedWorkQueue'));
    }
    if (tryPush(item)) {
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    _pushWaiters.add((item, completer));
    return completer.future;
  }

  /// Non-blocking [push]: enqueues [item] and returns true if there was room (or
  /// a waiting consumer), or false without blocking if the buffer is full.
  /// Throws [StateError] if the queue is closed.
  /// Audited: 2026-06-12 11:26 EDT
  bool tryPush(T item) {
    if (_isClosed) {
      throw StateError('cannot push to a closed BoundedWorkQueue');
    }
    // A waiting consumer takes the item directly, bypassing the buffer.
    if (_pullWaiters.isNotEmpty) {
      _pullWaiters.removeFirst().complete(item);
      return true;
    }
    if (_buffer.length < maxSize) {
      _buffer.add(item);
      return true;
    }
    return false;
  }

  /// Dequeues the next item, returning a future that completes once one is
  /// available. When the buffer is empty the future stays pending until a [push]
  /// arrives. If the queue is closed AND empty, completes with [StateError].
  /// Audited: 2026-06-12 11:26 EDT
  Future<T> pull() {
    if (_buffer.isNotEmpty) {
      final T item = _buffer.removeFirst();
      _admitWaitingProducer();
      return Future<T>.value(item);
    }
    if (_isClosed) {
      return Future<T>.error(StateError('BoundedWorkQueue is closed and empty'));
    }
    final Completer<T> completer = Completer<T>();
    _pullWaiters.add(completer);
    return completer.future;
  }

  /// Non-blocking [pull]: returns the next buffered item, or null if the buffer
  /// is empty. NOTE: with a nullable [T] a buffered null is indistinguishable
  /// from "empty" here — use [pull] when [T] is nullable.
  /// Audited: 2026-06-12 11:26 EDT
  T? tryPull() {
    if (_buffer.isEmpty) {
      return null;
    }
    final T item = _buffer.removeFirst();
    _admitWaitingProducer();
    return item;
  }

  /// Closes the queue: blocks further pushes, fails every blocked producer and
  /// consumer with [StateError], and lets consumers drain any already-buffered
  /// items (a [pull] on the empty closed queue then errors). Buffered items are
  /// NOT discarded — drain them before closing if they matter.
  /// Audited: 2026-06-12 11:26 EDT
  void close() {
    _isClosed = true;
    for (final (_, Completer<void> completer) in _pushWaiters) {
      completer.completeError(StateError('BoundedWorkQueue closed'), StackTrace.current);
    }
    _pushWaiters.clear();
    for (final Completer<T> completer in _pullWaiters) {
      completer.completeError(StateError('BoundedWorkQueue closed'), StackTrace.current);
    }
    _pullWaiters.clear();
  }

  /// After a slot frees, admits one blocked producer: its item moves to the back
  /// of the buffer (preserving arrival order) and its [push] future completes.
  /// Audited: 2026-06-12 11:26 EDT
  void _admitWaitingProducer() {
    if (_pushWaiters.isEmpty) {
      return;
    }
    final (T item, Completer<void> completer) = _pushWaiters.removeFirst();
    _buffer.add(item);
    completer.complete();
  }

  @override
  String toString() =>
      'BoundedWorkQueue(maxSize: $maxSize, length: $length, '
      'pendingProducers: $pendingProducers, pendingConsumers: $pendingConsumers)';
}
