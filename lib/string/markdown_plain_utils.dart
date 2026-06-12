/// Markdown to plain text (strip markup, keep structure) — roadmap #420.
library;

/// Strips Markdown markup and returns plain text (headers, lists as lines).
/// Audited: 2026-06-12 11:26 EDT
String markdownToPlainText(String markdown) {
  final String s = markdown
      .replaceAllMapped(RegExp(r'^#{1,6}\s*', multiLine: true), (_) => '')
      .replaceAll(RegExp(r'\*\*?|__?|~~|`'), '')
      // Strip image syntax `![alt](url)` BEFORE the link rule. Otherwise the
      // link regex rewrites the inner `[alt](url)` to `alt` and leaves a stray
      // leading `!` (e.g. `![logo](x.png)` -> `!logo`). Images drop entirely.
      .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]+\)'), '')
      .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '')
      .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '• ')
      .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
  return s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}
