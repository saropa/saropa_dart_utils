import 'package:meta/meta.dart';

final RegExp _ansiEscape = RegExp(
  r'\x1b\[[0-9;]*[a-zA-Z]|\x1b\].[^\x07]*\x07|\x1b[PX^_].*?\x1b\\',
);

/// Strip ANSI escape codes from terminal output.
extension StringAnsiExtensions on String {
  /// Removes ANSI escape sequences (e.g. color codes) from this string.
  ///
  /// Returns a new string with all ANSI escape sequences removed.
  ///
  /// Example:
  /// ```dart
  /// '\x1b[31mred\x1b[0m'.stripAnsi();  // 'red'
  /// ```
  @useResult
  String stripAnsi() {
    if (isEmpty) return this;
    return replaceAll(_ansiEscape, '');
  }
}
