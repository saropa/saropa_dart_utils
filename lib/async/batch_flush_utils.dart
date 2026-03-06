/// Batch/flush: collect events and flush on size/time — roadmap #671.
library;

/// Collects items and flushes when [batchSize] reached or [flush] called.
class BatchBuffer<T extends Object> {
  BatchBuffer(int batchSize, this.onFlush) : _batchSize = batchSize, _buffer = [];
  final int _batchSize;

  /// Size at which the buffer is automatically flushed.
  int get batchSize => _batchSize;
  final void Function(List<T> batch) onFlush;
  final List<T> _buffer;

  /// Appends [item]; flushes when buffer length reaches the batch size.
  void add(T item) {
    _buffer.add(item);
    if (_buffer.length >= _batchSize) flush();
  }

  /// Invokes [onFlush] with current buffer contents and clears the buffer.
  void flush() {
    if (_buffer.isEmpty) return;
    onFlush(List<T>.of(_buffer));
    _buffer.clear();
  }

  /// Current number of items in the buffer.
  int get length => _buffer.length;

  @override
  String toString() => 'BatchBuffer(batchSize: $_batchSize, length: ${_buffer.length})';
}
