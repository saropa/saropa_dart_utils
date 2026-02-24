import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Saropa extensions for [List]s of [Enum]s
///
extension EnumIterableExtensions<T extends Enum> on Iterable<T> {
  /// Returns a [MapEntry] with the most common value and its frequency,
  /// or `null` if the iterable is empty.
  ///
  /// Dart's type system doesn’t allow us to return a strongly typed enum
  /// from a method that works with the base Enum type. This is because
  /// Dart's generics are invariant, which means you can’t use a subtype
  /// (like ZodiacSigns) where a base type (like Enum) is expected.
  @useResult
  MapEntry<Enum, int>? mostOccurrences() {
    if (isEmpty) {
      return null;
    }

    final Map<Enum, int> frequencyMap = <Enum, int>{};

    for (final Enum item in this) {
      // Map.update is called for in-place mutation; no Future is involved
      // ignore: require_future_error_handling
      frequencyMap.update(item, (int value) => value + 1, ifAbsent: () => 1);
    }

    // The map is guaranteed non-empty since we checked isEmpty above.
    MapEntry<Enum, int>? mostCommonEntry;
    for (final MapEntry<Enum, int> entry in frequencyMap.entries) {
      if (mostCommonEntry == null || entry.value > mostCommonEntry.value) {
        mostCommonEntry = entry;
      }
    }

    return mostCommonEntry;
  }

  /// Finds and returns the first enum value in this list whose [name] property
  /// matches the given [name], or `null` if no such value is found.
  ///
  /// If [isCaseSensitive] is `true`, the comparison between the [name] property
  /// of each enum value and the given [name] is case-sensitive. Otherwise,
  /// the comparison is case-insensitive.
  ///
  /// - Parameters:
  ///   - name: The name to search for among the enum values.
  ///   - isCaseSensitive: Whether the comparison should be case-sensitive.
  ///
  /// - Returns: The first enum value whose [name] matches the given [name],
  ///  or `null` if no such value is found.
  @useResult
  T? byNameTry(String? name, {bool isCaseSensitive = true}) {
    if (name == null || name.isEmpty) {
      return null;
    }

    // Use a local variable to store the name for comparison
    final String comparisonName = isCaseSensitive ? name : name.toLowerCase();

    // Find the first enum value whose name matches the provided name
    return firstWhereOrNull(
      (T e) => isCaseSensitive ? e.name == comparisonName : e.name.toLowerCase() == comparisonName,
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
  @useResult
  List<T> sortedEnumValues() =>
      // Map the list of enum values to a list of their names as strings
      toList()
        // Sort the list of names in alphabetical order
        ..sort((T a, T b) => a.name.compareTo(b.name));
}
