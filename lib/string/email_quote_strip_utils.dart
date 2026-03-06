/// Email reply quote stripper (heuristic) — roadmap #424.
library;

const String _kOriginalMessage = 'Original Message';

/// Strips common reply patterns: lines starting with >, On ... wrote:, ----- Original Message -----.
String stripEmailReplyQuotes(String body) {
  final List<String> lines = body.split('\n');
  final List<String> out = [];
  bool isInQuote = false;
  for (final String line in lines) {
    final String trimmed = line.trimLeft();
    if (trimmed.startsWith('>') || trimmed.startsWith('|')) {
      isInQuote = true;
      continue;
    }
    if (RegExp(r'^On .+ wrote:').hasMatch(trimmed) || trimmed.contains(_kOriginalMessage)) {
      isInQuote = true;
      continue;
    }
    if (isInQuote && trimmed.isEmpty) continue;
    isInQuote = false;
    out.add(line);
  }
  return out.join('\n').trim();
}
