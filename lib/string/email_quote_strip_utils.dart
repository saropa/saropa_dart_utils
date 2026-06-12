/// Email reply quote stripper (heuristic) — roadmap #424.
library;

const String _kOriginalMessage = 'Original Message';

/// Strips common reply patterns: lines starting with >, On ... wrote:, ----- Original Message -----.
/// Audited: 2026-06-12 11:26 EDT
String stripEmailReplyQuotes(String body) {
  final List<String> lines = body.split('\n');
  final List<String> out = <String>[];
  // Track whether we are inside quoted reply text so blank lines within a quote
  // block are dropped too (not just the marker lines).
  bool isInQuote = false;
  for (final String line in lines) {
    final String trimmed = line.trimLeft();
    // Classic quote markers ('>' / '|') begin or continue a quoted block.
    if (trimmed.startsWith('>') || trimmed.startsWith('|')) {
      isInQuote = true;
      continue;
    }
    // Attribution lines ("On <date> ... wrote:" / "Original Message") introduce
    // quoted content even without a marker prefix.
    if (RegExp(r'^On .+ wrote:').hasMatch(trimmed) || trimmed.contains(_kOriginalMessage)) {
      isInQuote = true;
      continue;
    }
    // Swallow blank lines that trail a quote; the first real line ends the quote.
    if (isInQuote && trimmed.isEmpty) continue;
    isInQuote = false;
    out.add(line);
  }
  return out.join('\n').trim();
}
