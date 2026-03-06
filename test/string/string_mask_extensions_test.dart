import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_mask_extensions.dart';

void main() {
  group('mask', () {
    test('show last 4', () => expect('1234567890'.mask(visibleCount: 4), '******7890'));
    test('all visible', () => expect('card'.mask(visibleCount: 4), 'card'));
    test('short string', () => expect('ab'.mask(visibleCount: 5), 'ab'));
    test('empty', () => expect(''.mask(visibleCount: 4), ''));
    test('visibleCount 0', () => expect('123'.mask(visibleCount: 0), '***'));
    test('custom maskChar', () => expect('12'.mask(visibleCount: 1, maskChar: 'x'), 'x2'));
    test('empty maskChar throws', () {
      expect(() => 'ab'.mask(maskChar: ''), throwsArgumentError);
    });
  });

  group('redactEmail', () {
    test('normal', () => expect('user@example.com'.redactEmail(), 'u***@example.com'));
    test('single char local', () => expect('a@b.co'.redactEmail(), 'a***@b.co'));
    test('custom maskChar', () => expect('u@x.com'.redactEmail(maskChar: 'x'), 'uxxx@x.com'));
    test('no @', () => expect('nobody'.redactEmail(), '******'));
    test('empty', () => expect(''.redactEmail(), ''));
  });

  group('redactPhone', () {
    test('keeps last 4 digits', () {
      final String s = '+1 (555) 123-4567'.redactPhone(visibleCount: 4);
      expect(s.endsWith('4567'), isTrue);
      expect(s.contains('*'), isTrue);
    });
    test('empty', () => expect(''.redactPhone(), ''));
    test('visibleCount negative throws', () {
      expect(() => '12'.redactPhone(visibleCount: -1), throwsArgumentError);
    });
  });
}
