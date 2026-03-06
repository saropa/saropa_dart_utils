import 'package:meta/meta.dart';

const String _kErrPatternNotEmpty = 'pattern must not be empty';
const String _kParamPattern = 'pattern';

/// Split options that keep delimiters.
extension StringSplitExtensions on String {
  /// Splits by [pattern] and returns list of segments; optionally includes matches as separate elements.
  ///
  /// If [includeDelimiters] is true, the pattern matches are included after each segment (except the last).
  /// [pattern] is a [RegExp] or [String]; if String, it is interpreted as a literal.
  ///
  /// Throws [ArgumentError] if [pattern] is an empty [String].
  ///
  /// Example:
  /// ```dart
  /// 'a-b-c'.splitKeepingDelimiter('-', includeDelimiters: true);  // ['a', '-', 'b', '-', 'c']
  /// ```
  @useResult
  List<String> splitKeepingDelimiter(Pattern pattern, {bool includeDelimiters = false}) {
    if (isEmpty) return <String>[];
    if (pattern is String && pattern.isEmpty) {
      throw ArgumentError(_kErrPatternNotEmpty, _kParamPattern);
    }
    final List<Match> matches = pattern.allMatches(this).toList();
    final int matchCount = matches.length;
    final int capacity = 1 + matchCount + (includeDelimiters ? matchCount : 0);
    final List<String> result = List<String>.filled(capacity, '');
    int start = 0;
    int idx = 0;
    for (final Match m in matches) {
      result[idx++] = substring(start, m.start);
      if (includeDelimiters) {
        final delim = m.group(0);
        if (delim != null) result[idx++] = delim;
      }
      start = m.end;
    }
    result[idx] = substring(start);
    return result.sublist(0, idx + 1);
  }
}
