/// Markdown to plain text (strip markup, keep structure) — roadmap #420.
library;

/// Strips Markdown markup and returns plain text (headers, lists as lines).
String markdownToPlainText(String markdown) {
  String s = markdown
      .replaceAllMapped(RegExp(r'^#{1,6}\s*', multiLine: true), (_) => '')
      .replaceAll(RegExp(r'\*\*?|__?|~~|`'), '')
      .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '')
      .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '• ')
      .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
  return s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
