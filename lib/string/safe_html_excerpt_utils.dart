/// Safe HTML excerpt (truncate without breaking tags) — roadmap #440.
library;

import 'string_extensions.dart';

const String _kTagBr = 'br';
const String _kTagImg = 'img';

/// Truncates [html] to about [maxLength] chars, closing open tags.
/// Audited: 2026-06-12 11:26 EDT
String safeHtmlExcerpt(String html, int maxLength) {
  if (html.length <= maxLength) return html;
  final int len = maxLength.clamp(0, html.length);
  final String trimmed = html.substringSafe(0, len);
  final List<String> open = <String>[];
  final RegExp openTag = RegExp(r'<(\w+)[^>]*>');
  final RegExp closeTag = RegExp(r'</(\w+)>');
  // `open` is a stack of still-unclosed tags. Void elements (br/img) never carry
  // a closing tag, so they must not be pushed or they'd be wrongly closed later.
  for (final Match m in openTag.allMatches(trimmed)) {
    final String tag = m.group(1) ?? '';
    if (tag != _kTagBr && tag != _kTagImg) open.add(tag);
  }
  // Pop on each closer. Using lastIndexOf + removeRange (rather than removeLast)
  // handles malformed/overlapping nesting: it discards everything opened after
  // the matched tag, since those can no longer be cleanly closed.
  for (final Match m in closeTag.allMatches(trimmed)) {
    final String tag = m.group(1) ?? '';
    final int i = open.lastIndexOf(tag);
    if (i >= 0) open.removeRange(i, open.length);
  }
  final StringBuffer out = StringBuffer(trimmed);
  // Emit closers in reverse open order (innermost first) to keep nesting valid.
  for (int i = open.length - 1; i >= 0; i--) {
    out.write('</${open[i]}>');
  }
  return out.toString();
}
