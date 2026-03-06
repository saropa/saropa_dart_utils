import 'package:meta/meta.dart';

/// Default empty list/map for null. Roadmap #240, #400.
extension ListDefaultEmptyExtension<T> on List<T>? {
  /// This list, or an empty list if null.
  @useResult
  List<T> orEmpty() => this ?? <T>[];
}

/// Default empty map for null.
extension MapDefaultEmptyExtension<K, V> on Map<K, V>? {
  /// This map, or an empty map if null.
  @useResult
  Map<K, V> orEmpty() => this ?? <K, V>{};
}

/// Second/third element or null.
extension ListSecondThirdExtension<T> on List<T> {
  /// Element at index 1, or null if length < 2.
  T? get secondOrNull => length > 1 ? this[1] : null;

  /// Element at index 2, or null if length < 3.
  T? get thirdOrNull => length > 2 ? this[2] : null;
}
