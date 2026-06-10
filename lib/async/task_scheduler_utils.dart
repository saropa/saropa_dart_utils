/// Priority task scheduler with a concurrency limit — roadmap #655.
///
/// Runs at most N async tasks at once; when a slot frees, the highest-priority
/// waiting task runs next (FIFO among equal priorities). This is the piece the
/// FIFO `AsyncSemaphoreUtils` can't provide: a semaphore admits waiters in
/// arrival order, whereas a scheduler reorders the backlog by importance — so an
/// urgent task jumps ahead of a queue of background work without preempting the
/// jobs already running.
library;

import 'dart:async' show Completer;

/// Produces the future result of one scheduled task.
typedef ScheduledTask<T> = Future<T> Function();

/// Schedules async tasks under a fixed [concurrency] cap, dispatching the
/// highest-priority waiter whenever a slot opens. Higher [schedule] `priority`
/// values run first; equal priorities preserve submission order.
class TaskScheduler {
  /// Creates a scheduler that runs at most [concurrency] tasks concurrently.
  /// [concurrency] must be at least 1.
  TaskScheduler({required this.concurrency})
    : assert(concurrency >= 1, 'concurrency must be >= 1');

  /// Maximum number of tasks allowed to run at the same time.
  final int concurrency;

  /// Backlog ordered highest-priority-first, then by submission order. The head
  /// is always the next task to dispatch, so dispatch is a cheap `removeAt(0)`.
  final List<_PendingTask> _queue = <_PendingTask>[];

  int _running = 0;

  /// Monotonic submission counter; the tie-breaker that makes equal-priority
  /// scheduling FIFO instead of arbitrary.
  int _sequence = 0;

  /// Number of tasks currently executing.
  int get running => _running;

  /// Number of tasks waiting for a slot.
  int get pending => _queue.length;

  /// Schedules [task] to run when a slot is free, returning a future that
  /// completes with its result (or its error — a failed task never stalls the
  /// scheduler; the slot is always released). Higher [priority] runs sooner.
  ///
  /// Example:
  /// ```dart
  /// final scheduler = TaskScheduler(concurrency: 2);
  /// final result = scheduler.schedule(() => fetch(url), priority: 10);
  /// ```
  Future<T> schedule<T>(ScheduledTask<T> task, {int priority = 0}) {
    final Completer<T> completer = Completer<T>();
    _insert(_PendingTask(priority, _sequence++, () => _execute<T>(task, completer)));
    _pump();
    return completer.future;
  }

  /// Dispatches waiting tasks until the concurrency cap is reached or the queue
  /// drains. Safe to call repeatedly; it only ever starts as many as fit.
  void _pump() {
    while (_running < concurrency && _queue.isNotEmpty) {
      _queue.removeAt(0).start();
    }
  }

  /// Runs one task: increments the in-flight count synchronously (before the
  /// first await, so [_pump]'s cap check sees it), forwards the result or error
  /// to the caller's completer, then frees the slot and re-pumps.
  Future<void> _execute<T>(ScheduledTask<T> task, Completer<T> completer) async {
    _running++;
    try {
      completer.complete(await task());
    } on Object catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    } finally {
      _running--;
      _pump();
    }
  }

  /// Inserts [task] keeping [_queue] sorted by priority (desc) then sequence
  /// (asc). Because [task] always carries the newest sequence, equal-priority
  /// entries land after their predecessors — preserving FIFO within a priority.
  void _insert(_PendingTask task) {
    int i = 0;
    while (i < _queue.length && _queue[i].outranks(task)) {
      i++;
    }
    _queue.insert(i, task);
  }

  @override
  String toString() => 'TaskScheduler(concurrency: $concurrency, running: $_running, pending: $pending)';
}

/// One queued task: its [priority], submission [sequence], and the [start]
/// thunk that begins execution.
class _PendingTask {
  _PendingTask(this.priority, this.sequence, this.start);

  final int priority;
  final int sequence;
  final void Function() start;

  /// Whether this task should stay ahead of [other] in the queue: strictly
  /// higher priority, or equal priority but submitted earlier.
  bool outranks(_PendingTask other) =>
      priority > other.priority || (priority == other.priority && sequence < other.sequence);
}
