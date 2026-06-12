import 'package:meta/meta.dart';

/// Run-length encode/decode for iterables.
extension RunLengthEncodeExtensions<T> on Iterable<T> {
  /// Run-length encodes this iterable into (value, count) pairs.
  ///
  /// Example:
  /// ```dart
  /// [1, 1, 2, 2, 2].runLengthEncode(); // [(1, 2), (2, 3)]
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  List<(T, int)> runLengthEncode() {
    final List<(T, int)> result = <(T, int)>[];
    // Use a `hasPrev` flag, NOT `prev == null`, as the "no previous run"
    // sentinel: when T is nullable, a real `null` element would otherwise be
    // mistaken for "no run yet", dropping/miscounting a run of nulls and
    // breaking the round-trip with runLengthDecode.
    bool hasPrev = false;
    late T prev;
    int count = 0;
    for (final T element in this) {
      if (!hasPrev || element != prev) {
        if (hasPrev) result.add((prev, count));
        prev = element;
        count = 1;
        hasPrev = true;
      } else {
        count++;
      }
    }
    if (hasPrev) result.add((prev, count));
    return result;
  }
}

/// Run-length decode: expand (value, count) pairs into a list.
///
/// Example:
/// ```dart
/// runLengthDecode([(1, 2), (2, 3)]); // [1, 1, 2, 2, 2]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<T> runLengthDecode<T>(Iterable<(T, int)> pairs) {
  final List<T> result = <T>[];
  for (final (T value, int count) in pairs) {
    for (int i = 0; i < count; i++) {
      result.add(value);
    }
  }
  return result;
}
