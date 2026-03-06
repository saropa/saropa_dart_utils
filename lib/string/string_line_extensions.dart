import 'package:meta/meta.dart';

const String _kErrTargetNonEmpty = 'target must be non-empty';
const String _kParamTarget = 'target';

/// Extensions for line-based string operations (line breaks, BOM, indent).
extension StringLineExtensions on String {
  /// Normalizes line breaks to [target] (default `\n`).
  ///
  /// Replaces CRLF (`\r\n`), CR (`\r`), and LF (`\n`) with a single [target] character.
  /// [target] must not be null.
  ///
  /// Returns a new string with normalized line breaks.
  ///
  /// Throws [ArgumentError] if [target] is empty.
  ///
  /// Example:
  /// ```dart
  /// 'a\r\nb\rc\n'.normalizeLineBreaks();  // 'a\nb\nc\n'
  /// 'a\r\nb'.normalizeLineBreaks('\r\n'); // 'a\r\nb' (CRLF)
  /// ```
  @useResult
  String normalizeLineBreaks([String target = '\n']) {
    if (target.isEmpty) {
      throw ArgumentError(_kErrTargetNonEmpty, _kParamTarget);
    }
    if (isEmpty) return this;
    return replaceAll(RegExp(r'\r\n|\r|\n'), target);
  }

  /// Removes the UTF-8 BOM (U+FEFF) from the start of this string if present.
  ///
  /// Returns this string without a leading BOM, or unchanged if none.
  ///
  /// Example:
  /// ```dart
  /// '\uFEFFhello'.stripBom(); // 'hello'
  /// 'hello'.stripBom();       // 'hello'
  /// ```
  @useResult
  String stripBom() {
    if (isEmpty) return this;
    if (startsWith('\uFEFF')) return replaceRange(0, 1, '');
    return this;
  }

  /// Splits this string into lines, normalizing CRLF/CR/LF to a single newline first.
  ///
  /// Returns a list of lines without the line break characters. Empty string yields `['']`.
  ///
  /// Example:
  /// ```dart
  /// 'a\nb\r\nc'.splitIntoLines(); // ['a', 'b', 'c']
  /// ''.splitIntoLines();          // ['']
  /// ```
  @useResult
  List<String> splitIntoLines() {
    if (isEmpty) return const <String>[''];
    return normalizeLineBreaks().split('\n');
  }
}
