/// URL/link extractor with context (roadmap #423).
library;

/// One extracted link with optional label and surrounding snippet.
class UrlExtractUtils {
  /// Creates an extracted link for [url], with an optional anchor [label] and
  /// surrounding [snippet] of context.
  /// Audited: 2026-06-12 11:26 EDT
  const UrlExtractUtils(String url, {String? label, String? snippet})
    : _url = url,
      _label = label,
      _snippet = snippet;
  final String _url;

  /// The extracted URL.
  /// Audited: 2026-06-12 11:26 EDT
  String get url => _url;
  final String? _label;

  /// Visible link text/anchor when the URL was part of markup, else null.
  /// Audited: 2026-06-12 11:26 EDT
  String? get label => _label;
  final String? _snippet;

  /// Surrounding text giving context around the link, or null if unavailable.
  /// Audited: 2026-06-12 11:26 EDT
  String? get snippet => _snippet;

  @override
  String toString() =>
      'UrlExtractUtils(url: $_url, label: ${_label ?? ''}, snippet: ${_snippet ?? ''})';
}

/// Extracts URLs from [text]; [snippetLength] chars of context before/after.
/// Audited: 2026-06-12 11:26 EDT
List<UrlExtractUtils> extractUrlsWithContext(String text, {int snippetLength = 40}) {
  final RegExp urlPattern = RegExp(r'https?://[^\s<>"\x27]+', caseSensitive: false);
  final List<UrlExtractUtils> out = <UrlExtractUtils>[];
  for (final Match m in urlPattern.allMatches(text)) {
    // The greedy match swallows trailing sentence punctuation when a URL ends a
    // sentence (`...a.com.` / `...a.com,`). Trim those terminal characters.
    // Brackets are deliberately NOT trimmed so paren-bearing URLs (e.g.
    // Wikipedia `..._(disambiguation)`) survive intact.
    final String urlStr = (m.group(0) ?? '').replaceFirst(RegExp('''[.,;:!?'"]+\$'''), '');
    final int start = (m.start - snippetLength).clamp(0, text.length);
    final int end = (m.end + snippetLength).clamp(0, text.length);
    // Extract snippet: substring from start to end, or empty if invalid range.
    final String copy = text;
    final String raw = (start < m.start || m.end < end) && start < end && end <= text.length
        ? copy.replaceRange(end, text.length, '').replaceRange(0, start, '')
        : '';
    final String snippet = raw.trim();
    out.add(UrlExtractUtils(urlStr, snippet: snippet.isEmpty ? null : snippet));
  }
  return out;
}
