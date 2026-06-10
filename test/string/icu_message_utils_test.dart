import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/icu_message_utils.dart';

void main() {
  group('icuPlural', () {
    test('picks zero form only when provided and count is 0', () {
      expect(icuPlural(0, zero: 'No files', one: '# file', other: '# files'), 'No files');
    });

    test('falls through to other at 0 when no zero form', () {
      expect(icuPlural(0, one: '# file', other: '# files'), '0 files');
    });

    test('picks one form at count 1', () {
      expect(icuPlural(1, one: '# file', other: '# files'), '1 file');
    });

    test('picks other and substitutes # for any other count', () {
      expect(icuPlural(5, one: '# file', other: '# files'), '5 files');
      expect(icuPlural(42, other: '# items'), '42 items');
    });

    test('substitutes every # occurrence', () {
      expect(icuPlural(3, other: '# of # shown'), '3 of 3 shown');
    });

    test('one form without a # is returned verbatim', () {
      expect(icuPlural(1, one: 'a single file', other: '# files'), 'a single file');
    });
  });

  group('icuSelect', () {
    test('returns the matching case', () {
      expect(
        icuSelect('female', <String, String>{'male': 'He', 'female': 'She'}, other: 'They'),
        'She',
      );
    });

    test('falls back to other for an unknown value', () {
      expect(
        icuSelect('nonbinary', <String, String>{'male': 'He', 'female': 'She'}, other: 'They'),
        'They',
      );
    });

    test('falls back to other for an empty case map', () {
      expect(icuSelect('x', <String, String>{}, other: 'default'), 'default');
    });
  });
}
