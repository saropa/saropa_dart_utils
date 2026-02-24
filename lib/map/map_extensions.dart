import 'dart:math';
import 'package:meta/meta.dart';

/// Closing bracket with trailing comma for list display in
/// [StringMapExtensions.formatMap].
const String _listClosingBracket = '],\n';

/// Extension methods for generic maps.
extension MapExtensions<K, V> on Map<K, V> {
  /// Returns this map, or `null` if it is empty.
  @useResult
  Map<K, V>? nullIfEmpty() => isEmpty ? null : this;

  /// Returns up to [count] random entries from this map, excluding any keys
  /// present in [ignoreList].
  ///
  /// Returns `null` if no eligible entries remain after exclusion.
  @useResult
  List<MapEntry<K, V>>? getRandomListExcept({
    required int count,
    required List<K>? ignoreList,
  }) {
    final Set<K> ignore = ignoreList?.toSet() ?? <K>{};
    final List<MapEntry<K, V>> available = entries
        .where((MapEntry<K, V> e) => !ignore.contains(e.key))
        .toList();
    if (available.isEmpty) {
      return null;
    }

    available.shuffle(Random());

    return available.take(count).toList();
  }
}

/// Extension methods for String-keyed dynamic maps.
extension StringMapExtensions on Map<String, dynamic> {
  /// Returns a human-readable string representation of this map with
  /// indentation.
  @useResult
  String formatMap() {
    if (isEmpty) {
      return '';
    }

    const String indent = '  ';
    final StringBuffer buffer = StringBuffer('{\n');
    forEach(
      (String mapKey, dynamic mapValue) {
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
          buffer.write(_listClosingBracket);
        } else {
          buffer.write(mapValue);
          buffer.write(',\n');
        }
      },
    );
    buffer.write('}');

    return buffer.toString();
  }

  /// Returns the value for [childKey] as a `String`, or `null` if the key is
  /// missing or the value is not a `String`.
  @useResult
  String? getChildString(String childKey) {
    final dynamic value = this[childKey];

    return value is String ? value : null;
  }

  /// Returns the nested value at [childKey] → [grandChildKey], or `null` if
  /// either key is missing or the child is not a map.
  @useResult
  dynamic getGrandchild(String childKey, String grandChildKey) {
    final dynamic child = this[childKey];
    if (child is Map<dynamic, dynamic>) {
      return child[grandChildKey];
    }

    return null;
  }

  /// Returns the nested value at [childKey] → [grandChildKey] as a `String`,
  /// or `null` if either key is missing or the value is not a `String`.
  @useResult
  String? getGrandchildString(String childKey, String grandChildKey) {
    final dynamic value = getGrandchild(childKey, grandChildKey);

    return value is String ? value : null;
  }

  /// Returns the nested value at [childKey] → [grandChildKey] →
  /// [greatGrandChildKey], or `null` if any key is missing.
  @useResult
  dynamic getGreatGrandchild({
    required String childKey,
    required String grandChildKey,
    required String greatGrandChildKey,
  }) {
    final dynamic grandChild = getGrandchild(childKey, grandChildKey);
    if (grandChild is Map<dynamic, dynamic>) {
      return grandChild[greatGrandChildKey];
    }

    return null;
  }

  /// Returns the nested value at [childKey] → [grandChildKey] →
  /// [greatGrandChildKey] as a `String`, or `null` if any key is missing or
  /// the value is not a `String`.
  @useResult
  String? getGreatGrandchildString({
    required String childKey,
    required String grandChildKey,
    required String greatGrandChildKey,
  }) {
    final dynamic value = getGreatGrandchild(childKey: childKey, grandChildKey: grandChildKey, greatGrandChildKey: greatGrandChildKey);

    return value is String ? value : null;
  }

  /// Returns the value for [key] as a `Map<String, dynamic>`, or `null` if the
  /// key is missing or the value cannot be converted.
  @useResult
  Map<String, dynamic>? getValue(String? key) {
    if (isEmpty || key == null) {
      return null;
    }

    final dynamic value = this[key];

    return MapUtils.toMapStringDynamic(value);
  }

  /// Returns `true` after removing all keys in [removeKeysList] from this map.
  ///
  /// When [recurseChildValues] is `true` (default), keys are also removed from
  /// nested `Map<String, dynamic>` values.
  @useResult
  bool removeKeys(List<String>? removeKeysList, {bool recurseChildValues = true}) {
    if (removeKeysList == null || removeKeysList.isEmpty) {
      return false;
    }

    removeWhere((String key, _) => removeKeysList.contains(key));
    if (recurseChildValues) {
      // ignore: require_future_error_handling
      updateAll(
        (String _, dynamic value) {
          // Recursive call mutates child map in-place; return value not needed
          // ignore: unused_result
          if (value is Map<String, dynamic>) value.removeKeys(removeKeysList);

          return value;
        },
      );
    }

    return true;
  }

  /// Returns a new `Map<String, dynamic>` with keys sorted alphabetically.
  @useResult
  Map<String, dynamic> toKeySorted() => Map<String, dynamic>.fromEntries(
    entries.toList()..sort(
      (MapEntry<String, dynamic> a, MapEntry<String, dynamic> b) => a.key.compareTo(b.key),
    ),
  );
}

/// Utility class for map operations.
abstract final class MapUtils {
  /// Returns the total number of items across all iterable values in
  /// [inputMap].
  @useResult
  static int countItems<K, V>(Map<K, Iterable<V>> inputMap) =>
      inputMap.values.fold<int>(0, (int sum, Iterable<V> iter) => sum + iter.length);

  /// Toggles [value] in the list at [key] within [map].
  ///
  /// If [add] is `null`, toggles based on current presence.
  /// If [add] is `true`, adds the value. If `false`, removes it.
  static void mapToggleValue<K, V>({required Map<K, List<V>> map, required K key, required V value, bool? add}) {
    if (value == null) return;
    final bool shouldAdd = add ?? !mapContainsValue(map: map, key: key, value: value);
    if (shouldAdd) {
      mapAddValue(map: map, key: key, value: value);
    } else {
      mapRemoveValue(map: map, key: key, value: value);
    }
  }

  /// Adds [value] to the list at [key] within [map], creating the list if
  /// absent.
  ///
  /// Uses an immutable approach: creates a new list rather than mutating the
  /// existing one.
  ///
  /// Example:
  /// ```dart
  /// final map = <String, List<int>>{};
  /// MapUtils.mapAddValue(map: map, key: 'scores', value: 100); // {'scores': [100]}
  /// MapUtils.mapAddValue(map: map, key: 'scores', value: 200); // {'scores': [100, 200]}
  /// ```
  static void mapAddValue<K, V>({required Map<K, List<V>> map, required K key, required V value}) {
    if (value == null) return;
    // Function is designed to mutate the map parameter
    // ignore: saropa_lints/avoid_parameter_mutation
    map.update(key, (List<V> list) => [...list, value], ifAbsent: () => <V>[value]);
  }

  /// Removes all occurrences of [value] from the list at [key] within [map].
  ///
  /// Uses an immutable approach: creates a new filtered list rather than
  /// mutating the existing one.
  ///
  /// Example:
  /// ```dart
  /// final map = <String, List<int>>{'scores': [100, 200, 100]};
  /// MapUtils.mapRemoveValue(map: map, key: 'scores', value: 100); // {'scores': [200]}
  /// ```
  static void mapRemoveValue<K, V>({required Map<K, List<V>> map, required K key, required V value}) {
    if (value == null) return;
    // Function is designed to mutate the map parameter
    // ignore: saropa_lints/avoid_parameter_mutation
    map.update(
      key,
      (List<V> list) => list.where((V v) => v != value).toList(),
      ifAbsent: () => <V>[],
    );
  }

  /// Returns `true` if the list at [key] within [map] contains [value].
  @useResult
  static bool mapContainsValue<K, V>({required Map<K, List<V>> map, required K key, required V value}) {
    if (value == null) {
      return false;
    }

    return map[key]?.contains(value) ?? false;
  }

  /// Returns [json] as a `Map<String, dynamic>`, or `null` if conversion is
  /// not possible.
  ///
  /// All keys are converted to `String` via `toString()`. If the source map
  /// contains keys that produce the same string (e.g. `1` and `'1'` both
  /// become `'1'`), the last value wins by default. Pass
  /// [ensureUniqueKey] as `true` to keep the first value instead.
  @useResult
  static Map<String, dynamic>? toMapStringDynamic(
    dynamic json, {
    bool ensureUniqueKey = false,
  }) {
    if (json == null) {
      return null;
    }

    if (json is Map<String, dynamic>) {
      return json;
    }

    if (json is Map<dynamic, dynamic>) {
      if (ensureUniqueKey) {
        final Map<String, dynamic> result = <String, dynamic>{};
        json.forEach(
          (dynamic key, dynamic value) {
            // ignore: require_future_error_handling
            result.putIfAbsent(key.toString(), () => value);
          },
        );

        return result;
      }

      return json.map(
        (dynamic key, dynamic value) => MapEntry<String, dynamic>(key.toString(), value),
      );
    }

    return null;
  }
}
