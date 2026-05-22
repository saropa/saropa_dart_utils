import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/sensitive_scrub_utils.dart';

void main() {
  // cspell: disable
  group('SensitiveScrubUtils', () {
    test('should expose pattern and replacement', () {
      final SensitiveScrubUtils rule = SensitiveScrubUtils(RegExp(r'\d+'), '[NUM]');
      expect(rule.pattern.pattern, r'\d+');
      expect(rule.replacement, '[NUM]');
    });

    test('toString should render pattern source and replacement', () {
      final SensitiveScrubUtils rule = SensitiveScrubUtils(RegExp('x'), '[X]');
      expect(rule.toString(), 'SensitiveScrubUtils(pattern: x, replacement: [X])');
    });
  });

  group('defaultScrubRules', () {
    test('should provide four default rules', () {
      expect(defaultScrubRules, hasLength(4));
    });

    test('should mask an email address', () {
      expect(scrubSensitive('contact me@x.com please', defaultScrubRules), 'contact [EMAIL] please');
    });

    test('should mask a phone-like number', () {
      expect(scrubSensitive('call 555-123-4567 now', defaultScrubRules), 'call [PHONE] now');
    });

    test('should mask a card-like number', () {
      expect(
        scrubSensitive('card 1234 5678 9012 3456 ok', defaultScrubRules),
        'card [CARD] ok',
      );
    });

    test('should mask an SSN-like number', () {
      expect(scrubSensitive('ssn 123-45-6789 end', defaultScrubRules), 'ssn [SSN] end');
    });
  });

  group('scrubSensitive', () {
    test('should apply a custom rule', () {
      final List<SensitiveScrubUtils> rules = <SensitiveScrubUtils>[
        SensitiveScrubUtils(RegExp(r'secret'), '[REDACTED]'),
      ];
      expect(scrubSensitive('the secret is out', rules), 'the [REDACTED] is out');
    });

    test('should apply multiple rules in order', () {
      final List<SensitiveScrubUtils> rules = <SensitiveScrubUtils>[
        SensitiveScrubUtils(RegExp(r'a'), 'X'),
        SensitiveScrubUtils(RegExp(r'b'), 'Y'),
      ];
      expect(scrubSensitive('abc', rules), 'XYc');
    });

    test('should return text unchanged when no rules match', () {
      final List<SensitiveScrubUtils> rules = <SensitiveScrubUtils>[
        SensitiveScrubUtils(RegExp(r'zzz'), '[Z]'),
      ];
      expect(scrubSensitive('nothing here', rules), 'nothing here');
    });

    test('should return text unchanged for empty rule list', () {
      expect(scrubSensitive('keep me', <SensitiveScrubUtils>[]), 'keep me');
    });
  });
}
