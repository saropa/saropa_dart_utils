/// Saropa extensions for [List]s of [Enum]s
///
extension EnumListExtension<T extends Enum> on Iterable<T> {
  /// Return a MapEntry with the most common value and its frequency.
  ///
  /// Dart’s type system doesn’t allow us to return a strongly typed enum
  /// from a method that works with the base Enum type. This is because
  /// Dart’s generics are invariant, which means you can’t use a subtype
  /// (like ZodiacSigns) where a base type (like Enum) is expected.
  ///
  /* HACK: SB: for you to migrate to the examples folder

    void main() {
    // Assuming you have a list of Enums
    List<Enum> list = [Enum.value1, Enum.value2, Enum.value1, Enum.value3];

    // Call the mostOccurrences method
    MapEntry<Enum, int> result = list.mostOccurrences();

    // Print the most common Enum and its frequency
    print('Most common item: ${result.key}');
    print('Frequency: ${result.value}');
  }
*/
  MapEntry<Enum, int> mostOccurrences() {
    // If the list is empty, the method will now throw an exception with
    // a descriptive error message.
    if (isEmpty) {
      throw Exception('Error: The list is empty.');
    }

    // Create a new HashMap to store each integer and its frequency.
    // In Dart, Map is an interface that HashMap implements. Using Map makes
    // code more flexible, as it can work with any class that implements Map.
    final frequencyMap = <Enum, int>{};

    // Iterate over each integer in the list.
    for (final Enum item in this) {
      // Update the frequency of the current integer in the map, or set it
      // to 1 if it's not in the map yet.
      frequencyMap.update(
        item,
        (int value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    // Find and return the key with the highest value (frequency) in the map.
    final mostCommonEntry = frequencyMap.entries.reduce(
      (MapEntry<Enum, int> a, MapEntry<Enum, int> b) =>
          a.value > b.value ? a : b,
    );

    // Return a MapEntry with the most common value and its frequency.
    // Return a MapEntry<Enum, int> to make it clear that you’re returning a
    // key-value pair, and it’s more idiomatic in Dart.
    return mostCommonEntry;
  }
}
