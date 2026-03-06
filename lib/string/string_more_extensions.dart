import 'package:characters/characters.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// String More: strip leading/trailing substring, join lines, wrap at N, capitalize sentence, swap case, etc. Roadmap #251-265.
extension StringMoreExtensions on String {
  /// Removes leading and trailing occurrences of [substring] until none remain.
  @useResult
  String stripSubstring(String substring) {
    if (substring.isEmpty) return this;
    String current = this;
    while (current.startsWith(substring)) current = current.substringSafe(substring.length);
    while (current.endsWith(substring))
      current = current.substringSafe(0, current.length - substring.length);
    return current;
  }

  /// Joins lines (split by newline) with [separator]. Default separator is newline (no-op).
  @useResult
  String joinLines([String separator = '\n']) => split('\n').join(separator);

  /// Wraps this string at [width] character boundaries (grapheme-safe). Returns chunks joined by newline.
  @useResult
  String wrapAtChars(int width) {
    if (width < 1) return this;
    final Characters charSeq = characters;
    if (charSeq.length <= width) return this;
    final int partCount = (charSeq.length / width).ceil();
    final List<String> parts = List<String>.filled(partCount, '');
    for (int i = 0; i < partCount; i++) {
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
        return '${prefixGroup ?? ''}${(letterGroup != null ? letterGroup : '').toUpperCase()}';
      },
    );
  }

  /// Swaps upper-case and lower-case for each character.
  @useResult
  String swapCase() => split(
    '',
  ).map((String ch) => ch.toUpperCase() == ch ? ch.toLowerCase() : ch.toUpperCase()).join();

  @useResult
  String removeRepeatedChars() {
    if (length <= 1) return this;
    final StringBuffer sb = StringBuffer(this[0]);
    for (int i = 1; i < length; i++) {
      if (this[i] != this[i - 1]) sb.write(this[i]);
    }
    return sb.toString();
  }

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
    if (substring.isEmpty) return <int>[];
    final int maxOccurrences = length ~/ (substring.length > 0 ? substring.length : 1) + 1;
    final List<int> out = List<int>.filled(maxOccurrences, 0);
    int i = 0;
    int idx = 0;
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
