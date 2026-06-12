/// Async resource pool with a fixed maximum size — roadmap #666.
///
/// Bounds how many expensive-to-create resources (DB connections, HTTP clients,
/// worker isolates) exist at once and reuses idle ones instead of recreating
/// them. A borrower acquires a resource, uses it, and returns it; when every
/// resource is busy, further borrowers wait FIFO until one is released. Lazily
/// grows up to the cap — a resource is created only when a borrower needs one
/// and none is idle.
library;

import 'dart:async' show Completer;

/// Creates a fresh pooled resource.
typedef ResourceFactory<T> = Future<T> Function();

/// Disposes a pooled resource (close a socket, end a connection).
typedef ResourceDisposer<T> = Future<void> Function(T resource);

/// A bounded, reusing pool of at most [maxSize] resources of type [T].
class ResourcePool<T> {
  /// Creates a pool that lazily builds up to [maxSize] resources via [create],
  /// optionally disposing idle ones through [onDispose] when [close] drains the
  /// pool. [maxSize] must be at least 1.
  /// Audited: 2026-06-12 11:26 EDT
  ResourcePool({
    required ResourceFactory<T> create,
    required this.maxSize,
    ResourceDisposer<T>? onDispose,
  }) : assert(maxSize >= 1, 'maxSize must be >= 1'),
       _create = create,
       _onDispose = onDispose;

  /// Maximum number of resources that may exist (idle + in use) at once.
  final int maxSize;

  final ResourceFactory<T> _create;
  final ResourceDisposer<T>? _onDispose;

  /// Resources created and currently free for reuse.
  final List<T> _idle = <T>[];

  /// Borrowers waiting for a resource because the pool is at capacity, in
  /// arrival order — a release hands the resource straight to the head.
  final List<Completer<T>> _waiters = <Completer<T>>[];

  /// Count of resources created (idle + in use); the cap is on this, not idle.
  int _created = 0;

  bool _isClosed = false;

  /// Resources free for immediate reuse.
  /// Audited: 2026-06-12 11:26 EDT
  int get idleCount => _idle.length;

  /// Resources currently borrowed (created but not idle).
  /// Audited: 2026-06-12 11:26 EDT
  int get inUseCount => _created - _idle.length;

  /// Borrowers currently waiting for a resource.
  /// Audited: 2026-06-12 11:26 EDT
  int get waitingCount => _waiters.length;

  /// Borrows a resource for [action], returning it to the pool afterward even if
  /// [action] throws. The usual entry point — it pairs acquire/release so a
  /// resource can never leak. Throws [StateError] if the pool is closed.
  /// Audited: 2026-06-12 11:26 EDT
  Future<R> use<R>(Future<R> Function(T resource) action) async {
    final T resource = await acquire();
    try {
      return await action(resource);
    } finally {
      release(resource);
    }
  }

  /// Acquires a resource: reuses an idle one, else creates a new one if below
  /// [maxSize], else waits FIFO for a release. Prefer [use] so the matching
  /// [release] can't be forgotten. Throws [StateError] if the pool is closed.
  /// Audited: 2026-06-12 11:26 EDT
  Future<T> acquire() async {
    if (_isClosed) {
      throw StateError('ResourcePool is closed');
    }
    if (_idle.isNotEmpty) {
      return _idle.removeLast();
    }
    if (_created < maxSize) {
      return await _createTracked();
    }
    final Completer<T> waiter = Completer<T>();
    _waiters.add(waiter);
    return await waiter.future;
  }

  /// Returns [resource] to the pool. A waiting borrower (if any) receives it
  /// directly; otherwise it becomes idle. After [close], the resource is simply
  /// dropped from the count (not disposed here — see [close]).
  /// Audited: 2026-06-12 11:26 EDT
  void release(T resource) {
    if (_isClosed) {
      // Pool is shut down: drop the resource from the live count. Disposal is
      // not performed here because this method is synchronous and cannot await a
      // disposer. The close method disposes the idle resources it holds, while a
      // resource still checked out at shutdown belongs to the caller — return
      // resources before closing, or dispose that one directly.
      _created--;
      return;
    }
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete(resource);
      return;
    }
    _idle.add(resource);
  }

  /// Closes the pool: disposes every idle resource, fails every waiting borrower
  /// with [StateError], and blocks new acquisitions. Awaits all idle disposals.
  /// Resources still checked out are NOT disposed by the pool — return them
  /// before closing (or dispose them yourself); a late [release] just drops the
  /// reference from the count.
  /// Audited: 2026-06-12 11:26 EDT
  Future<void> close() async {
    _isClosed = true;
    final List<T> toDispose = List<T>.of(_idle);
    _idle.clear();
    // Fail anyone parked on a slot that will now never free.
    for (final Completer<T> waiter in _waiters) {
      waiter.completeError(StateError('ResourcePool is closed'), StackTrace.current);
    }
    _waiters.clear();
    for (final T resource in toDispose) {
      await _dispose(resource);
    }
  }

  /// Creates one resource under the cap, rolling back the count if creation
  /// fails so a thrown factory doesn't permanently consume a slot.
  /// Audited: 2026-06-12 11:26 EDT
  Future<T> _createTracked() async {
    _created++;
    try {
      return await _create();
    } on Object {
      _created--;
      rethrow;
    }
  }

  /// Disposes [resource] via [_onDispose] if provided, and drops it from the
  /// created count so a closed pool's slots are reclaimed.
  /// Audited: 2026-06-12 11:26 EDT
  Future<void> _dispose(T resource) async {
    _created--;
    final ResourceDisposer<T>? dispose = _onDispose;
    if (dispose != null) {
      await dispose(resource);
    }
  }

  @override
  String toString() =>
      'ResourcePool(maxSize: $maxSize, idle: $idleCount, inUse: $inUseCount, waiting: $waitingCount)';
}
