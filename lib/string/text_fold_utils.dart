/// Quote-aware text folding/unfolding (email-reply style) — roadmap #412.
library;

/// Default soft-wrap column for [foldText] when no width is supplied.
const int _kDefaultFoldWidth = 78;

/// Matches a run of email quote markers at the start of a line, e.g. "> > ".
///
/// The quote prefix is one or more ">" tokens, each optionally followed by a
/// single space; this is the de-facto convention for nested email replies.
final RegExp _kQuotePrefix = RegExp(r'^(?:>\s?)+');

/// Options controlling how [foldText] hard-wraps lines.
///
/// Grouped into a single object because folding needs more than three knobs
/// while still honoring the project's parameter limit; callers tweak only the
/// fields they care about and rely on the defaults for the rest.
///
/// Example:
/// ```dart
/// const FoldOptions(width: 40);
/// ```
class FoldOptions {
  /// Creates fold options with an optional [width] (defaults to 78).
  const FoldOptions({this.width = _kDefaultFoldWidth});

  /// Maximum column width (inclusive) for each produced line, prefix included.
  final int width;
}

/// Splits a line into its quote prefix and the remaining body text.
///
/// Returns a record so callers reuse one regex pass; the prefix keeps its
/// trailing space (if present) so re-joining preserves the original spacing.
///
/// Example:
/// ```dart
/// splitQuotePrefix('> > hi'); // ('> > ', 'hi')
/// ```
(String prefix, String body) splitQuotePrefix(String line) {
  final RegExpMatch? match = _kQuotePrefix.firstMatch(line);
  if (match == null) return ('', line);
  final String prefix = match.group(0)!;
  // Strip exactly the matched prefix (anchored at ^) to get the body; using
  // replaceFirst avoids a length-based substring() and its RangeError surface.
  return (prefix, line.replaceFirst(prefix, ''));
}

/// Hard-wraps [text] to [options].width, preserving each line's quote prefix.
///
/// Why: email replies must keep "> " markers on every wrapped continuation so
/// quote depth survives folding. Words longer than the available width are
/// emitted on their own line rather than split, which avoids an infinite loop
/// when a single token already exceeds the width. Blank lines pass through as
/// paragraph separators.
///
/// Example:
/// ```dart
/// foldText('> hello world', const FoldOptions(width: 9));
/// // '> hello\n> world'
/// ```
String foldText(String text, [FoldOptions options = const FoldOptions()]) {
  // Fold each source line independently so a line's own quote depth governs
  // the prefix repeated on its continuations.
  final List<String> out = <String>[
    for (final String line in text.split('\n')) ..._foldLine(line, options.width),
  ];
  return out.join('\n');
}

/// Wraps a single [line] to [width], repeating its quote prefix per output line.
List<String> _foldLine(String line, int width) {
  final (String prefix, String body) = splitQuotePrefix(line);
  if (body.isEmpty) return <String>[line];
  // Reserve room for the prefix; clamp to >=1 so an over-wide prefix still
  // makes progress (one word per line) instead of looping forever.
  final int avail = (width - prefix.length).clamp(1, width);
  return _wrapWords(body.split(RegExp(r'\s+')), avail).map((w) => '$prefix$w').toList();
}

/// Greedily packs [words] into lines no wider than [avail] characters.
List<String> _wrapWords(List<String> words, int avail) {
  final List<String> lines = <String>[];
  String current = '';
  for (final String word in words) {
    // Start a new line when appending would overflow; a word wider than avail
    // lands alone (we never split a token) so the loop always advances.
    if (current.isEmpty) {
      current = word;
    } else if (current.length + 1 + word.length <= avail) {
      current = '$current $word';
    } else {
      lines.add(current);
      current = word;
    }
  }
  if (current.isNotEmpty) lines.add(current);
  return lines;
}

/// Joins soft-wrapped continuation lines back into one logical line per block.
///
/// Why: undoing [foldText] requires merging adjacent lines that share the same
/// quote prefix, while blank lines and quote-depth changes stay as boundaries
/// so paragraph structure and reply nesting are preserved.
///
/// Example:
/// ```dart
/// unfoldText('> hello\n> world'); // '> hello world'
/// ```
String unfoldText(String text) {
  final List<String> out = <String>[];
  String? prefix;
  String buffer = '';
  // Accumulate consecutive lines that share a prefix; flush on a prefix change
  // or a blank line so distinct quote levels and paragraphs are not merged.
  for (final String line in text.split('\n')) {
    final (String p, String body) = splitQuotePrefix(line);
    if (body.isEmpty || p != prefix) {
      _flush(out, prefix, buffer);
      prefix = body.isEmpty ? null : p;
      buffer = body.isEmpty ? '' : body;
      if (body.isEmpty) out.add(line);
    } else {
      buffer = '$buffer $body';
    }
  }
  _flush(out, prefix, buffer);
  return out.join('\n');
}

/// Emits the accumulated [buffer] (with its [prefix]) when non-empty.
void _flush(List<String> out, String? prefix, String buffer) {
  if (prefix != null && buffer.isNotEmpty) out.add('$prefix$buffer');
}
