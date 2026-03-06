import 'package:meta/meta.dart';

/// CSV-style quoting (wrap in quotes and escape internal quotes).
extension StringCsvExtensions on String {
  /// Wraps this string in double quotes and doubles any internal double quotes.
  ///
  /// Returns a new string with CSV-style quoting applied.
  ///
  /// Example:
  /// ```dart
  /// 'a"b'.wrapCsvQuotes();  // '"a""b"'
  /// 'normal'.wrapCsvQuotes();  // '"normal"'
  /// ```
  @useResult
  String wrapCsvQuotes() {
    final String escaped = replaceAll('"', '""');
    return '"$escaped"';
  }
}
