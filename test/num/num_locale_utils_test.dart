import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/num/num_locale_utils.dart';

void main() {
  group('parseNumberLocale', () {
    test('strips default group separator (comma)', () {
      expect(parseNumberLocale('1,234.56'), 1234.56);
    });

    test('plain number without separators', () {
      expect(parseNumberLocale('42'), 42.0);
    });

    test('European style with custom separators', () {
      // groupSep '.', decimalSep ',' -> "1.234,56" means 1234.56.
      expect(
        parseNumberLocale('1.234,56', decimalSep: ',', groupSep: '.'),
        1234.56,
      );
    });

    test('trims surrounding whitespace', () {
      expect(parseNumberLocale('  3.14  '), 3.14);
    });

    test('invalid input returns null', () {
      expect(parseNumberLocale('abc'), isNull);
    });

    test('negative number', () {
      expect(parseNumberLocale('-1,000'), -1000.0);
    });
  });

  group('formatNumberLocale', () {
    test('groups thousands with default comma', () {
      expect(formatNumberLocale(1234567), '1,234,567');
    });

    test('rounds when no decimal places requested', () {
      expect(formatNumberLocale(1234.7), '1,235');
    });

    test('keeps decimal places', () {
      expect(formatNumberLocale(1234.5, decimalPlaces: 2), '1,234.50');
    });

    test('negative number keeps sign before grouped digits', () {
      expect(formatNumberLocale(-1234), '-1,234');
    });

    test('empty group separator disables grouping', () {
      expect(formatNumberLocale(1234567, groupSep: ''), '1234567');
    });

    test('small value below 1000 is ungrouped', () {
      expect(formatNumberLocale(42), '42');
    });

    test('custom group separator', () {
      expect(formatNumberLocale(1234567, groupSep: ' '), '1 234 567');
    });
  });
}
