/// Tokenize text into sentences and words (roadmap #404).
library;

/// Splits [text] into sentences (split on . ! ? followed by space or end).
/// Audited: 2026-06-12 11:26 EDT
List<String> tokenizeSentences(String text) {
  // Whitespace-only input has no sentences; guard so the split below cannot
  // emit a single empty token.
  if (text.trim().isEmpty) return <String>[];
  // The lookbehind splits on whitespace that follows a terminator (. ! ?) so the
  // punctuation stays attached to the sentence it ends rather than being consumed
  // by the split. Trim each piece and drop any that became empty.
  return text
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();
}

/// Splits [text] into words (non-empty runs of letters/numbers).
/// Audited: 2026-06-12 11:26 EDT
List<String> tokenizeWords(String text) => text
    .split(RegExp(r'\s+'))
    .map((String s) => s.replaceAll(RegExp(r'[^\w]'), '').trim())
    .where((String s) => s.isNotEmpty)
    .toList();
