import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/phone_normalize_utils.dart';

void main() {
  group('normalizePhoneDigits', () {
    test('strips formatting', () => expect(normalizePhoneDigits('(555) 123-4567'), '5551234567'));
    test('strips plus sign', () => expect(normalizePhoneDigits('+1 555 123 4567'), '15551234567'));
    test('digits only unchanged', () => expect(normalizePhoneDigits('5551234567'), '5551234567'));
    test('empty string yields empty', () => expect(normalizePhoneDigits(''), ''));
    test('all non-digit yields empty', () => expect(normalizePhoneDigits('abc-def'), ''));
    test('letters interspersed stripped', () => expect(normalizePhoneDigits('1a2b3'), '123'));
  });

  group('normalizePhoneE164', () {
    test('leading plus preserved as prefix', () {
      expect(normalizePhoneE164('+1 (555) 123-4567'), '+15551234567');
    });
    test('no plus yields bare digits', () {
      expect(normalizePhoneE164('1 555 123 4567'), '15551234567');
    });
    test('plus after leading whitespace preserved', () {
      expect(normalizePhoneE164('  +44 20 1234'), '+44201234');
    });
    test('internal plus only (no leading) not preserved', () {
      expect(normalizePhoneE164('1+555'), '1555');
    });
    test('empty string yields empty', () => expect(normalizePhoneE164(''), ''));
    test('only plus yields plus prefix and empty digits', () {
      expect(normalizePhoneE164('+'), '+');
    });
  });
}
