import 'package:meta/meta.dart';

const String _kErrPatternNotEmpty = 'pattern must not be empty';
const String _kParamPattern = 'pattern';

/// Replace first N or last occurrence.
extension StringReplaceNExtensions on String {
  /// Replaces the first [n] occurrences of [pattern] with [replacement].
  ///
  /// If [n] is 0 or negative, returns this string unchanged. If [n] is null or omitted, replaces all.
  /// [pattern] must not be empty.
  ///
  /// Throws [ArgumentError] if [pattern] is empty.
  ///
  /// Example:
  /// ```dart
  /// 'a-b-c'.replaceFirstN('-', '_', 2);  // 'a_b_c'
  /// 'a-b-c'.replaceFirstN('-', '_', 1);  // 'a_b-c'
  /// ```
  @useResult
  String replaceFirstN(String pattern, String replacement, [int? n]) {
    if (pattern.isEmpty) {
      throw ArgumentError(_kErrPatternNotEmpty, _kParamPattern);
    }
    if (n != null && n <= 0) return this;
    if (isEmpty) return this;
    int count = 0;
    final int? limit = n;
    String result = this;
    int index = result.indexOf(pattern);
    while (index >= 0 && (limit == null || count < limit)) {
      result = result.replaceRange(index, index + pattern.length, replacement);
      count++;
      index = result.indexOf(pattern, index + replacement.length);
    }
    return result;
  }

  /// Replaces only the last occurrence of [pattern] with [replacement].
  ///
  /// Returns this string if [pattern] is not found or empty. [pattern] must not be empty.
  ///
  /// Throws [ArgumentError] if [pattern] is empty.
  ///
  /// Example:
  /// ```dart
  /// 'a-b-c'.replaceLast('-', '_');  // 'a-b_c'
  /// ```
  @useResult
  String replaceLast(String pattern, String replacement) {
    if (pattern.isEmpty) {
      throw ArgumentError(_kErrPatternNotEmpty, _kParamPattern);
    }
    final int i = lastIndexOf(pattern);
    if (i < 0) return this;
    return replaceRange(i, i + pattern.length, replacement);
  }
}
