import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/password_strength_utils.dart';

void main() {
  group('passwordStrengthScore', () {
    test('empty string scores 0', () => expect(passwordStrengthScore(''), 0));

    test('short all-lowercase scores 0', () => expect(passwordStrengthScore('abc'), 0));

    test('8 lowercase only scores 1 (length)', () {
      expect(passwordStrengthScore('abcdefgh'), 1);
    });

    test('8 chars upper and lower scores 2 (length + case variety)', () {
      expect(passwordStrengthScore('Abcdefgh'), 2);
    });

    test('8 chars with digit scores 3', () {
      expect(passwordStrengthScore('Abcdefg1'), 3);
    });

    test('8 chars with special scores 4 (length + case + digit + special)', () {
      expect(passwordStrengthScore('Abcdef1!'), 4);
    });

    test('long complex password clamped to max 4', () {
      // length>=8 +1, length>=12 +1, case +1, digit +1, special +1 = 5 -> clamp 4.
      expect(passwordStrengthScore('Abcdefghijk1!'), 4);
    });

    test('all uppercase no lowercase gets no case-variety point', () {
      // 8 chars length +1 only; no lower so case point not awarded.
      expect(passwordStrengthScore('ABCDEFGH'), 1);
    });

    test('digits only short string scores digit point only', () {
      expect(passwordStrengthScore('1234'), 1);
    });

    test('never below 0', () => expect(passwordStrengthScore('x'), greaterThanOrEqualTo(0)));
  });
}
