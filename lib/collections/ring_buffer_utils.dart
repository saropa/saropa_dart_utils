/// Ring buffer (bounded queue with overwrite) — roadmap #500.
library;

/// Fixed-capacity ring buffer. When full, oldest is overwritten.
class RingBufferUtils<T extends Object> {
  static const String _kErrCapacityAtLeastOne = 'capacity >= 1';

  factory RingBufferUtils(int capacity) {
    if (capacity < 1) throw ArgumentError(_kErrCapacityAtLeastOne);
    return RingBufferUtils._(capacity);
  }

  RingBufferUtils._(int capacity) : _capacity = capacity, _data = List<T?>.filled(capacity, null);
  final List<T?> _data;
  final int _capacity;

  /// Maximum number of elements; when full, oldest is overwritten.
  int get capacity => _capacity;
  int _head = 0;
  int _len = 0;

  /// Appends [value]; overwrites oldest if at capacity.
  void add(T value) {
    _data[(_head + _len) % _capacity] = value;
    if (_len < _capacity) {
      _len++;
    } else {
      _head = (_head + 1) % _capacity;
    }
  }

  T? removeFirst() {
    if (_len == 0) return null;
    final T? v = _data[_head];
    _head = (_head + 1) % _capacity;
    _len--;
    return v;
  }

  /// Current number of elements (0 to [capacity]).
  int get length => _len;

  /// True when the buffer has no elements.
  bool get isEmpty => _len == 0;

  /// True when the buffer has at least one element.
  bool get isNotEmpty => _len > 0;

  /// Elements in order (oldest first).
  List<T> toList() {
    final List<T> out = <T>[];
    for (int i = 0; i < _len; i++) {
      final T? v = _data[(_head + i) % _capacity];
      if (v != null) out.add(v);
    }
    return out;
  }

  @override
  String toString() => 'RingBufferUtils(capacity: $_capacity, length: $_len)';
}
