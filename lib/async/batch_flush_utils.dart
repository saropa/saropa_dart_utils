/// Batch/flush: collect events and flush on size/time — roadmap #671.
library;

/// Collects items and flushes when [batchSize] reached or [flush] called.
class BatchFlushUtils<T extends Object> {
  /// Creates a batcher that flushes via [onFlush] once [batchSize] items
  /// accumulate (or when [flush] is called explicitly).
  /// Audited: 2026-06-12 11:26 EDT
  BatchFlushUtils(this.batchSize, this.onFlush) : _buffer = <T>[];

  /// Size at which the buffer is automatically flushed.
  final int batchSize;

  /// Callback invoked with the buffered batch when a flush occurs.
  /// Audited: 2026-06-12 11:26 EDT
  final void Function(List<T> batch) onFlush;
  final List<T> _buffer;

  /// Appends [item]; flushes when buffer length reaches the batch size.
  /// Audited: 2026-06-12 11:26 EDT
  void add(T item) {
    _buffer.add(item);
    if (_buffer.length >= batchSize) flush();
  }

  /// Invokes [onFlush] with current buffer contents and clears the buffer.
  /// Audited: 2026-06-12 11:26 EDT
  void flush() {
    if (_buffer.isEmpty) return;
    onFlush(List<T>.of(_buffer));
    _buffer.clear();
  }

  /// Current number of items in the buffer.
  /// Audited: 2026-06-12 11:26 EDT
  int get length => _buffer.length;

  @override
  String toString() => 'BatchFlushUtils(batchSize: $batchSize, length: ${_buffer.length})';
}
