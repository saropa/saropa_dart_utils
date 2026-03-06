/// Sensitive data scrubber with pluggable patterns (roadmap #425).
library;

/// A scrubber rule: [pattern] is replaced by [replacement] when matched.
class ScrubRule {
  const ScrubRule(this.pattern, this.replacement);
  final RegExp pattern;
  final String replacement;

  @override
  String toString() => 'ScrubRule(pattern: ${pattern.pattern}, replacement: $replacement)';
}

const String _kScrubEmail = '[EMAIL]';
const String _kScrubPhone = '[PHONE]';
const String _kScrubCard = '[CARD]';
const String _kScrubSsn = '[SSN]';

/// Default rules: mask emails, phone-like digits, card-like numbers, SSN-like.
List<ScrubRule> get defaultScrubRules => <ScrubRule>[
  ScrubRule(RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'), _kScrubEmail),
  ScrubRule(RegExp(r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b'), _kScrubPhone),
  ScrubRule(RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), _kScrubCard),
  ScrubRule(RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), _kScrubSsn),
];

/// Returns [text] with all matches of [rules] replaced by their replacement string.
String scrubSensitive(String text, List<ScrubRule> rules) {
  String out = text;
  for (final ScrubRule r in rules) {
    out = out.replaceAll(r.pattern, r.replacement);
  }
  return out;
}
