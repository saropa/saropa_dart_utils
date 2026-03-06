import 'package:meta/meta.dart';

final RegExp _regexSpecialChars = RegExp(r'[.*+?^${}()|[\]\\]');

/// Extensions for regex-related string operations.
extension StringRegexExtensions on String {
  /// Escapes this string for use as a literal inside a [RegExp].
  ///
  /// Returns a new string with regex metacharacters backslash-escaped so that
  /// the resulting pattern matches this string literally. Uses a non-null
  /// fallback for each match so the result never contains the literal "null".
  ///
  /// Example:
  /// ```dart
  /// r'$10.00'.escapeForRegex();  // r'\$10\.00'
  /// 'a+b'.escapeForRegex();      // r'a\+b'
  /// ```
  @useResult
  String escapeForRegex() {
    if (isEmpty) return this;
    return replaceAllMapped(
      _regexSpecialChars,
      (Match m) => '\\${m.group(0) ?? ''}',
    );
  }
}
