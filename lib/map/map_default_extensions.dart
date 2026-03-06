import 'package:meta/meta.dart';

/// Default map: returns a default value for missing keys.
///
/// Wraps a [Map] and implements [Map] so that [operator []] returns
/// [defaultValue] when the key is absent. Writes and [remove] write through.
class MapDefaultExtensions<K extends Object, V extends Object> implements Map<K, V> {
  /// Creates a default map with the wrapped map and [defaultValue].
  MapDefaultExtensions(this._source, this.defaultValue);

  final Map<K, V> _source;

  /// Value returned for missing keys.
  final V defaultValue;

  @override
  V? operator [](Object? key) {
    final V? v = _source[key];
    return v ?? defaultValue;
  }

  @override
  void operator []=(K key, V value) => _source[key] = value;

  @override
  void clear() => _source.clear();

  @override
  Iterable<K> get keys => _source.keys;

  @override
  V? remove(Object? key) => _source.remove(key);

  @override
  Iterable<V> get values => _source.values;

  @override
  void addAll(Map<K, V> other) => _source.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) => _source.addEntries(entries);

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) =>
      _source.map(convert);

  @override
  void removeWhere(bool Function(K key, V value) test) => _source.removeWhere(test);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) => _source.putIfAbsent(key, ifAbsent);

  @override
  void forEach(void Function(K key, V value) action) => _source.forEach(action);

  @override
  Iterable<MapEntry<K, V>> get entries => _source.entries;

  @override
  int get length => _source.length;

  @override
  bool get isEmpty => _source.isEmpty;

  @override
  bool get isNotEmpty => _source.isNotEmpty;

  @override
  bool containsKey(Object? key) => _source.containsKey(key);

  @override
  bool containsValue(Object? value) => _source.containsValue(value);

  @override
  Map<K2, V2> cast<K2, V2>() => _source.cast<K2, V2>();

  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) =>
      _source.update(key, update, ifAbsent: ifAbsent);

  @override
  void updateAll(V Function(K key, V value) update) => _source.updateAll(update);

  @override
  String toString() => _source.toString();
}

/// Extension to wrap a map with a default value for missing keys.
extension MapWithDefaultExt<K extends Object, V extends Object> on Map<K, V> {
  /// Returns a [MapDefaultExtensions] view that returns [defaultValue] for missing keys.
  @useResult
  MapDefaultExtensions<K, V> withDefault(V defaultValue) => MapDefaultExtensions<K, V>(this, defaultValue);
}
