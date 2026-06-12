/// Memory-conscious string pool (deduplicate repeating strings) — roadmap #518.
library;

/// Interner: returns canonical instance for equal strings.
///
/// Optional [maxSize] limits the pool; when exceeded, one arbitrary entry
/// is evicted (FIFO by first intern after full). Omit for unbounded pooling.
class StringPoolUtils {
  /// Creates a string pool. Pass [maxSize] to bound the pool with FIFO
  /// eviction; omit it for unbounded pooling.
  /// Audited: 2026-06-12 11:26 EDT
  StringPoolUtils({int? maxSize})
    : _maxSize = maxSize,
      _order = maxSize != null ? <String>[] : null;

  final int? _maxSize;
  final List<String>? _order;
  final Map<String, String> _pool = <String, String>{};

  /// Returns the canonical string equal to [s]; deduplicates repeated strings.
  /// Audited: 2026-06-12 11:26 EDT
  String intern(String s) {
    final String? existing = _pool[s];
    if (existing != null) return existing;
    if (_maxSize != null && _order != null && _order.length >= _maxSize) {
      final String evict = _order.removeAt(0);
      _pool.remove(evict);
    }
    _pool[s] = s;
    _order?.add(s);
    return s;
  }

  /// Number of distinct interned strings.
  /// Audited: 2026-06-12 11:26 EDT
  int get size => _pool.length;

  @override
  String toString() => 'StringPoolUtils(size: ${_pool.length})';
}
