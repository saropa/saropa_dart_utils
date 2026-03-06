import 'package:meta/meta.dart';

/// Rotate list left or right.
extension ListRotateExtensions<T> on List<T> {
  /// Returns a new list rotated left by [n] (positive) or right by -[n].
  ///
  /// [n] may be negative; rotation is modulo length. Empty list returns empty.
  @useResult
  List<T> rotate(int n) {
    if (isEmpty) return toList();
    final int len = length;
    final int k = n % len;
    if (k == 0) return toList();
    final int shift = k < 0 ? len + k : k;
    return <T>[...sublist(shift), ...sublist(0, shift)];
  }
}
