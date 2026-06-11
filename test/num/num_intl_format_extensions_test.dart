import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:saropa_dart_utils/num/num_intl_format_extensions.dart';

void main() {
  group('NumIntlFormatExtensions.formatNumber', () {
    // intl's default locale is process-global. Pin it to en_US before each test
    // and clear it after, so a default-locale assertion neither depends on host
    // configuration nor leaks state into a later test.
    setUp(() {
      Intl.defaultLocale = 'en_US';
    });
    tearDown(() {
      Intl.defaultLocale = null;
    });

    group('default and explicit en_US locale', () {
      test('default locale (pinned en_US) groups with comma', () {
        expect(1234.formatNumber(), equals('1,234'));
        expect(1234567.formatNumber(), equals('1,234,567'));
      });

      test('explicit en_US locale matches the default', () {
        expect(1234.formatNumber(locale: 'en_US'), equals('1,234'));
      });

      test('int and double receiver render identically under default pattern', () {
        expect(1234.formatNumber(), equals('1,234'));
        expect((1234.0).formatNumber(), equals('1,234'));
      });
    });

    group('locale-specific separators', () {
      test('de_DE uses dot grouping', () {
        // Pins that the locale parameter is honored: de_DE must produce
        // "1.234", not "1,234".
        expect(1234.formatNumber(locale: 'de_DE'), equals('1.234'));
        expect(1234567.formatNumber(locale: 'de_DE'), equals('1.234.567'));
      });

      test('es_ES also uses dot grouping', () {
        expect(1234567.formatNumber(locale: 'es_ES'), equals('1.234.567'));
      });

      test('fr_FR groups with U+202F narrow no-break space', () {
        // The fr_FR group separator is U+202F (NARROW no-break space) in
        // intl 0.20.2 — NOT a regular space and NOT U+00A0. A literal-space
        // assertion would pass wrongly, so build the expected string from the
        // exact code point.
        final String nnbsp = String.fromCharCode(0x202F);
        expect(1234.formatNumber(locale: 'fr_FR'), equals('1${nnbsp}234'));
        expect(
          1234567.formatNumber(locale: 'fr_FR'),
          equals('1${nnbsp}234${nnbsp}567'),
        );
      });

      test('de_DE decimal separator is a comma', () {
        expect(
          1234.5.formatNumber(format: '#,##0.00', locale: 'de_DE'),
          equals('1.234,50'),
        );
      });

      test('en_IN uses non-3-digit (2-2-3) grouping', () {
        // The manual formatNumberLocale cannot express this; CLDR-driven
        // grouping can.
        expect(
          1234567.formatNumber(format: '##,##,##0', locale: 'en_IN'),
          equals('12,34,567'),
        );
      });

      test('Arabic (ar) emits Western digits with comma grouping', () {
        // intl 0.20.2 renders Western (ASCII) digits for the bare 'ar' locale
        // rather than Eastern-Arabic-Indic digits; pin the actual behavior.
        expect(1234.formatNumber(locale: 'ar'), equals('1,234'));
        expect(1234567.formatNumber(locale: 'ar'), equals('1,234,567'));
      });

      test('unknown locale throws ArgumentError', () {
        expect(
          () => 1234.formatNumber(locale: 'xx_YY'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('empty locale string throws ArgumentError', () {
        expect(
          () => 1234.formatNumber(locale: ''),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('explicit format pattern', () {
      test("'#,##0.00' adds two decimals over the default", () {
        expect(
          1234.5.formatNumber(format: '#,##0.00', locale: 'en_US'),
          equals('1,234.50'),
        );
      });

      test('empty format string formats without grouping (no throw)', () {
        // intl treats '' as a bare decimal pattern: no grouping, no throw.
        expect(1234.formatNumber(format: ''), equals('1234'));
      });

      test("zero-pad pattern '00000' left-pads with zeros", () {
        expect(1234.formatNumber(format: '00000'), equals('01234'));
      });

      test('literal text in the pattern is preserved', () {
        expect(1234.formatNumber(format: '#,##0 kg'), equals('1,234 kg'));
      });

      test('percent pattern scales the receiver by 100', () {
        // The receiver is multiplied by 100 and a percent sign appended.
        expect(0.42.formatNumber(format: '#,##0%'), equals('42%'));
      });
    });

    group('zero and small numbers', () {
      test('values below the first grouping have no separators', () {
        expect(0.formatNumber(), equals('0'));
        expect(42.formatNumber(), equals('42'));
        expect(999.formatNumber(), equals('999'));
      });

      test('zero double under a two-decimal pattern keeps the decimals', () {
        expect(0.0.formatNumber(format: '#,##0.00'), equals('0.00'));
      });
    });

    group('grouping boundaries', () {
      test('separator appears exactly at the thousands boundary', () {
        expect(999.formatNumber(), equals('999'));
        expect(1000.formatNumber(), equals('1,000'));
        expect(99999.formatNumber(), equals('99,999'));
      });
    });

    group('negatives', () {
      test('default pattern keeps the minus sign outside the grouping', () {
        expect((-1234).formatNumber(), equals('-1,234'));
      });

      test('two-decimal pattern places the sign before the digits', () {
        expect(
          (-1234.5).formatNumber(format: '#,##0.00'),
          equals('-1,234.50'),
        );
      });

      test('parenthesized-negative pattern wraps the value', () {
        expect(
          (-1234).formatNumber(format: '#,##0;(#,##0)'),
          equals('(1,234)'),
        );
      });

      test('negative zero is preserved', () {
        // intl emits the sign for -0.0; pin both the integer and decimal forms.
        expect((-0.0).formatNumber(), equals('-0'));
        expect((-0.0).formatNumber(format: '#,##0.00'), equals('-0.00'));
      });
    });

    group('rounding', () {
      test('half-up rounding from the pattern decimal count', () {
        expect(
          1234.567.formatNumber(format: '#,##0.00'),
          equals('1,234.57'),
        );
        // 1234.565 in IEEE-754 is fractionally above the exact midpoint, so it
        // rounds up to .57 rather than .56.
        expect(
          1234.565.formatNumber(format: '#,##0.00'),
          equals('1,234.57'),
        );
      });

      test('integer rounding is half-up, not banker\'s', () {
        // Banker's rounding would give 2.5 -> 2 and 3.5 -> 4; half-up gives
        // 2.5 -> 3 and 3.5 -> 4. The 2.5 case is the discriminator.
        expect(2.5.formatNumber(), equals('3'));
        expect(3.5.formatNumber(), equals('4'));
      });
    });

    group('extremes', () {
      test('very large int does not leak an exponent', () {
        expect(
          9223372036854775807.formatNumber(),
          equals('9,223,372,036,854,775,807'),
        );
      });

      test('double.maxFinite renders as fully expanded grouped digits', () {
        final String formatted = double.maxFinite.formatNumber();
        // No scientific-notation 'E' leaks through a grouped pattern, and the
        // result groups in threes ending in a comma-separated triplet.
        expect(formatted.contains('E'), isFalse);
        expect(formatted.contains('e'), isFalse);
        expect(formatted.startsWith('179,769,313,486'), isTrue);
      });

      test('very small fraction is preserved at four decimals', () {
        expect(
          0.0001.formatNumber(format: '#,##0.0000'),
          equals('0.0001'),
        );
      });

      test('positive infinity renders the locale infinity symbol', () {
        // The en infinity symbol is U+221E; assert via the code point so the
        // expectation never embeds a raw glyph.
        expect(
          double.infinity.formatNumber(),
          equals(String.fromCharCode(0x221E)),
        );
      });

      test('negative infinity prefixes the infinity symbol with a minus', () {
        expect(
          double.negativeInfinity.formatNumber(),
          equals('-${String.fromCharCode(0x221E)}'),
        );
      });

      test('NaN renders the locale NaN symbol', () {
        expect(double.nan.formatNumber(), equals('NaN'));
      });
    });

    group('determinism', () {
      test('default-locale output follows Intl.defaultLocale changes', () {
        // Guards that the null-locale path reads the process default rather than
        // a hard-coded en_US, and that tearDown resets it for later tests.
        Intl.defaultLocale = 'de_DE';
        expect(1234.formatNumber(), equals('1.234'));
        Intl.defaultLocale = 'en_US';
        expect(1234.formatNumber(), equals('1,234'));
      });
    });
  });
}
