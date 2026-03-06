/// Code block detector/extractor from mixed text (roadmap #422).
library;

/// Extracts first fenced code block (```lang\n...\n```) or returns null.
String? extractFirstCodeBlock(String text) {
  final RegExp fenced = RegExp(r'```[\w]*\n([\s\S]*?)```');
  final Match? m = fenced.firstMatch(text);
  return m != null ? m.group(1)?.trim() : null;
}

/// Returns all fenced code blocks as list of (language, code).
List<(String, String)> extractAllCodeBlocks(String text) {
  final RegExp fenced = RegExp(r'```(\w*)\n([\s\S]*?)```');
  return fenced
      .allMatches(text)
      .map((Match m) => (m.group(1) ?? '', (m.group(2) ?? '').trim()))
      .toList();
}
