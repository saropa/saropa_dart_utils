/// Tokenize text into sentences and words (roadmap #404).
library;

/// Splits [text] into sentences (split on . ! ? followed by space or end).
List<String> tokenizeSentences(String text) {
  if (text.trim().isEmpty) return <String>[];
  return text
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();
}

/// Splits [text] into words (non-empty runs of letters/numbers).
List<String> tokenizeWords(String text) => text
    .split(RegExp(r'\s+'))
    .map((String s) => s.replaceAll(RegExp(r'[^\w]'), '').trim())
    .where((String s) => s.isNotEmpty)
    .toList();
