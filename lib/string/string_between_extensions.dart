/// Extension methods for extracting content between delimiters.
extension StringBetweenExtensions on String {
  /// Extracts content between bracket pairs.
  ///
  /// Tries parentheses, square brackets, angle brackets, and curly braces in order.
  /// Returns a tuple of (content between brackets, remaining string after removal).
  (String, String?)? betweenBracketsResult() {
    if (isEmpty) return null;
    return betweenResult('(', ')') ??
        betweenResult('[', ']') ??
        betweenResult('<', '>') ??
        betweenResult('{', '}');
  }

  /// Same as [betweenBracketsResult] but searches from the end.
  (String, String?)? betweenBracketsResultLast() {
    if (isEmpty) return null;
    return betweenResultLast('(', ')') ??
        betweenResultLast('[', ']') ??
        betweenResultLast('<', '>') ??
        betweenResultLast('{', '}');
  }

  /// Gets content between bracket pairs.
  ///
  /// Tries parentheses, square brackets, angle brackets, and curly braces in order.
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

  /// Removes all content between [start] and [end] delimiters.
  ///
  /// If [inclusive] is true (default), removes the delimiters as well.
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

  /// Extracts all sections between [start] and [end] delimiters.
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

  /// Extracts content between [start] and [end] delimiters.
  ///
  /// Returns a tuple of (content between delimiters, remaining string after removal).
  /// Uses `lastIndexOf` for the end delimiter to capture the outermost pair,
  /// which correctly handles nested delimiters like `(a(test)b)` → `a(test)b`.
  (String, String?)? betweenResult(
    String start,
    String end, {
    bool endOptional = true,
    bool trim = true,
  }) {
    if (isEmpty || start.isEmpty || end.isEmpty) return null;
    final int startIndex = indexOf(start);
    if (startIndex == -1) return null;
    final int endIndex = lastIndexOf(end);
    if (endIndex == -1) return null;
    if (startIndex >= endIndex || (startIndex + start.length) > endIndex) return null;

    final String found = substring(startIndex + start.length, endIndex);
    final String remaining = substring(0, startIndex) + substring(endIndex + end.length);
    final String finalFound = trim ? found.trim() : found;
    final String finalRemaining = trim
        ? remaining.replaceAll(RegExp(r'\s+'), ' ').trim()
        : remaining;
    return (finalFound, finalRemaining.isEmpty ? '' : finalRemaining);
  }

  /// Same as [betweenResult] but searches from the end.
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

  /// Extracts content between first occurrence of [start] and [end].
  ///
  /// If [endOptional] is true and [end] is not found, returns content after [start].
  String between(String start, String end, {bool endOptional = true, bool trim = true}) {
    if (isEmpty || start.isEmpty) return '';
    final int startIndex = indexOf(start);
    if (startIndex == -1) return '';
    final int endIndex = end.isEmpty ? -1 : indexOf(end, startIndex + start.length);
    if (endIndex == -1) {
      if (endOptional) {
        final String content = substring(startIndex + start.length);
        return trim ? content.trim() : content;
      }
      return '';
    }
    final String content = substring(startIndex + start.length, endIndex);
    return trim ? content.trim() : content;
  }

  /// Extracts content between last occurrence of [start] and [end].
  ///
  /// If [endOptional] is true and [end] is not found, returns content after last [start].
  String betweenLast(String start, String end, {bool endOptional = true, bool trim = true}) {
    if (isEmpty || start.isEmpty) return '';
    final int startIndex = lastIndexOf(start);
    if (startIndex == -1) return '';
    final int endIndex = end.isEmpty ? (endOptional ? length : -1) : lastIndexOf(end);
    if (endIndex == -1 || endIndex <= startIndex || (startIndex + start.length) > endIndex) {
      if (endOptional) {
        final String content = substring(startIndex + start.length);
        return trim ? content.trim() : content;
      }
      return '';
    }
    final String content = substring(startIndex + start.length, endIndex);
    return trim ? content.trim() : content;
  }
}
