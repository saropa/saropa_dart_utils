import 'package:meta/meta.dart';

/// Map More: from iterable, find key by value, rename key, ensure key, etc. Roadmap #291-300.
extension MapFromIterableExtension<T, K, V> on Iterable<T> {
  /// Builds a map from [keyOf] and [valueOf] for each element; later elements overwrite.
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  List<K> get keysList => keys.toList();

  /// All values in iteration order.
  /// Audited: 2026-06-12 11:26 EDT
  List<V> get valuesList => values.toList();
}

/// Find key for a value.
extension MapFindKey<K, V> on Map<K, V> {
  /// First key that maps to [value], or null.
  /// Audited: 2026-06-12 11:26 EDT
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
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Map<K, V> renameKey(K oldKey, K newKey) {
    // Rebuild into a fresh map (preserves a genuinely-null value — the old
    // `if (v != null)` guard dropped entries whose value was null) and re-key
    // each entry in one pass so there is no remove-then-overwrite hazard.
    final Map<K, V> out = <K, V>{};
    forEach((K k, V v) {
      out[k == oldKey ? newKey : k] = v;
    });
    return out;
  }

  /// New map with keys renamed according to [oldToNew]. Keys absent from
  /// [oldToNew] are kept as-is. If two keys map to the same target, the later
  /// one in iteration order wins (a genuine collision is inherently lossy).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Map<K, V> renameKeys(Map<K, K> oldToNew) {
    // Single pass into a fresh map: read the NEW key for each ORIGINAL entry
    // (`oldToNew[k] ?? k`) and write it once. The previous version mutated the
    // copy it was iterating, so a chained rename ({'a':'b','b':'c'}) overwrote
    // 'b' before renaming it and lost data; it also dropped null values.
    final Map<K, V> out = <K, V>{};
    forEach((K k, V v) {
      out[oldToNew[k] ?? k] = v;
    });
    return out;
  }
}

/// Ensure a key exists.
extension MapEnsureKey<K, V> on Map<K, V> {
  /// If [key] is absent, sets this[key] = ifAbsent().
  /// Audited: 2026-06-12 11:26 EDT
  void ensureKey(K key, V Function() ifAbsent) {
    if (!containsKey(key)) this[key] = ifAbsent();
  }
}

/// Insert or update by key.
extension MapUpsert<K, V> on Map<K, V> {
  /// If [key] absent: this[key] = insert(); else this[key] = update(this[key]).
  /// Audited: 2026-06-12 11:26 EDT
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
