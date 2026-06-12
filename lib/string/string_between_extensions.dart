import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/between_result.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Extension methods for extracting content between delimiters.
extension StringBetweenExtensions on String {
  /// Returns a [BetweenResult] of (content between brackets, remaining string)
  /// for the first matching bracket pair found.
  ///
  /// Tries parentheses, square brackets, angle brackets, and curly braces in
  /// order. Returns `null` if no bracket pairs are found.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  BetweenResult? betweenBracketsResult() {
    if (isEmpty) {
      return null;
    }

    return ((betweenResult('(', ')') ?? betweenResult('[', ']')) ??
        (betweenResult('<', '>') ?? betweenResult('{', '}')));
  }

  /// Returns a [BetweenResult] like `betweenBracketsResult` but searches from
  /// the end.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  BetweenResult? betweenBracketsResultLast() {
    if (isEmpty) {
      return null;
    }

    return ((betweenResultLast('(', ')') ?? betweenResultLast('[', ']')) ??
        (betweenResultLast('<', '>') ?? betweenResultLast('{', '}')));
  }

  /// Returns the content between the first matching bracket pair found, or
  /// `null` if none is found.
  ///
  /// Tries parentheses, square brackets, angle brackets, and curly braces in
  /// order.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String? betweenBrackets() {
    if (isEmpty) {
      return null;
    }

    // Try each bracket family in priority order, returning the first non-empty
    // result. Empty content is skipped so "()" doesn't shadow a later "[x]".
    final String parens = between('(', ')');
    if (parens.isNotEmpty) return parens;

    final String squares = between('[', ']');
    if (squares.isNotEmpty) return squares;

    final String angles = between('<', '>');
    if (angles.isNotEmpty) return angles;

    final String curlies = between('{', '}');
    if (curlies.isNotEmpty) return curlies;

    return null;
  }

  /// Returns a new string with all content between [start] and [end]
  /// delimiters removed.
  ///
  /// If [inclusive] is `true` (default), the delimiters themselves are also
  /// removed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String removeBetweenAll(String start, String end, {bool inclusive = true}) {
    if (start.isEmpty) {
      return this;
    }

    if (this == start + end && inclusive) {
      return '';
    }

    // endOptional:false so we only act on a real, closed start..end pair.
    final String found = between(start, end, endOptional: false);
    // Empty content with no literal "startend" adjacency: nothing to strip unless
    // start and end exist separately in order. If they don't, return unchanged so
    // a lone start (or out-of-order delimiters) is never partially mangled.
    if (found.isEmpty && !contains(start + end)) {
      if (contains(start) && contains(end) && indexOf(start) < indexOf(end)) {
        if (inclusive && this == start + end) {
          return '';
        }
      } else {
        return this;
      }
    }
    // Reconstruct the literal span to delete: with the delimiters when inclusive,
    // just the inner content otherwise. An empty non-inclusive pattern would make
    // replaceAll a no-op (or worse), so bail out and return the string untouched.
    final String pattern = inclusive ? (start + found + end) : found;
    if (pattern.isEmpty && !inclusive) {
      return this;
    }

    return replaceAll(pattern, '');
  }

  /// Returns a list of all sections found between [start] and [end]
  /// delimiters, or `null` if none are found.
  ///
  /// When [endOptional] is `true` (default), content after the last [start]
  /// delimiter is included even without a closing [end]. When [trim] is `true`
  /// (default), each extracted section is trimmed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  List<String>? betweenSplit(
    String start,
    String end, {
    bool endOptional = true,
    bool trim = true,
  }) {
    if (isEmpty) {
      return null;
    }

    final BetweenResult? found = betweenResult(
      start,
      end,
      endOptional: endOptional,
      trim: trim,
    );
    if (found == null) {
      return null;
    }

    if (found.content.isEmpty) {
      return null;
    }

    final List<String>? next = found.remaining?.betweenSplit(
      start,
      end,
      endOptional: endOptional,
      trim: trim,
    );

    return <String>[found.content, ...?next];
  }

  /// Returns a [BetweenResult] of content between [start] and [end]
  /// delimiters plus the remaining string, or `null` if not found.
  ///
  /// When [endOptional] is `true` and [end] is not found, returns the content
  /// after [start]. When [trim] is `true` (default), results are trimmed.
  ///
  /// Uses `indexOf` for [start] (first occurrence) and `lastIndexOf` for
  /// [end] (last occurrence), returning the **outermost** match.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  BetweenResult? betweenResult(
    String start,
    String end, {
    bool endOptional = false,
    bool trim = true,
  }) {
    if (isEmpty || start.isEmpty || end.isEmpty) {
      return null;
    }

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

        return finalContent.isEmpty ? null : BetweenResult(finalContent, null);
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

    return BetweenResult(
      finalFound,
      finalRemaining.isEmpty ? '' : finalRemaining,
    );
  }

  /// Returns a [BetweenResult] like `betweenResult` but searches from the end
  /// using [start] and [end] delimiters.
  ///
  /// When [endOptional] is `true` (default) and [end] is not found, returns
  /// content after the last [start]. When [trim] is `true` (default), results
  /// are trimmed.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  BetweenResult? betweenResultLast(
    String start,
    String end, {
    bool endOptional = true,
    bool trim = true,
  }) {
    if (isEmpty) {
      return null;
    }

    final String found = betweenLast(start, end, endOptional: endOptional, trim: trim);
    if (found.isEmpty) {
      return null;
    }

    final String removed = replaceFirst(start + found + end, '');
    final String remaining = trim ? removed.replaceAll(RegExp(r'\s+'), ' ').trim() : removed;

    return BetweenResult(found, remaining);
  }

  /// Returns the content between the first occurrence of [start] and [end].
  ///
  /// If [endOptional] is `true` (default) and [end] is not found, returns
  /// content after [start]. When [trim] is `true` (default), the result is
  /// trimmed. Returns an empty string if no match is found.
  ///
  /// An empty [end] is treated the same as a delimiter that is *not found*: it
  /// never matches, so the [endOptional] rules apply. With the default
  /// `endOptional: true` this returns everything after [start]; with
  /// `endOptional: false` it returns an empty string. (BUG-029)
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String between(String start, String end, {bool endOptional = true, bool trim = true}) {
    if (isEmpty || start.isEmpty) {
      return '';
    }

    final int startIndex = indexOf(start);
    if (startIndex == -1) {
      return '';
    }

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
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String betweenLast(String start, String end, {bool endOptional = true, bool trim = true}) {
    if (isEmpty || start.isEmpty) {
      return '';
    }

    final int startIndex = lastIndexOf(start);
    if (startIndex == -1) {
      return '';
    }

    // An empty end can't be located: treat it as "to end of string" when optional,
    // otherwise as not-found (-1) so the guards below fall through to the no-match path.
    final int endIndex = end.isEmpty ? (endOptional ? length : -1) : lastIndexOf(end);
    final bool noEnd = endIndex == -1;
    // end must come strictly after start, and start's own delimiter must not
    // run past end (overlap), or there's no valid inner span between them.
    final bool endBeforeStart = endIndex <= startIndex;
    final bool contentOverlaps = (startIndex + start.length) > endIndex;
    if (noEnd || endBeforeStart || contentOverlaps) {
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
