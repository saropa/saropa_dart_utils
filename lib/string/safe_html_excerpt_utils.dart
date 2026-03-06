/// Safe HTML excerpt (truncate without breaking tags) — roadmap #440.
library;

import 'string_extensions.dart';

const String _kTagBr = 'br';
const String _kTagImg = 'img';

/// Truncates [html] to about [maxLength] chars, closing open tags.
String safeHtmlExcerpt(String html, int maxLength) {
  if (html.length <= maxLength) return html;
  final int len = maxLength.clamp(0, html.length);
  final String trimmed = html.substringSafe(0, len);
  final List<String> open = <String>[];
  final RegExp openTag = RegExp(r'<(\w+)[^>]*>');
  final RegExp closeTag = RegExp(r'</(\w+)>');
  for (final Match m in openTag.allMatches(trimmed)) {
    final String tag = m.group(1) ?? '';
    if (tag != _kTagBr && tag != _kTagImg) open.add(tag);
  }
  for (final Match m in closeTag.allMatches(trimmed)) {
    final String tag = m.group(1) ?? '';
    final int i = open.lastIndexOf(tag);
    if (i >= 0) open.removeRange(i, open.length);
  }
  final StringBuffer out = StringBuffer(trimmed);
  for (int i = open.length - 1; i >= 0; i--) {
    out.write('</${open[i]}>');
  }
  return out.toString();
}
