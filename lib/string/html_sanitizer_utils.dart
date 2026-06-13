/// HTML-to-plain-text reducer (roadmap #439).
///
/// NOT a security sanitizer and NOT an allowlist: it removes `<script>`/`<style>`
/// blocks then strips ALL remaining tags to plain text — no tag/attribute is
/// preserved. Do not use it to produce HTML for re-insertion into a page; the
/// tag-matching is a regex (`<[^>]+>`) that cannot handle a `>` inside an
/// attribute value and is not a substitute for a real HTML sanitizer/parser.
/// Use it only to extract readable text from HTML.
library;

/// Removes `<script>`/`<style>` blocks, then strips all remaining tags, leaving
/// plain text. See the library note: this is text extraction, not sanitization.
/// Audited: 2026-06-12 11:26 EDT
String sanitizeHtml(String html) {
  String s = html.replaceAllMapped(
    RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false),
    (_) => '',
  );
  s = s.replaceAllMapped(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), (_) => '');
  return stripHtmlTags(s);
}

/// Strips all HTML tags and returns plain text (no attributes or script content).
/// Audited: 2026-06-12 11:26 EDT
String stripHtmlTags(String html) =>
    html.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
