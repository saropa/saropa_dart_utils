import 'package:meta/meta.dart';

/// Run-length encode/decode for iterables.
extension RunLengthEncodeExtensions<T> on Iterable<T> {
  /// Run-length encodes this iterable into (value, count) pairs.
  ///
  /// Example:
  /// ```dart
  /// [1, 1, 2, 2, 2].runLengthEncode(); // [(1, 2), (2, 3)]
  /// ```
  @useResult
  List<(T, int)> runLengthEncode() {
    final List<(T, int)> result = <(T, int)>[];
    T? prev;
    int count = 0;
    for (final T element in this) {
      if (prev == null || element != prev) {
        if (prev != null) result.add((prev, count));
        prev = element;
        count = 1;
      } else {
        count++;
      }
    }
    if (prev != null) result.add((prev, count));
    return result;
  }
}

/// Run-length decode: expand (value, count) pairs into a list.
///
/// Example:
/// ```dart
/// runLengthDecode([(1, 2), (2, 3)]); // [1, 1, 2, 2, 2]
/// ```
List<T> runLengthDecode<T>(Iterable<(T, int)> pairs) {
  final List<T> result = <T>[];
  for (final (T value, int count) in pairs) {
    for (int i = 0; i < count; i++) result.add(value);
  }
  return result;
}
