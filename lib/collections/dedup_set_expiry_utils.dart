/// Deduplicating set with expiry (for idempotency) — roadmap #511.
library;

/// Tracks "seen" keys; after [expiry] they are forgotten. Not thread-safe.
class DedupSetWithExpiry {
  DedupSetWithExpiry(Duration expiry) : _expiry = expiry;
  final Duration _expiry;

  /// Duration after which a key is forgotten.
  Duration get expiry => _expiry;
  final Map<Object, DateTime> _seen = <Object, DateTime>{};

  /// Adds [key] if not recently seen; returns true if added, false if already present.
  bool add(Object key) {
    _prune();
    final DateTime now = DateTime.now();
    if (_seen.containsKey(key)) return false;
    _seen[key] = now;
    return true;
  }

  /// True if [key] was added and not yet expired.
  bool contains(Object key) {
    _prune();
    return _seen.containsKey(key);
  }

  void _prune() {
    final DateTime cutoff = DateTime.now().subtract(_expiry);
    _seen.removeWhere((_, DateTime t) => t.isBefore(cutoff));
  }

  @override
  String toString() => 'DedupSetWithExpiry(expiry: $_expiry, seen: ${_seen.length})';
}
