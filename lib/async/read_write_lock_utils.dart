/// Async read/write lock — roadmap #653.
///
/// Coordinates a shared resource so many readers run concurrently OR one writer
/// runs exclusively, never both. Unlike `AsyncMutexUtils` (which serializes
/// everything), this lets reads proceed in parallel and only blocks them around
/// a write — the right primitive for a read-heavy cache or in-memory store.
///
/// Writer-preference is the default: once a writer is waiting, new readers queue
/// behind it, so a steady stream of reads can't starve a pending write. Pass
/// `writerPreferred: false` for reader-preference (max read throughput, at the
/// risk of writer starvation).
library;

import 'dart:async' show Completer;
import 'dart:collection' show ListQueue;

/// A reader/writer lock with `read`/`write` scopes. Reentrancy is NOT supported
/// (acquiring a write inside a read on the same lock will deadlock).
class ReadWriteLock {
  /// Creates a lock. [writerPreferred] (default true) makes waiting writers take
  /// priority over newly-arriving readers.
  ReadWriteLock({this.writerPreferred = true});

  /// Whether a waiting writer blocks newly-arriving readers (anti-starvation).
  final bool writerPreferred;

  int _activeReaders = 0;
  bool _writerActive = false;
  final ListQueue<Completer<void>> _readWaiters = ListQueue<Completer<void>>();
  final ListQueue<Completer<void>> _writeWaiters = ListQueue<Completer<void>>();

  /// Number of readers currently holding the lock.
  int get activeReaders => _activeReaders;

  /// Whether a writer currently holds the lock exclusively.
  bool get isWriteLocked => _writerActive;

  /// Readers currently waiting to acquire.
  int get waitingReaders => _readWaiters.length;

  /// Writers currently waiting to acquire.
  int get waitingWriters => _writeWaiters.length;

  /// Runs [action] under a shared read lock, releasing it afterward even if
  /// [action] throws. Multiple reads run concurrently.
  Future<T> read<T>(Future<T> Function() action) async {
    await _acquireRead();
    try {
      return await action();
    } finally {
      _releaseRead();
    }
  }

  /// Runs [action] under the exclusive write lock, releasing it afterward even
  /// if [action] throws. No reads or other writes overlap it.
  Future<T> write<T>(Future<T> Function() action) async {
    await _acquireWrite();
    try {
      return await action();
    } finally {
      _releaseWrite();
    }
  }

  Future<void> _acquireRead() {
    // Proceed immediately only if no writer holds the lock and (under
    // writer-preference) none is queued; otherwise wait behind the writer.
    final bool blockedByWriter = writerPreferred && _writeWaiters.isNotEmpty;
    if (!_writerActive && !blockedByWriter) {
      _activeReaders++;
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    _readWaiters.add(completer);
    return completer.future;
  }

  Future<void> _acquireWrite() {
    if (!_writerActive && _activeReaders == 0) {
      _writerActive = true;
      return Future<void>.value();
    }
    final Completer<void> completer = Completer<void>();
    _writeWaiters.add(completer);
    return completer.future;
  }

  void _releaseRead() {
    _activeReaders--;
    // The last reader out lets a waiting writer (or readers) proceed.
    if (_activeReaders == 0) {
      _wakeNext();
    }
  }

  void _releaseWrite() {
    _writerActive = false;
    _wakeNext();
  }

  /// Hands the lock to the next waiter(s) per the preference policy. Only runs
  /// when the lock is free (no active writer, no active readers).
  void _wakeNext() {
    if (_writerActive || _activeReaders > 0) {
      return;
    }
    if (writerPreferred) {
      if (!_grantWriter()) {
        _grantAllReaders();
      }
      return;
    }
    // Reader-preference: drain queued readers first, else hand to a writer.
    if (_readWaiters.isNotEmpty) {
      _grantAllReaders();
      return;
    }
    _grantWriter();
  }

  /// Grants the lock to the head writer if one waits; returns whether it did.
  bool _grantWriter() {
    if (_writeWaiters.isEmpty) {
      return false;
    }
    _writerActive = true;
    _writeWaiters.removeFirst().complete();
    return true;
  }

  /// Admits every currently-waiting reader as a concurrent batch.
  void _grantAllReaders() {
    while (_readWaiters.isNotEmpty) {
      _activeReaders++;
      _readWaiters.removeFirst().complete();
    }
  }

  @override
  String toString() =>
      'ReadWriteLock(activeReaders: $_activeReaders, writeLocked: $_writerActive, '
      'waitingReaders: $waitingReaders, waitingWriters: $waitingWriters)';
}
