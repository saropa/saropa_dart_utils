import 'package:meta/meta.dart';

const String _kErrSubstringNotEmpty = 'substring must not be empty';
const String _kParamSubstring = 'substring';

/// Highlight (wrap) substring matches.
extension StringHighlightExtensions on String {
  /// Wraps each occurrence of [substring] with [before] and [after].
  ///
  /// Matching is case-sensitive. Overlapping matches are not merged.
  /// [substring] must not be empty.
  ///
  /// Returns a new string with each occurrence of [substring] wrapped.
  ///
  /// Throws [ArgumentError] if [substring] is empty.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.highlightSubstring(substring: 'o', before: '<', after: '>');  // 'hell<o> w<o>rld'
  /// ```
  @useResult
  String highlightSubstring({
    required String substring,
    required String before,
    required String after,
  }) {
    if (substring.isEmpty) {
      throw ArgumentError(_kErrSubstringNotEmpty, _kParamSubstring);
    }
    if (isEmpty) return this;
    return replaceAll(substring, '$before$substring$after');
  }
}
