import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:saropa_dart_utils/datetime/date_time_intl_display_extensions.dart';

// Collapses every non-breaking space variant intl/CLDR may emit between the
// clock and its AM/PM marker (U+00A0 from the extension's own replace, or the
// U+202F narrow no-break space some CLDR data ships) down to a plain ASCII
// space. Visible-content assertions use this so they do not depend on which
// exact non-breaking code point the installed intl version produces; the
// non-breaking INVARIANT is asserted separately against the raw string.
String visible(String? s) =>
    (s ?? '').replaceAll(' ', ' ').replaceAll(' ', ' ');

void main() {
  // Required for non-en locales: date_symbol_data_local must load once per
  // process before any DateFormat with a non-en locale runs. Without it, a
  // non-en locale throws and the catch-and-degrade paths fire instead.
  setUpAll(() async {
    await initializeDateFormatting();
  });

  // ===========================================================================
  // formatUtcOffset (pure Dart, no intl) — deterministic via explicit Duration.
  // ===========================================================================
  group('formatUtcOffset', () {
    test('should render zero as UTC±0 with the plus-minus sign', () {
      final String result = formatUtcOffset(Duration.zero);
      expect(result, equals('UTC±0'));
      // Assert the actual ± code unit, not a flattened ASCII +/-.
      expect(result.codeUnits, contains(0x00B1));
    });

    test('should render verbose zero as UTC±00:00', () {
      final String result = formatUtcOffset(Duration.zero, verbose: true);
      expect(result, equals('UTC±00:00'));
      expect(result.codeUnits, contains(0x00B1));
    });

    test('should render a positive whole hour without minutes', () {
      expect(formatUtcOffset(const Duration(hours: 5)), equals('UTC+5'));
    });

    test('should render a negative whole hour without minutes', () {
      expect(formatUtcOffset(const Duration(hours: -8)), equals('UTC-8'));
    });

    test('should render a positive half-hour offset (India UTC+5:30)', () {
      expect(formatUtcOffset(const Duration(hours: 5, minutes: 30)), equals('UTC+5:30'));
    });

    test('should render a negative half-hour offset (Newfoundland UTC-3:30)', () {
      expect(formatUtcOffset(const Duration(hours: -3, minutes: -30)), equals('UTC-3:30'));
    });

    test('should zero-pad a 45-minute offset (Nepal UTC+5:45)', () {
      expect(formatUtcOffset(const Duration(hours: 5, minutes: 45)), equals('UTC+5:45'));
    });

    test('should render the Chatham 12:45 offset with padded minutes', () {
      expect(formatUtcOffset(const Duration(hours: 12, minutes: 45)), equals('UTC+12:45'));
    });

    test('should render the extreme positive offset UTC+14 without overflow', () {
      expect(formatUtcOffset(const Duration(hours: 14)), equals('UTC+14'));
    });

    test('should render the extreme negative offset UTC-12 without overflow', () {
      expect(formatUtcOffset(const Duration(hours: -12)), equals('UTC-12'));
    });
  });

  // ===========================================================================
  // getUtcOffset — extension form reads the host TZ, so only assert shape.
  // ===========================================================================
  group('getUtcOffset', () {
    test('should produce a non-null UTC-prefixed string for any DateTime', () {
      final String? result = DateTime(2026).getUtcOffset();
      expect(result, isNotNull);
      expect(result, startsWith('UTC'));
    });
  });

  // ===========================================================================
  // fullDateDisplay — locale-ordered full month name.
  // ===========================================================================
  group('fullDateDisplay', () {
    final DateTime jan15_1945 = DateTime(1945, 1, 15);

    test('should use month-first ordering with full month name for en_US', () {
      expect(jan15_1945.fullDateDisplay(locale: 'en_US'), equals('January 15, 1945'));
    });

    test('should preserve fr_FR non-ASCII output without flattening', () {
      // Assert via explicit text; "janvier" round-trips through the test intact.
      expect(jan15_1945.fullDateDisplay(locale: 'fr_FR'), equals('15 janvier 1945'));
    });

    test('should preserve ja_JP CJK output via explicit code points', () {
      final String result = jan15_1945.fullDateDisplay(locale: 'ja_JP');
      // Verify against the exact Unicode scalar values rather than a pasted
      // glyph: a paste/encoding glitch that swapped or flattened the CJK
      // characters would change these code points and fail the test.
      // 年 = U+5E74, 月 = U+6708, 日 = U+65E5.
      expect(result.runes.toList(), equals(<int>[
        0x31, 0x39, 0x34, 0x35, // 1945
        0x5E74, //                年
        0x31, //                  1
        0x6708, //                月
        0x31, 0x35, //            15
        0x65E5, //                日
      ]));
    });

    test('should return empty string for an unknown locale (no throw)', () {
      expect(() => jan15_1945.fullDateDisplay(locale: 'xx_YY'), returnsNormally);
      expect(jan15_1945.fullDateDisplay(locale: 'xx_YY'), equals(''));
    });
  });

  // ===========================================================================
  // MMMMd skeleton ordering (spec sample) — verifies intl reorders components.
  // ===========================================================================
  group('MMMMd skeleton locale ordering', () {
    final DateTime may10 = DateTime(2026, 5, 10);

    test('should produce month-first ordering for en_US', () {
      expect(DateFormat.MMMMd('en_US').format(may10), equals('May 10'));
    });

    test('should produce day-first ordering for fr_FR', () {
      expect(DateFormat.MMMMd('fr_FR').format(may10), equals('10 mai'));
    });

    test('should produce day-dot-space-month ordering for de_DE', () {
      expect(DateFormat.MMMMd('de_DE').format(may10), equals('10. Mai'));
    });
  });

  // ===========================================================================
  // dateDisplay — abbreviated/full month, ordinals, year suppression.
  // ===========================================================================
  group('dateDisplay', () {
    final DateTime jan15_1945 = DateTime(1945, 1, 15);

    test('should use abbreviated month, month-first, with year for en_US', () {
      expect(jan15_1945.dateDisplay(locale: 'en_US'), equals('Jan 15, 1945'));
    });

    test('should select the full month name when monthFormat is MMMM', () {
      expect(
        jan15_1945.dateDisplay(locale: 'en_US', monthFormat: 'MMMM'),
        equals('January 15, 1945'),
      );
    });

    test('should keep fixed English ordinal order with showDayOrdinal', () {
      expect(
        jan15_1945.dateDisplay(locale: 'en_US', showDayOrdinal: true),
        equals('Jan 15th, 1945'),
      );
    });

    test('should reorder month-first en_US but day-first fr_FR via skeleton', () {
      expect(DateFormat.yMMMd('en_US').format(jan15_1945), startsWith('Jan'));
      expect(DateFormat.yMMMd('fr_FR').format(jan15_1945), startsWith('15'));
    });

    test('should omit the year for a current-year date when showCurrentYear is false', () {
      final DateTime fixedNow = DateTime(2026, 6, 11);
      final DateTime inCurrentYear = DateTime(2026, 3, 4);
      expect(
        inCurrentYear.dateDisplay(locale: 'en_US', showCurrentYear: false, now: fixedNow),
        equals('Mar 4'),
      );
    });

    test('should keep the year for a different-year date when showCurrentYear is false', () {
      final DateTime fixedNow = DateTime(2026, 6, 11);
      final DateTime priorYear = DateTime(2020, 3, 4);
      expect(
        priorYear.dateDisplay(locale: 'en_US', showCurrentYear: false, now: fixedNow),
        equals('Mar 4, 2020'),
      );
    });
  });

  // ===========================================================================
  // dateDisplay ordinals — the % 100 in 11..13 teens carve-out.
  // ===========================================================================
  group('dateDisplay ordinals', () {
    String ordinalFor(int day) =>
        DateTime(2026, 1, day).dateDisplay(locale: 'en_US', showDayOrdinal: true);

    test('should suffix st/nd/rd for 1, 2, 3', () {
      expect(ordinalFor(1), equals('Jan 1st, 2026'));
      expect(ordinalFor(2), equals('Jan 2nd, 2026'));
      expect(ordinalFor(3), equals('Jan 3rd, 2026'));
    });

    test('should suffix th for 4', () {
      expect(ordinalFor(4), equals('Jan 4th, 2026'));
    });

    test('should suffix th for the 11/12/13 teens exception', () {
      expect(ordinalFor(11), equals('Jan 11th, 2026'));
      expect(ordinalFor(12), equals('Jan 12th, 2026'));
      expect(ordinalFor(13), equals('Jan 13th, 2026'));
    });

    test('should suffix st/nd/rd again for 21, 22, 23', () {
      expect(ordinalFor(21), equals('Jan 21st, 2026'));
      expect(ordinalFor(22), equals('Jan 22nd, 2026'));
      expect(ordinalFor(23), equals('Jan 23rd, 2026'));
    });

    test('should suffix st for 31', () {
      expect(ordinalFor(31), equals('Jan 31st, 2026'));
    });
  });

  // ===========================================================================
  // makeDisplayDate — weekday + year suppression incl. year <= 0 guard.
  // ===========================================================================
  group('makeDisplayDate', () {
    final DateTime jul21_2020 = DateTime(2020, 7, 21); // a Tuesday

    test('should render weekday, month, day, year by default', () {
      expect(jul21_2020.makeDisplayDate(locale: 'en_US'), equals('Tue, Jul 21, 2020'));
    });

    test('should drop the weekday when showWeekday is false', () {
      expect(
        jul21_2020.makeDisplayDate(locale: 'en_US', showWeekday: false),
        equals('Jul 21, 2020'),
      );
    });

    test('should suppress the year for a current-year date by default', () {
      final DateTime fixedNow = DateTime(2026, 6, 11);
      final DateTime inCurrentYear = DateTime(2026, 7, 21);
      // showCurrentYear defaults false here, so a current-year date hides the year.
      final String? result = inCurrentYear.makeDisplayDate(locale: 'en_US', now: fixedNow);
      expect(result, isNotNull);
      expect(result, isNot(contains('2026')));
    });

    test('should suppress the year for the year-zero placeholder date', () {
      // DateTime(0) has year <= 0; the year > 0 guard must hide the year, so the
      // weekday+month+day form (no trailing ", <year>") is rendered.
      final String? result = DateTime(0, 7, 21).makeDisplayDate(locale: 'en_US');
      final String? withoutYear =
          DateTime(0, 7, 21).makeDisplayDate(locale: 'en_US', showWeekday: false);
      expect(result, isNotNull);
      // No 4-digit year leaks through (the year > 0 guard suppressed it).
      expect(RegExp(r'\d{4}').hasMatch(result!), isFalse);
      // Weekday name varies for the proleptic year 0, so assert the stable tail.
      expect(result, endsWith('Jul 21'));
      expect(withoutYear, equals('Jul 21'));
    });

    test('should return null for an unknown locale (no throw)', () {
      expect(() => jul21_2020.makeDisplayDate(locale: 'xx_YY'), returnsNormally);
      expect(jul21_2020.makeDisplayDate(locale: 'xx_YY'), isNull);
    });
  });

  // ===========================================================================
  // makeDisplayTime — clock convention, omit-minutes, seconds, non-breaking.
  // ===========================================================================
  group('makeDisplayTime', () {
    final DateTime at1530 = DateTime(2026, 1, 15, 15, 30);
    final DateTime at1500 = DateTime(2026, 1, 15, 15);

    test('should render 12h AM/PM by default for en_US', () {
      expect(visible(at1530.makeDisplayTime(locale: 'en_US')), equals('3:30 PM'));
    });

    test('should omit :00 minutes on the hour for en_US', () {
      expect(visible(at1500.makeDisplayTime(locale: 'en_US')), equals('3 PM'));
    });

    test('should force a 24h clock with hour24 + showAMPM false', () {
      expect(at1530.makeDisplayTime(hour24: true, showAMPM: false), equals('15:30'));
    });

    test('should keep :00 when omitZeroMinutes is false at midnight', () {
      final DateTime midnight = DateTime(2026, 1, 15);
      expect(
        visible(midnight.makeDisplayTime(locale: 'en_US', omitZeroMinutes: false)),
        equals('12:00 AM'),
      );
    });

    test('should render midnight as 12 AM in 12h and 00 in 24h', () {
      final DateTime midnight = DateTime(2026, 1, 15);
      expect(visible(midnight.makeDisplayTime(locale: 'en_US')), equals('12 AM'));
      expect(midnight.makeDisplayTime(hour24: true, showAMPM: false), equals('00'));
    });

    test('should render noon as 12 PM in 12h', () {
      final DateTime noon = DateTime(2026, 1, 15, 12);
      expect(visible(noon.makeDisplayTime(locale: 'en_US')), equals('12 PM'));
    });

    test('should zero-pad a single-digit minute', () {
      final DateTime at1505 = DateTime(2026, 1, 15, 15, 5);
      expect(visible(at1505.makeDisplayTime(locale: 'en_US')), equals('3:05 PM'));
    });

    test('should append a seconds suffix at :00, :01 and :59', () {
      expect(
        visible(DateTime(2026, 1, 15, 15, 30).makeDisplayTime(locale: 'en_US', showSeconds: true)),
        equals('3:30 PM, 00 s'),
      );
      expect(
        visible(
          DateTime(2026, 1, 15, 15, 30, 1).makeDisplayTime(locale: 'en_US', showSeconds: true),
        ),
        equals('3:30 PM, 01 s'),
      );
      expect(
        visible(
          DateTime(2026, 1, 15, 15, 30, 59).makeDisplayTime(locale: 'en_US', showSeconds: true),
        ),
        equals('3:30 PM, 59 s'),
      );
    });
  });

  // ===========================================================================
  // makeDisplayTime locale clock sweep — 12h en_US vs 24h en_GB/fr/de/ja.
  // ===========================================================================
  group('makeDisplayTime locale clock convention', () {
    final DateTime at1530 = DateTime(2026, 1, 15, 15, 30);

    test('should signal 12h en_US but 24h for en_GB/fr_FR/de_DE/ja_JP via jm', () {
      expect(DateFormat.jm('en_US').pattern, isNot(contains('H')));
      expect(DateFormat.jm('en_GB').pattern, contains('H'));
      expect(DateFormat.jm('fr_FR').pattern, contains('H'));
      expect(DateFormat.jm('de_DE').pattern, contains('H'));
      expect(DateFormat.jm('ja_JP').pattern, contains('H'));
    });

    test('should render the 24h string for a 24h locale (en_GB)', () {
      // No AM/PM marker, so no non-breaking space is introduced.
      expect(at1530.makeDisplayTime(locale: 'en_GB'), equals('15:30'));
    });

    test('should render the 24h string for fr_FR', () {
      expect(at1530.makeDisplayTime(locale: 'fr_FR'), equals('15:30'));
    });
  });

  // ===========================================================================
  // makeDisplayTime non-breaking invariant.
  // ===========================================================================
  group('makeDisplayTime non-breaking clock', () {
    final DateTime at2031 = DateTime(2026, 1, 15, 20, 31);

    test('should join the clock and AM/PM (visible content 8:31 PM)', () {
      expect(visible(at2031.makeDisplayTime(locale: 'en_US')), equals('8:31 PM'));
    });

    test('should contain no ASCII space but a non-breaking space in the 12h clock', () {
      final String? result = at2031.makeDisplayTime(locale: 'en_US');
      expect(result, isNotNull);
      // The clock must never carry a wrappable ASCII space (0x20).
      expect(result!.codeUnits, isNot(contains(0x20)));
      // It must carry a non-breaking space: U+00A0 (the extension's own replace
      // of an ASCII space) OR U+202F (the narrow no-break space some CLDR data
      // ships directly). Accept either so the test does not pin one intl build.
      final bool hasNonBreaking =
          result.codeUnits.contains(0x00A0) || result.codeUnits.contains(0x202F);
      expect(hasNonBreaking, isTrue);
    });
  });

  // ===========================================================================
  // utcTimeDisplay — fixed-form presets, non-breaking.
  // ===========================================================================
  group('utcTimeDisplay', () {
    final DateTime at2031 = DateTime(2026, 1, 15, 20, 31, 45);

    test('should strip ASCII space from the twelveHourAMPM clock', () {
      final String result =
          at2031.utcTimeDisplay(UtcTimeDisplayEnum.twelveHourAMPM, locale: 'en_US');
      expect(result.contains(' '), isFalse);
      expect(result, startsWith('8:31'));
      expect(result, endsWith('PM'));
    });

    test('should return twentyFourHour unchanged (no space to break)', () {
      expect(
        at2031.utcTimeDisplay(UtcTimeDisplayEnum.twentyFourHour, locale: 'en_US'),
        equals('20:31'),
      );
    });

    test('should render twelveHourWithSecondsAMPM with seconds', () {
      final String result =
          at2031.utcTimeDisplay(UtcTimeDisplayEnum.twelveHourWithSecondsAMPM, locale: 'en_US');
      expect(result, startsWith('8:31:45'));
      expect(result, endsWith('PM'));
    });

    test('should render twentyFourHourWithSeconds as HH:mm:ss', () {
      expect(
        at2031.utcTimeDisplay(UtcTimeDisplayEnum.twentyFourHourWithSeconds, locale: 'en_US'),
        equals('20:31:45'),
      );
    });

    test('should render twelveHour without an AM/PM marker', () {
      expect(
        at2031.utcTimeDisplay(UtcTimeDisplayEnum.twelveHour, locale: 'en_US'),
        equals('8:31'),
      );
    });

    test('should render amPmOnly as just the marker', () {
      expect(
        at2031.utcTimeDisplay(UtcTimeDisplayEnum.amPmOnly, locale: 'en_US'),
        equals('PM'),
      );
    });
  });

  // ===========================================================================
  // formatByLocale — locale short date and the dd MMM yy override.
  // ===========================================================================
  group('formatByLocale', () {
    final DateTime aug16_2023 = DateTime(2023, 8, 16);

    test('should render month-first short date for en_US', () {
      expect(aug16_2023.formatByLocale(locale: 'en_US'), equals('8/16/2023'));
    });

    test('should render day-first short date for en_GB', () {
      expect(aug16_2023.formatByLocale(locale: 'en_GB'), equals('16/08/2023'));
    });

    test('should force the dd MMM yy layout when ddMMyyFormat is true', () {
      expect(
        aug16_2023.formatByLocale(locale: 'en_US', ddMMyyFormat: true),
        equals('16 Aug 23'),
      );
    });

    test('should return null for an unknown locale (no throw)', () {
      expect(() => aug16_2023.formatByLocale(locale: 'xx_YY'), returnsNormally);
      expect(aug16_2023.formatByLocale(locale: 'xx_YY'), isNull);
    });
  });

  // ===========================================================================
  // toDateFormat — explicit pattern, milliseconds, invalid-pattern contract.
  // ===========================================================================
  group('toDateFormat', () {
    final DateTime at2230 = DateTime(2026, 1, 15, 22, 30, 45, 137);

    test('should format with an explicit pattern', () {
      expect(at2230.toDateFormat('HH:mm:ss'), equals('22:30:45'));
    });

    test('should append 4-digit milliseconds when requested', () {
      expect(
        at2230.toDateFormat('HH:mm:ss', showLogTimeMilliseconds: true),
        equals('22:30:45.0137'),
      );
    });

    test('should return empty string for an invalid pattern (no throw)', () {
      // A bare unescaped letter that is not a valid field throws inside intl;
      // the catch contract must degrade to '' rather than propagate.
      expect(() => at2230.toDateFormat('q'), returnsNormally);
      expect(at2230.toDateFormat('q'), equals(''));
    });
  });

  // ===========================================================================
  // Boundary / robustness — leap day, year extremes, month/day edges, UTC vs
  // local, DST instants.
  // ===========================================================================
  group('date boundaries and robustness', () {
    test('should format the leap day Feb 29 2024 without error', () {
      expect(DateTime(2024, 2, 29).fullDateDisplay(locale: 'en_US'), equals('February 29, 2024'));
    });

    test('should format the non-leap Feb 28 without error', () {
      expect(DateTime(2023, 2, 28).fullDateDisplay(locale: 'en_US'), equals('February 28, 2023'));
    });

    test('should format Jan 1 and Dec 31 month/day boundaries', () {
      expect(DateTime(2026).dateDisplay(locale: 'en_US'), equals('Jan 1, 2026'));
      expect(DateTime(2026, 12, 31).dateDisplay(locale: 'en_US'), equals('Dec 31, 2026'));
    });

    test('should render a very large year (9999)', () {
      expect(DateTime(9999, 1, 15).dateDisplay(locale: 'en_US'), equals('Jan 15, 9999'));
    });

    test('should format year 1 without error', () {
      expect(() => DateTime(1, 1, 15).fullDateDisplay(locale: 'en_US'), returnsNormally);
    });

    test('should format a UTC DateTime identically to a local one with the same fields', () {
      // Formatting reads wall-clock fields, not the offset; both must match.
      final DateTime local = DateTime(2026, 1, 15, 15, 30);
      final DateTime utc = DateTime.utc(2026, 1, 15, 15, 30);
      expect(utc.makeDisplayTime(locale: 'en_US'), equals(local.makeDisplayTime(locale: 'en_US')));
      expect(utc.dateDisplay(locale: 'en_US'), equals(local.dateDisplay(locale: 'en_US')));
    });

    test('should produce a valid string for a normalized DST spring-forward instant', () {
      // 02:30 may not exist on a spring-forward day; DateTime normalizes it and
      // formatting must still return a non-empty string without throwing.
      final DateTime springForward = DateTime(2026, 3, 8, 2, 30);
      expect(() => springForward.makeDisplayTime(locale: 'en_US'), returnsNormally);
      expect(springForward.makeDisplayTime(locale: 'en_US'), isNotNull);
    });

    test('should produce a valid string for a fall-back DST instant that occurs twice', () {
      final DateTime fallBack = DateTime(2026, 11, 1, 1, 30);
      expect(() => fallBack.makeDisplayTime(locale: 'en_US'), returnsNormally);
      expect(fallBack.makeDisplayTime(locale: 'en_US'), isNotNull);
    });
  });

  // ===========================================================================
  // Empty / null locale degradation.
  // ===========================================================================
  group('locale degradation', () {
    final DateTime jan15_1945 = DateTime(1945, 1, 15);

    test('should not throw and return non-null for a null locale after init', () {
      expect(() => jan15_1945.fullDateDisplay(), returnsNormally);
      expect(jan15_1945.makeDisplayDate(), isNotNull);
    });

    test('should degrade an empty-string locale without throwing', () {
      // An empty locale resolves to intl's default rather than throwing; the
      // contract is simply "no throw, returns a usable value".
      expect(() => jan15_1945.fullDateDisplay(locale: ''), returnsNormally);
      expect(() => jan15_1945.formatByLocale(locale: ''), returnsNormally);
    });
  });
}
