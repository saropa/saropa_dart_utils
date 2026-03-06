/// HTML sanitizer: allowlist tags/attributes, strip scripts/styles (roadmap #439).
library;

/// Removes script and style tag contents, then strips all HTML tags.
String sanitizeHtml(String html) {
  String s = html.replaceAllMapped(
    RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false),
    (_) => '',
  );
  s = s.replaceAllMapped(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), (_) => '');
  return stripHtmlTags(s);
}

/// Strips all HTML tags and returns plain text (no attributes or script content).
String stripHtmlTags(String html) {
  return html.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
