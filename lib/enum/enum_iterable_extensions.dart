import 'package:collection/collection.dart';

/// Saropa extensions for [List]s of [Enum]s
///
extension EnumIterableExtensions<T extends Enum> on Iterable<T> {
  /// Return a MapEntry with the most common value and its frequency.
  ///
  /// Dart’s type system doesn’t allow us to return a strongly typed enum
  /// from a method that works with the base Enum type. This is because
  /// Dart’s generics are invariant, which means you can’t use a subtype
  /// (like ZodiacSigns) where a base type (like Enum) is expected.
  ///
  MapEntry<Enum, int> mostOccurrences() {
    // If the list is empty, the method will now throw an exception with
    // a descriptive error message.
    if (isEmpty) {
      throw Exception('Error: The list is empty.');
    }

    // Create a new HashMap to store each integer and its frequency.
    // In Dart, Map is an interface that HashMap implements. Using Map makes
    // code more flexible, as it can work with any class that implements Map.
    final Map<Enum, int> frequencyMap = <Enum, int>{};

    // Iterate over each integer in the list.
    for (final Enum item in this) {
      // Update the frequency of the current integer in the map, or set it
      // to 1 if it's not in the map yet.
      // ignore: require_future_error_handling
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // Find and return the key with the highest value (frequency) in the map.
    // The map is guaranteed non-empty since we checked isEmpty above.
    MapEntry<Enum, int>? mostCommonEntry;
    for (final MapEntry<Enum, int> entry in frequencyMap.entries) {
      if (mostCommonEntry == null || entry.value > mostCommonEntry.value) {
        mostCommonEntry = entry;
      }
    }

    // Return a MapEntry with the most common value and its frequency.
    // mostCommonEntry is guaranteed non-null since the list is non-empty.
    if (mostCommonEntry == null) {
      throw StateError('Unexpected null entry in non-empty frequency map');
    }
    return mostCommonEntry;
  }

  /// Finds and returns the first enum value in this list whose [name] property
  /// matches the given [name], or `null` if no such value is found.
  ///
  /// If [caseSensitive] is `true`, the comparison between the [name] property
  /// of each enum value and the given [name] is case-sensitive. Otherwise,
  /// the comparison is case-insensitive.
  ///
  /// - Parameters:
  ///   - name: The name to search for among the enum values.
  ///   - caseSensitive: Whether the comparison should be case-sensitive.
  ///
  /// - Returns: The first enum value whose [name] matches the given [name],
  ///  or `null` if no such value is found.
  T? byNameTry(String? name, {bool caseSensitive = true}) {
    if (name == null || name.isEmpty) {
      return null;
    }

    // Use a local variable to store the name for comparison
    final String comparisonName = caseSensitive ? name : name.toLowerCase();

    // Find the first enum value whose name matches the provided name
    return firstWhereOrNull(
      (T e) => caseSensitive ? e.name == comparisonName : e.name.toLowerCase() == comparisonName,
    );
  }

  /// Returns a list of enum values sorted alphabetically by name.
  ///
  /// Example:
  /// ```dart
  /// enum MyEnum { b, c, a }
  ///
  /// final sortedValues = MyEnum.values.sortedEnumValues();
  /// print(sortedValues); // prints [MyEnum.a, MyEnum.b, MyEnum.c]
  /// ```
  ///
  /// - Returns: A list of enum values sorted alphabetically by name.
  List<T> sortedEnumValues() =>
      // Map the list of enum values to a list of their names as strings
      toList()
        // Sort the list of names in alphabetical order
        ..sort((T a, T b) => a.name.compareTo(b.name));
}
