/// Sensitive data scrubber with pluggable patterns (roadmap #425).
library;

/// A scrubber rule: [pattern] is replaced by [replacement] when matched.
class SensitiveScrubUtils {
  /// Creates a rule that replaces every match of [pattern] with [replacement].
  /// Audited: 2026-06-12 11:26 EDT
  const SensitiveScrubUtils(this.pattern, this.replacement);

  /// Regular expression identifying the sensitive substrings to mask.
  final RegExp pattern;

  /// Text substituted in place of each [pattern] match (e.g. "[EMAIL]").
  final String replacement;

  @override
  String toString() =>
      'SensitiveScrubUtils(pattern: ${pattern.pattern}, replacement: $replacement)';
}

const String _kScrubEmail = '[EMAIL]';
const String _kScrubPhone = '[PHONE]';
const String _kScrubCard = '[CARD]';
const String _kScrubSsn = '[SSN]';

/// Default rules: mask emails, phone-like digits, card-like numbers, SSN-like.
/// Audited: 2026-06-12 11:26 EDT
List<SensitiveScrubUtils> get defaultScrubRules => <SensitiveScrubUtils>[
  SensitiveScrubUtils(RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), _kScrubEmail),
  SensitiveScrubUtils(RegExp(r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b'), _kScrubPhone),
  SensitiveScrubUtils(RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), _kScrubCard),
  SensitiveScrubUtils(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), _kScrubSsn),
];

/// Returns [text] with all matches of [rules] replaced by their replacement string.
/// Audited: 2026-06-12 11:26 EDT
String scrubSensitive(String text, List<SensitiveScrubUtils> rules) {
  String out = text;
  for (final SensitiveScrubUtils r in rules) {
    out = out.replaceAll(r.pattern, r.replacement);
  }
  return out;
}
