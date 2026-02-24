import 'package:meta/meta.dart';

/// Represents a value and its frequency count within a collection.
///
/// Used by `mostOccurrences()` and `leastOccurrences()` extension methods
/// to return both the value and how many times it appears.
///
/// Example:
/// ```dart
/// final result = [1, 2, 2, 3].mostOccurrences();
/// print(result?.value); // 2
/// print(result?.count); // 2
/// ```
@immutable
// Manual == is simpler than adding equatable dependency for one class.
// ignore: require_extend_equatable
class Occurrence<T extends Object> {
  /// Creates an [Occurrence] with the given [value] and [count].
  const Occurrence(this.value, this.count);

  /// The value that was found in the collection.
  final T value;

  /// How many times [value] appears in the collection.
  final int count;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Occurrence<T> &&
          value == other.value &&
          count == other.count;

  @override
  int get hashCode => Object.hash(value, count);

  @override
  String toString() => 'Occurrence($value, $count)';
}
