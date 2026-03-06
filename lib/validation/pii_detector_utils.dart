/// PII detector for free-form text — roadmap #691.
library;

const String _kPiiPatternEmail = 'email';
const String _kPiiPatternPhone = 'phone';

/// Detects likely PII patterns; returns list of (patternName, startIndex, endIndex).
List<(String, int, int)> detectPii(String text) {
  final RegExp email = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
  final RegExp phone = RegExp(r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b');
  final List<RegExpMatch> emailMatches = email.allMatches(text).toList();
  final List<RegExpMatch> phoneMatches = phone.allMatches(text).toList();
  final int total = emailMatches.length + phoneMatches.length;
  final List<(String, int, int)> out = List.generate(
    total,
    (int index) {
      if (index < emailMatches.length) {
        final m = emailMatches[index];
        return (_kPiiPatternEmail, m.start, m.end);
      }
      final m = phoneMatches[index - emailMatches.length];
      return (_kPiiPatternPhone, m.start, m.end);
    },
  );
  return out;
}
