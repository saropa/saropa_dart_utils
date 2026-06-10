import 'package:characters/characters.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// String More: strip leading/trailing substring, join lines, wrap at N, capitalize sentence, swap case, etc. Roadmap #251-265.
extension StringMoreExtensions on String {
  /// Removes leading and trailing occurrences of [substring] until none remain.
  @useResult
  String stripSubstring(String substring) {
    // An empty substring must short-circuit: startsWith('') / endsWith('') are
    // always true, so the loops below would never terminate.
    if (substring.isEmpty) return this;
    String current = this;
    // Peel repeated leading copies, then repeated trailing copies, so e.g.
    // stripping "ab" from "abababXabab" removes every bounding copy, not just one.
    while (current.startsWith(substring)) {
      current = current.substringSafe(substring.length);
    }
    while (current.endsWith(substring)) {
      current = current.substringSafe(0, current.length - substring.length);
    }
    return current;
  }

  /// Joins lines (split by newline) with [separator]. Default separator is newline (no-op).
  @useResult
  String joinLines([String separator = '\n']) => split('\n').join(separator);

  /// Wraps this string at [width] character boundaries (grapheme-safe). Returns chunks joined by newline.
  @useResult
  String wrapAtChars(int width) {
    // A width below one has no sensible chunk size, and a string already within
    // the width needs no wrapping — return it unchanged in both cases.
    if (width < 1) return this;
    // Measure and slice in grapheme clusters (Characters), not code units, so an
    // emoji or combining mark is never split across a line boundary.
    final Characters charSeq = characters;
    if (charSeq.length <= width) return this;
    // Pre-size the parts list to the exact ceil(length/width) so it is filled by
    // index without intermediate growth.
    final int partCount = (charSeq.length / width).ceil();
    final List<String> parts = List<String>.filled(partCount, '');
    for (int i = 0; i < partCount; i++) {
      // Clamp the final chunk's end to the sequence length so the last (short)
      // line does not read past the end.
      final int start = i * width;
      final int end = (start + width) > charSeq.length ? charSeq.length : start + width;
      parts[i] = charSeq.getRange(start, end).string;
    }
    return parts.join('\n');
  }

  /// Capitalizes the first letter after sentence boundaries (start or after `. `).
  @useResult
  String capitalizeSentences() {
    if (isEmpty) return this;
    final RegExp re = RegExp(r'(^|\.\s+)([a-z])');
    return replaceAllMapped(
      re,
      (Match m) {
        final prefixGroup = m[1];
        final letterGroup = m[2];
        return '${prefixGroup ?? ''}${(letterGroup ?? '').toUpperCase()}';
      },
    );
  }

  /// Swaps upper-case and lower-case for each character.
  @useResult
  String swapCase() => split(
    '',
  ).map((String ch) => ch.toUpperCase() == ch ? ch.toLowerCase() : ch.toUpperCase()).join();

  /// Collapses runs of the same character into one, keeping order.
  ///
  /// Operates on UTF-16 code units, so it does not merge multi-unit emoji.
  ///
  /// Example:
  /// ```dart
  /// 'aaabbbccaa'.removeRepeatedChars(); // 'abca'
  /// ```
  @useResult
  String removeRepeatedChars() {
    if (length <= 1) return this;
    final StringBuffer sb = StringBuffer(this[0]);
    for (int i = 1; i < length; i++) {
      if (this[i] != this[i - 1]) sb.write(this[i]);
    }
    return sb.toString();
  }

  /// Counts non-overlapping occurrences of [substring] in this string.
  ///
  /// Returns 0 when [substring] is empty. Matches are consumed left to right,
  /// so overlaps are not double-counted.
  ///
  /// Example:
  /// ```dart
  /// 'aaaa'.countOccurrences('aa'); // 2
  /// ```
  int countOccurrences(String substring) {
    if (substring.isEmpty) return 0;
    int count = 0;
    int i = 0;
    while (true) {
      i = indexOf(substring, i);
      if (i == -1) break;
      count++;
      i += substring.length;
    }
    return count;
  }

  /// Returns all start indices where [substring] occurs (non-overlapping).
  List<int> allIndicesOf(String substring) {
    // An empty needle has no well-defined positions, so report none.
    if (substring.isEmpty) return <int>[];
    // Pre-size to the maximum possible non-overlapping match count (string length
    // divided by needle length, plus one slack) to fill a fixed list rather than
    // grow it; the trailing sublist trims the unused tail. The `> 0 ? : 1` is a
    // defensive guard against division by zero even though the empty case already
    // returned above.
    final int maxOccurrences = length ~/ (substring.length > 0 ? substring.length : 1) + 1;
    final List<int> out = List<int>.filled(maxOccurrences, 0);
    int i = 0;
    int idx = 0;
    // Advance past each match by the needle length so overlapping matches are not
    // counted twice (e.g. "aa" in "aaaa" reports indices 0 and 2, not 0,1,2).
    while (true) {
      i = indexOf(substring, i);
      if (i == -1) break;
      out[idx++] = i;
      i += substring.length;
    }
    return out.sublist(0, idx);
  }

  /// Returns true if this string reads the same forwards and backwards (optionally ignoring case/punctuation).
  @useResult
  bool isPalindrome({bool ignoreCase = true, bool ignorePunctuation = false}) {
    // Normalize per the flags first, then compare with two cursors moving inward
    // from both ends; one mismatch disproves it. The cursors meeting (i >= j)
    // means every mirrored pair matched.
    String normalized = this;
    if (ignoreCase) normalized = normalized.toLowerCase();
    if (ignorePunctuation) normalized = normalized.replaceAll(RegExp(r'[^\w]'), '');
    for (int i = 0, j = normalized.length - 1; i < j; i++, j--) {
      if (normalized[i] != normalized[j]) return false;
    }
    return true;
  }

  /// Reverses the order of words (split on whitespace).
  @useResult
  String reverseWords() => split(RegExp(r'\s+')).reversed.join(' ');

  /// Returns the first [n] words (split on whitespace). Returns empty string if n <= 0.
  @useResult
  String firstNWords(int n) {
    if (n <= 0) return '';
    final List<String> words = trim().split(RegExp(r'\s+'));
    return words.take(n).join(' ');
  }

  /// Returns the last [n] words (split on whitespace), preserving their order.
  ///
  /// Returns the empty string when [n] is `<= 0`, and the whole trimmed string
  /// when it has [n] or fewer words.
  ///
  /// Example:
  /// ```dart
  /// 'the quick brown fox'.lastNWords(2); // 'brown fox'
  /// ```
  @useResult
  String lastNWords(int n) {
    if (n <= 0) return '';
    final List<String> words = trim().split(RegExp(r'\s+'));
    if (words.length <= n) return words.join(' ');
    return words.sublist(words.length - n).join(' ');
  }

  /// Pads this string to [width] with [padChar], on the left if [padLeft] else right.
  @useResult
  String padToWidth(int width, {bool padLeft = true, String padChar = ' '}) {
    if (length >= width) return this;
    final String pad = padChar * (width - length);
    return padLeft ? pad + this : this + pad;
  }

  /// Removes HTML comments (<!-- ... -->) from this string.
  @useResult
  String stripHtmlComments() => replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
}
