/// URL/link extractor with context (roadmap #423).
library;

/// One extracted link with optional label and surrounding snippet.
class ExtractedLink {
  const ExtractedLink(String url, {String? label, String? snippet})
    : _url = url,
      _label = label,
      _snippet = snippet;
  final String _url;

  String get url => _url;
  final String? _label;

  String? get label => _label;
  final String? _snippet;

  String? get snippet => _snippet;

  @override
  String toString() =>
      'ExtractedLink(url: $_url, label: ${_label ?? ''}, snippet: ${_snippet ?? ''})';
}

/// Extracts URLs from [text]; [snippetLength] chars of context before/after.
List<ExtractedLink> extractUrlsWithContext(String text, {int snippetLength = 40}) {
  final RegExp urlPattern = RegExp(r'https?://[^\s<>"\x27]+', caseSensitive: false);
  final List<ExtractedLink> out = <ExtractedLink>[];
  for (final Match m in urlPattern.allMatches(text)) {
    final String urlStr = m.group(0) ?? '';
    final int start = (m.start - snippetLength).clamp(0, text.length);
    final int end = (m.end + snippetLength).clamp(0, text.length);
    // Extract snippet: substring from start to end, or empty if invalid range.
    final String raw = (start < m.start || m.end < end) && start < end && end <= text.length
        ? text.replaceRange(end, text.length, '').replaceRange(0, start, '')
        : '';
    final String snippet = raw.trim();
    out.add(ExtractedLink(urlStr, snippet: snippet.isEmpty ? null : snippet));
  }
  return out;
}
