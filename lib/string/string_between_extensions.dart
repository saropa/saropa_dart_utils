import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Extension methods for extracting content between delimiters.
extension StringBetweenExtensions on String {
  /// Returns a record of (content between brackets, remaining string) for the
  /// first matching bracket pair found.
  ///
  /// Tries parentheses, square brackets, angle brackets, and curly braces in
  /// order. Returns `null` if no bracket pairs are found.
  (String, String?)? betweenBracketsResult() {
    if (isEmpty) return null;
    return betweenResult('(', ')') ??
        betweenResult('[', ']') ??
        betweenResult('<', '>') ??
        betweenResult('{', '}');
  }

  /// Returns a record like `betweenBracketsResult` but searches from the end.
  (String, String?)? betweenBracketsResultLast() {
    if (isEmpty) return null;
    return betweenResultLast('(', ')') ??
        betweenResultLast('[', ']') ??
        betweenResultLast('<', '>') ??
        betweenResultLast('{', '}');
  }

  /// Returns the content between the first matching bracket pair found, or
  /// `null` if none is found.
  ///
  /// Tries parentheses, square brackets, angle brackets, and curly braces in
  /// order.
  String? betweenBrackets() {
    if (isEmpty) return null;
    String r = between('(', ')');
    if (r.isNotEmpty) return r;
    r = between('[', ']');
    if (r.isNotEmpty) return r;
    r = between('<', '>');
    if (r.isNotEmpty) return r;
    r = between('{', '}');
    if (r.isNotEmpty) return r;
    return null;
  }

  /// Returns a new string with all content between [start] and [end]
  /// delimiters removed.
  ///
  /// If [inclusive] is `true` (default), the delimiters themselves are also
  /// removed.
  String removeBetweenAll(String start, String end, {bool inclusive = true}) {
    if (start.isEmpty) return this;
    if (this == start + end && inclusive) return '';
    final String found = between(start, end, endOptional: false);
    if (found.isEmpty && !contains(start + end)) {
      if (contains(start) && contains(end) && indexOf(start) < indexOf(end)) {
        if (inclusive && this == start + end) return '';
      } else {
        return this;
      }
    }
    final String pattern = inclusive ? (start + found + end) : found;
    if (pattern.isEmpty && !inclusive) return this;
    return replaceAll(pattern, '');
  }

  /// Returns a list of all sections found between [start] and [end]
  /// delimiters, or `null` if none are found.
  ///
  /// When [endOptional] is `true` (default), content after the last [start]
  /// delimiter is included even without a closing [end]. When [trim] is `true`
  /// (default), each extracted section is trimmed.
  List<String>? betweenSplit(
    String start,
    String end, {
    bool endOptional = true,
    bool trim = true,
  }) {
    if (isEmpty) return null;
    final (String, String?)? found = betweenResult(
      start,
      end,
      endOptional: endOptional,
      trim: trim,
    );
    if (found == null) return null;
    final (String content, String? rest) = found;
    if (content.isEmpty) return null;
    final List<String> result = <String>[content];
    final List<String>? next = rest?.betweenSplit(start, end, endOptional: endOptional, trim: trim);
    if (next != null) result.addAll(next);
    return result;
  }

  /// Returns a record of (content between [start] and [end] delimiters,
  /// remaining string after the closing delimiter), or `null` if not found.
  ///
  /// When [endOptional] is `true` and [end] is not found, returns the content
  /// after [start]. When [trim] is `true` (default), results are trimmed.
  ///
  /// Uses `indexOf` for [start] (first occurrence) and `lastIndexOf` for
  /// [end] (last occurrence), returning the **outermost** match.
  (String, String?)? betweenResult(
    String start,
    String end, {
    bool endOptional = false,
    bool trim = true,
  }) {
    if (isEmpty || start.isEmpty || end.isEmpty) return null;
    final int startIndex = indexOf(start);
    if (startIndex == -1) {
      return null;
    }

    final int endIndex = lastIndexOf(end);
    if (endIndex == -1) {
      // If end is not found and it's optional, return the tail after start.
      if (endOptional) {
        final String content = substringSafe(startIndex + start.length);
        final String finalContent = trim ? content.trim() : content;
        return finalContent.isEmpty ? null : (finalContent, null);
      }
      return null;
    }

    if (startIndex >= endIndex || (startIndex + start.length) > endIndex) {
      return null;
    }

    final String found = substringSafe(startIndex + start.length, endIndex);

    final String remaining = substringSafe(0, startIndex) + substringSafe(endIndex + end.length);

    final String finalFound = trim ? found.trim() : found;

    final String finalRemaining = trim
        ? remaining.replaceAll(RegExp(r'\s+'), ' ').trim()
        : remaining;

    return (finalFound, finalRemaining.isEmpty ? '' : finalRemaining);
  }

  /// Returns a record like `betweenResult` but searches from the end using
  /// [start] and [end] delimiters.
  ///
  /// When [endOptional] is `true` (default) and [end] is not found, returns
  /// content after the last [start]. When [trim] is `true` (default), results
  /// are trimmed.
  (String, String?)? betweenResultLast(
    String start,
    String end, {
    bool endOptional = true,
    bool trim = true,
  }) {
    if (isEmpty) return null;
    final String found = betweenLast(start, end, endOptional: endOptional, trim: trim);
    if (found.isEmpty) return null;
    final String removed = replaceFirst(start + found + end, '');
    final String remaining = trim ? removed.replaceAll(RegExp(r'\s+'), ' ').trim() : removed;
    return (found, remaining);
  }

  /// Returns the content between the first occurrence of [start] and [end].
  ///
  /// If [endOptional] is `true` (default) and [end] is not found, returns
  /// content after [start]. When [trim] is `true` (default), the result is
  /// trimmed. Returns an empty string if no match is found.
  String between(String start, String end, {bool endOptional = true, bool trim = true}) {
    if (isEmpty || start.isEmpty) return '';
    final int startIndex = indexOf(start);
    if (startIndex == -1) return '';
    final int endIndex = end.isEmpty ? -1 : indexOf(end, startIndex + start.length);
    if (endIndex == -1) {
      if (endOptional) {
        final String content = substringSafe(startIndex + start.length);
        return trim ? content.trim() : content;
      }
      return '';
    }
    final String content = substringSafe(startIndex + start.length, endIndex);
    return trim ? content.trim() : content;
  }

  /// Returns the content between the last occurrence of [start] and [end].
  ///
  /// If [endOptional] is `true` (default) and [end] is not found, returns
  /// content after the last [start]. When [trim] is `true` (default), the
  /// result is trimmed. Returns an empty string if no match is found.
  String betweenLast(String start, String end, {bool endOptional = true, bool trim = true}) {
    if (isEmpty || start.isEmpty) return '';
    final int startIndex = lastIndexOf(start);
    if (startIndex == -1) return '';
    final int endIndex = end.isEmpty ? (endOptional ? length : -1) : lastIndexOf(end);
    if (endIndex == -1 || endIndex <= startIndex || (startIndex + start.length) > endIndex) {
      if (endOptional) {
        final String content = substringSafe(startIndex + start.length);
        return trim ? content.trim() : content;
      }
      return '';
    }
    final String content = substringSafe(startIndex + start.length, endIndex);
    return trim ? content.trim() : content;
  }
}
