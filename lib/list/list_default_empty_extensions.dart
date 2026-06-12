import 'package:meta/meta.dart';

/// Default empty list/map for null. Roadmap #240, #400.
extension ListDefaultEmptyExtension<T> on List<T>? {
  /// This list, or an empty list if null.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  List<T> orEmpty() => this ?? <T>[];
}

/// Default empty map for null.
extension MapDefaultEmptyExtension<K, V> on Map<K, V>? {
  /// This map, or an empty map if null.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Map<K, V> orEmpty() => this ?? <K, V>{};
}

/// Second/third element or null.
extension ListSecondThirdExtension<T> on List<T> {
  /// Element at index 1, or null if length < 2.
  /// Audited: 2026-06-12 11:26 EDT
  T? get secondOrNull => length > 1 ? this[1] : null;

  /// Element at index 2, or null if length < 3.
  /// Audited: 2026-06-12 11:26 EDT
  T? get thirdOrNull => length > 2 ? this[2] : null;
}
