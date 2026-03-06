/// Shallow copy list/map. Roadmap #207.
List<T> shallowCopyList<T>(List<T> source) => List<T>.of(source);

Map<K, V> shallowCopyMap<K, V>(Map<K, V> source) => Map<K, V>.of(source);
