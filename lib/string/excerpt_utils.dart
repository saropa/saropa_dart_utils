/// Smart excerpt generator: best snippet around query terms with ellipsis (roadmap #410).
library;

import 'string_extensions.dart';

/// Returns an excerpt of [text] around the first occurrence of [query], with
/// [contextChars] characters on each side and [ellipsis] at truncation points.
String excerptAround(String text, String query, {int contextChars = 60, String ellipsis = '...'}) {
  if (text.isEmpty) return '';
  final String q = query.trim();
  if (q.isEmpty) {
    if (text.length <= contextChars * 2 + 2) return text;
    final int takeFirst = contextChars.clamp(0, text.length);
    final int fromEnd = (text.length - contextChars).clamp(0, text.length);
    return '${text.substringSafe(0, takeFirst)}$ellipsis${text.substringSafe(fromEnd)}';
  }
  final int idx = text.toLowerCase().indexOf(q.toLowerCase());
  if (idx < 0) {
    if (text.length <= contextChars * 2 + 2) return text;
    final int takeFirst = contextChars.clamp(0, text.length);
    final int fromEnd = (text.length - contextChars).clamp(0, text.length);
    return '${text.substringSafe(0, takeFirst)}$ellipsis${text.substringSafe(fromEnd)}';
  }
  final int start = (idx - contextChars).clamp(0, text.length);
  final int end = (idx + q.length + contextChars).clamp(0, text.length);
  final int safeStart = start.clamp(0, text.length);
  final int safeEnd = end.clamp(0, text.length);
  final String head = start > 0 ? '$ellipsis ' : '';
  final String tail = end < text.length ? ' $ellipsis' : '';
  return '$head${text.substringSafe(safeStart, safeEnd)}$tail';
}
