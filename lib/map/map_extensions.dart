import 'dart:math';

/// Extension methods for generic maps.
extension MapExtensions<K, V> on Map<K, V> {
  /// Returns null if this map is empty.
  Map<K, V>? nullIfEmpty() => isEmpty ? null : this;

  /// Gets random entries from this map, excluding specified keys.
  ///
  /// Args:
  ///   count: The number of random entries to return.
  ///   ignoreList: List of keys to exclude from selection.
  ///
  /// Returns:
  ///   A list of random map entries, or an empty list if no eligible entries.
  List<MapEntry<K, V>>? getRandomListExcept({
    required int count,
    required List<K>? ignoreList,
  }) {
    final List<K> ignore = ignoreList ?? <K>[];
    final List<MapEntry<K, V>> available =
        entries.where((MapEntry<K, V> e) => !ignore.contains(e.key)).toList();
    if (available.isEmpty) return null;
    available.shuffle(Random());
    return available.take(count).toList();
  }
}

/// Extension methods for String-keyed dynamic maps.
extension StringMapExtensions on Map<String, dynamic> {
  /// Formats this map as a human-readable string with indentation.
  String formatMap() {
    if (isEmpty) return '';
    const String indent = '  ';
    final StringBuffer buffer = StringBuffer('{\n');
    forEach((String mapKey, dynamic mapValue) {
      buffer.write(indent);
      buffer.write(mapKey);
      buffer.write(': ');
      if (mapValue is Map<String, dynamic>) {
        buffer.write(mapValue.formatMap());
        buffer.write('\n');
      } else if (mapValue is List) {
        buffer.write('[\n');
        for (dynamic listItem in mapValue) {
          buffer.write(indent);
          buffer.write(indent);
          buffer.write(listItem);
          buffer.write(',\n');
        }
        buffer.write(indent);
        buffer.write('],\n');
      } else {
        buffer.write(mapValue);
        buffer.write(',\n');
      }
    });
    buffer.write('}');
    return buffer.toString();
  }

  /// Gets a child value as String.
  String? getChildString(String childKey) => this[childKey] as String?;

  /// Gets a grandchild value.
  dynamic getGrandchild(String childKey, String grandChildKey) {
    final Map<dynamic, dynamic>? child = this[childKey] as Map<dynamic, dynamic>?;
    return child?[grandChildKey];
  }

  /// Gets a grandchild value as String.
  String? getGrandchildString(String childKey, String grandChildKey) =>
      getGrandchild(childKey, grandChildKey) as String?;

  /// Gets a great-grandchild value.
  dynamic getGreatGrandchild(
    String childKey,
    String grandChildKey,
    String greatGrandChildKey,
  ) {
    final Map<dynamic, dynamic>? grandChild =
        getGrandchild(childKey, grandChildKey) as Map<dynamic, dynamic>?;
    return grandChild?[greatGrandChildKey];
  }

  /// Gets a great-grandchild value as String.
  String? getGreatGrandchildString(
    String childKey,
    String grandChildKey,
    String greatGrandChildKey,
  ) =>
      getGreatGrandchild(childKey, grandChildKey, greatGrandChildKey) as String?;

  /// Gets a child as Map`<String, dynamic>`.
  Map<String, dynamic>? getValue(String? key) {
    if (isEmpty || key == null) return null;
    final dynamic value = this[key];
    return MapUtils.toMapStringDynamic(value);
  }

  /// Removes specified keys from this map.
  ///
  /// Args:
  ///   removeKeysList: List of keys to remove.
  ///   recurseChildValues: If true, also removes keys from nested maps.
  ///
  /// Returns:
  ///   True if any modifications were made.
  bool removeKeys(List<String>? removeKeysList, {bool recurseChildValues = true}) {
    if (removeKeysList == null || removeKeysList.isEmpty) return false;
    removeWhere((String key, _) => removeKeysList.contains(key));
    if (recurseChildValues) {
      updateAll((String _, dynamic value) {
        if (value is Map<String, dynamic>) value.removeKeys(removeKeysList);
        return value;
      });
    }
    return true;
  }

  /// Returns a new map with keys sorted alphabetically.
  Map<String, dynamic> toKeySorted() => Map<String, dynamic>.fromEntries(
      entries.toList()
        ..sort(
          (MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) =>
              a.key.compareTo(b.key),
        ),
    );
}

/// Utility class for map operations.
class MapUtils {
  const MapUtils._();

  /// Counts total items across all iterable values in a map.
  static int countItems<K, V>(Map<K, Iterable<V>> inputMap) => inputMap.values.fold<int>(0, (int sum, Iterable<V> iter) => sum + iter.length);

  /// Toggles a value in a map of lists.
  ///
  /// If [add] is null, toggles based on current presence.
  /// If [add] is true, adds the value. If false, removes it.
  static void mapToggleValue<K, V>(Map<K, List<V>> map, K key, V value, {bool? add}) {
    if (value == null) return;
    add ??= !mapContainsValue(map, key, value);
    if (add) {
      mapAddValue(map, key, value);
    } else {
      mapRemoveValue(map, key, value);
    }
  }

  /// Adds a value to a map of lists.
  static void mapAddValue<K, V>(Map<K, List<V>> map, K key, V value) {
    if (value == null) return;
    map.update(key, (List<V> list) => list..add(value), ifAbsent: () => <V>[value]);
  }

  /// Removes a value from a map of lists.
  static void mapRemoveValue<K, V>(Map<K, List<V>> map, K key, V value) {
    if (value == null) return;
    map.update(key, (List<V> list) => list..remove(value), ifAbsent: () => <V>[]);
  }

  /// Checks if a map of lists contains a specific value.
  static bool mapContainsValue<K, V>(Map<K, List<V>> map, K key, V value) {
    if (value == null) return false;
    return map[key]?.contains(value) ?? false;
  }

  /// Converts dynamic to Map`<String, dynamic>`.
  ///
  /// Args:
  ///   json: The value to convert.
  ///   ensureUniqueKey: If true, uses putIfAbsent to avoid overwriting duplicate keys.
  static Map<String, dynamic>? toMapStringDynamic(
    dynamic json, {
    bool ensureUniqueKey = false,
  }) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) return json;
    if (json is Map<dynamic, dynamic>) {
      if (ensureUniqueKey) {
        final Map<String, dynamic> result = <String, dynamic>{};
        json.forEach((dynamic key, dynamic value) {
          result.putIfAbsent(key.toString(), () => value);
        });
        return result;
      }
      return json.map(
        (dynamic key, dynamic value) => MapEntry<String, dynamic>(key.toString(), value),
      );
    }
    return null;
  }
}
