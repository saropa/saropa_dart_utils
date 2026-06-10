import 'package:meta/meta.dart';

/// Map More: from iterable, find key by value, rename key, ensure key, etc. Roadmap #291-300.
extension MapFromIterableExtension<T, K, V> on Iterable<T> {
  /// Builds a map from [keyOf] and [valueOf] for each element; later elements overwrite.
  Map<K, V> toMapWith(K Function(T) keyOf, V Function(T) valueOf) {
    final Map<K, V> out = <K, V>{};
    for (final T e in this) {
      out[keyOf(e)] = valueOf(e);
    }
    return out;
  }
}

/// Keys/values as lists.
extension MapKeysValuesList<K, V> on Map<K, V> {
  /// All keys in iteration order.
  List<K> get keysList => keys.toList();

  /// All values in iteration order.
  List<V> get valuesList => values.toList();
}

/// Find key for a value.
extension MapFindKey<K, V> on Map<K, V> {
  /// First key that maps to [value], or null.
  K? findKeyByValue(V value) {
    for (final MapEntry<K, V> e in entries) {
      if (e.value == value) return e.key;
    }
    return null;
  }
}

/// Rename keys in a copy.
extension MapRenameKey<K, V> on Map<K, V> {
  /// New map with [oldKey] renamed to [newKey]; unchanged if oldKey absent.
  @useResult
  Map<K, V> renameKey(K oldKey, K newKey) {
    final Map<K, V> out = Map<K, V>.from(this);
    if (out.containsKey(oldKey)) {
      final v = out.remove(oldKey);
      if (v != null) out[newKey] = v;
    }
    return out;
  }

  /// New map with keys renamed according to [oldToNew].
  @useResult
  Map<K, V> renameKeys(Map<K, K> oldToNew) {
    // Rename on a copy so the receiver is left unmodified (the @useResult
    // contract — callers expect a new map, not a mutation).
    final Map<K, V> out = Map<K, V>.from(this);
    for (final MapEntry<K, K> e in oldToNew.entries) {
      // Only act on keys that are actually present; remove-then-reinsert under
      // the new key performs the rename. The v != null guard means a key whose
      // stored value is null is silently dropped rather than re-added — an
      // accepted caveat for maps that hold null values.
      if (out.containsKey(e.key)) {
        final v = out.remove(e.key);
        if (v != null) out[e.value] = v;
      }
    }
    return out;
  }
}

/// Ensure a key exists.
extension MapEnsureKey<K, V> on Map<K, V> {
  /// If [key] is absent, sets this[key] = ifAbsent().
  void ensureKey(K key, V Function() ifAbsent) {
    if (!containsKey(key)) this[key] = ifAbsent();
  }
}

/// Insert or update by key.
extension MapUpsert<K, V> on Map<K, V> {
  /// If [key] absent: this[key] = insert(); else this[key] = update(this[key]).
  void upsert(K key, V Function() insert, V Function(V existing) update) {
    // Branch on presence, not on the looked-up value: a key can be present with
    // a null value, and treating that as "absent" would wrongly call insert().
    if (!containsKey(key)) {
      this[key] = insert();
    } else {
      // The `is V` test both narrows the nullable lookup to non-null and skips
      // the rare case where the stored value is null (V itself nullable), so
      // update only ever receives a genuine existing V.
      final v = this[key];
      if (v is V) this[key] = update(v);
    }
  }
}
