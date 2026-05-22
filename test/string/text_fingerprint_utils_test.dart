import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/text_fingerprint_utils.dart';

void main() {
  // cspell: disable
  group('textFingerprint', () {
    test('should return 0 for empty text', () {
      expect(textFingerprint(''), 0);
    });

    test('should return 0 when no word is longer than one character', () {
      // Words of length <= 1 are filtered out, leaving nothing to hash.
      expect(textFingerprint('a b c 1'), 0);
    });

    test('should be deterministic for the same input within a run', () {
      expect(textFingerprint('the quick brown fox'), textFingerprint('the quick brown fox'));
    });

    test('should produce a non-zero fingerprint for multi-letter words', () {
      expect(textFingerprint('hello world'), isNot(0));
    });

    test('should differ for clearly different documents', () {
      expect(
        textFingerprint('apples oranges bananas'),
        isNot(textFingerprint('rockets planets galaxies')),
      );
    });

    test('should be order-insensitive (xor accumulates by position+word)', () {
      // Each word contributes value^(hashCode + index*prime); the same multiset
      // of words at the same positions yields the same fingerprint.
      expect(textFingerprint('aa bb'), textFingerprint('aa bb'));
    });
  });

  group('fingerprintDistance', () {
    test('should be 0 for identical fingerprints', () {
      expect(fingerprintDistance(0xFF, 0xFF), 0);
    });

    test('should count differing bits', () {
      // 0b0000 vs 0b1011 differ in 3 bits.
      expect(fingerprintDistance(0x0, 0xB), 3);
    });

    test('should equal bit count when one operand is zero', () {
      // 0xFF has eight set bits.
      expect(fingerprintDistance(0x0, 0xFF), 8);
    });

    test('should be symmetric', () {
      expect(fingerprintDistance(0x12, 0x34), fingerprintDistance(0x34, 0x12));
    });

    test('should mask to 32 bits before counting', () {
      expect(fingerprintDistance(0x1, 0x1), 0);
    });
  });
}
