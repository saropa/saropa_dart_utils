// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_relative_predicate_extensions.dart';

void main() {
  group('RelativeTimeUtils', () {
    // --- Verbatim sample tests from the spec ----------------------------------
    group('spec sample cases', () {
      test('isYesterday returns true for yesterday', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime yesterday = DateTime(2024, 6, 14);
        expect(yesterday.isYesterday(now: now), isTrue);
      });

      test('isYesterday returns false for today', () {
        final DateTime now = DateTime(2024, 6, 15);

        // Ignoring because NOT self-comparison
        // ignore: avoid-passing-self-as-argument
        expect(now.isYesterday(now: now), isFalse);
      });

      test('isTomorrow returns true for tomorrow', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime tomorrow = DateTime(2024, 6, 16);
        expect(tomorrow.isTomorrow(now: now), isTrue);
      });

      test('isOlderThanToday returns true for past dates', () {
        final DateTime now = DateTime(2024, 6, 15, 12, 0);
        final DateTime yesterday = DateTime(2024, 6, 14);
        expect(yesterday.isOlderThanToday(now: now), isTrue);
      });

      test('isOlderThanToday returns false for today', () {
        final DateTime now = DateTime(2024, 6, 15, 12, 0);
        final DateTime today = DateTime(2024, 6, 15, 8, 0);
        expect(today.isOlderThanToday(now: now), isFalse);
      });

      test('relativeTime returns correct string for moments', () {
        final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
        final DateTime seconds = DateTime(2024, 6, 15, 11, 59, 30);
        final String? result = seconds.relativeTime(now: now);
        expect(result, contains('moment'));
      });

      test('relativeTime returns correct string for minutes', () {
        final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
        final DateTime minutes = DateTime(2024, 6, 15, 11, 55, 0);
        final String? result = minutes.relativeTime(now: now);
        expect(result, contains('minute'));
      });

      test('relativeTime returns correct string for hours', () {
        final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
        final DateTime hours = DateTime(2024, 6, 15, 9, 0, 0);
        final String? result = hours.relativeTime(now: now);
        expect(result, contains('hour'));
      });

      test('relativeTime returns correct string for days', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime days = DateTime(2024, 6, 10);
        final String? result = days.relativeTime(now: now);
        expect(result, contains('day'));
      });

      test('relativeTime returns correct string for years', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime years = DateTime(2020, 6, 15);
        final String? result = years.relativeTime(now: now);
        expect(result, contains('year'));
      });

      test('relativeTime handles future dates', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime future = DateTime(2024, 6, 20);
        final String? result = future.relativeTime(now: now);
        expect(result, contains('from now'));
      });
    });

    // --- isYesterday ----------------------------------------------------------
    group('isYesterday', () {
      test('false for two days ago', () {
        final DateTime now = DateTime(2024, 6, 15);
        expect(DateTime(2024, 6, 13).isYesterday(now: now), isFalse);
      });

      test('false for tomorrow', () {
        final DateTime now = DateTime(2024, 6, 15);
        expect(DateTime(2024, 6, 16).isYesterday(now: now), isFalse);
      });

      test('ignores time-of-day: this at 23:59, now at 00:01 next day', () {
        final DateTime now = DateTime(2024, 6, 15, 0, 1);
        final DateTime late = DateTime(2024, 6, 14, 23, 59);
        expect(late.isYesterday(now: now), isTrue);
      });

      test('rolls over the month: 2024-02-29 is yesterday of 2024-03-01', () {
        final DateTime now = DateTime(2024, 3); // 2024-03-01
        expect(DateTime(2024, 2, 29).isYesterday(now: now), isTrue);
      });

      test('rolls over the year: 2023-12-31 is yesterday of 2024-01-01', () {
        final DateTime now = DateTime(2024); // 2024-01-01
        expect(DateTime(2023, 12, 31).isYesterday(now: now), isTrue);
      });

      test('non-leap year: 2023-02-28 is yesterday of 2023-03-01 (no Feb 29)', () {
        final DateTime now = DateTime(2023, 3); // 2023-03-01
        expect(DateTime(2023, 2, 28).isYesterday(now: now), isTrue);
      });

      test('century non-leap year 2100: 2100-02-28 is yesterday of 2100-03-01', () {
        // 2100 is divisible by 100 but not 400, so it is NOT a leap year.
        final DateTime now = DateTime(2100, 3); // 2100-03-01
        expect(DateTime(2100, 2, 28).isYesterday(now: now), isTrue);
        expect(DateTime(2100, 2, 29).isYesterday(now: now), isFalse);
      });

      test('defaults now to DateTime.now() and does not throw', () {
        final DateTime nearYesterday = DateTime.now().subtract(const Duration(days: 1));
        // No now passed: exercises the `?? DateTime.now()` branch.
        expect(() => nearYesterday.isYesterday(), returnsNormally);
      });
    });

    // --- isTomorrow -----------------------------------------------------------
    group('isTomorrow', () {
      test('false for today', () {
        final DateTime now = DateTime(2024, 6, 15);
        // ignore: avoid-passing-self-as-argument
        expect(now.isTomorrow(now: now), isFalse);
      });

      test('false for two days ahead', () {
        final DateTime now = DateTime(2024, 6, 15);
        expect(DateTime(2024, 6, 17).isTomorrow(now: now), isFalse);
      });

      test('ignores time-of-day: this at 23:59, now at 00:01 prior day', () {
        final DateTime now = DateTime(2024, 6, 15, 0, 1);
        final DateTime late = DateTime(2024, 6, 16, 23, 59);
        expect(late.isTomorrow(now: now), isTrue);
      });

      test('rolls over the year: 2025-01-01 is tomorrow of 2024-12-31', () {
        final DateTime now = DateTime(2024, 12, 31);
        expect(DateTime(2025).isTomorrow(now: now), isTrue);
      });

      test('leap-year boundary: 2024-02-29 is tomorrow of 2024-02-28', () {
        final DateTime now = DateTime(2024, 2, 28);
        expect(DateTime(2024, 2, 29).isTomorrow(now: now), isTrue);
      });

      test('non-leap boundary: 2023-03-01 is tomorrow of 2023-02-28', () {
        final DateTime now = DateTime(2023, 2, 28);
        expect(DateTime(2023, 3).isTomorrow(now: now), isTrue);
      });

      test('defaults now to DateTime.now() and does not throw', () {
        final DateTime nearTomorrow = DateTime.now().add(const Duration(days: 1));
        expect(() => nearTomorrow.isTomorrow(), returnsNormally);
      });
    });

    // --- isOlderThanToday -----------------------------------------------------
    group('isOlderThanToday', () {
      test('true for last week', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        expect(DateTime(2024, 6, 8).isOlderThanToday(now: now), isTrue);
      });

      test('false for the exact start-of-today instant (00:00:00.000)', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        final DateTime startOfToday = DateTime(2024, 6, 15);
        // Boundary is exclusive: start-of-today is NOT older than today.
        expect(startOfToday.isOlderThanToday(now: now), isFalse);
      });

      test('true for one microsecond before start-of-today', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        final DateTime justBefore = DateTime(2024, 6, 15).subtract(const Duration(microseconds: 1));
        expect(justBefore.isOlderThanToday(now: now), isTrue);
      });

      test('false for a future date', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        expect(DateTime(2024, 6, 16).isOlderThanToday(now: now), isFalse);
      });

      test('defaults now to DateTime.now() and does not throw', () {
        final DateTime past = DateTime.now().subtract(const Duration(days: 3));
        expect(() => past.isOlderThanToday(), returnsNormally);
        expect(past.isOlderThanToday(), isTrue);
      });
    });

    // --- isOlderThanYesterday (zero existing coverage in source app) ----------
    group('isOlderThanYesterday', () {
      test('true for two days ago', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        expect(DateTime(2024, 6, 13).isOlderThanYesterday(now: now), isTrue);
      });

      test('false for yesterday (mid-day)', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        expect(DateTime(2024, 6, 14, 9).isOlderThanYesterday(now: now), isFalse);
      });

      test('false for the exact start-of-yesterday instant (boundary exclusive)', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        final DateTime startOfYesterday = DateTime(2024, 6, 14);
        expect(startOfYesterday.isOlderThanYesterday(now: now), isFalse);
      });

      test('true for one microsecond before start-of-yesterday', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        final DateTime justBefore = DateTime(2024, 6, 14).subtract(const Duration(microseconds: 1));
        expect(justBefore.isOlderThanYesterday(now: now), isTrue);
      });

      test('false for today', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        expect(DateTime(2024, 6, 15, 8).isOlderThanYesterday(now: now), isFalse);
      });

      test('defaults now to DateTime.now() and does not throw', () {
        final DateTime past = DateTime.now().subtract(const Duration(days: 5));
        expect(() => past.isOlderThanYesterday(), returnsNormally);
        expect(past.isOlderThanYesterday(), isTrue);
      });
    });

    // --- UTC vs local divergence between the two predicate families -----------
    group('UTC vs local receiver', () {
      test('isOlderThanToday uses instant comparison (offset-aware)', () {
        // 2024-06-15T00:30 UTC is the same instant as a later local clock in a
        // positive-offset reading; isBefore compares the absolute instants.
        final DateTime nowUtc = DateTime.utc(2024, 6, 15, 12);
        final DateTime earlierUtc = DateTime.utc(2024, 6, 14, 23);
        expect(earlierUtc.isOlderThanToday(now: nowUtc), isTrue);
      });

      test('isYesterday compares calendar fields (offset-ignoring)', () {
        // Field-based comparison: the displayed Y/M/D drives the result, so a
        // UTC receiver and UTC now one day apart match regardless of offset.
        final DateTime nowUtc = DateTime.utc(2024, 6, 15);
        final DateTime yUtc = DateTime.utc(2024, 6, 14, 23, 59);
        expect(yUtc.isYesterday(now: nowUtc), isTrue);
      });
    });

    // --- DST transition behavior (documented as not-DST-safe) -----------------
    group('DST transitions (fixed 24h add/subtract)', () {
      test('isTomorrow holds across the US spring-forward boundary by date math', () {
        // Using explicit UTC removes the zone variable so the calendar-field
        // assertion is deterministic on any CI host: add(1 day) lands on the
        // next calendar day and isSameDateOnly matches.
        final DateTime now = DateTime.utc(2024, 3, 10);
        expect(DateTime.utc(2024, 3, 11).isTomorrow(now: now), isTrue);
      });

      test('isYesterday holds across the US fall-back boundary by date math', () {
        final DateTime now = DateTime.utc(2024, 11, 3);
        expect(DateTime.utc(2024, 11, 2).isYesterday(now: now), isTrue);
      });
    });

    // --- relativeTime: exact equality and zero elapsed ------------------------
    group('relativeTime exact-equality short-circuit', () {
      test('returns "now" when this == now', () {
        final DateTime t = DateTime(2024, 6, 15, 12);
        // ignore: avoid-passing-self-as-argument
        expect(t.relativeTime(now: t), equals('now'));
      });

      test('not equal but within the same second uses the "a moment" path', () {
        final DateTime now = DateTime(2024, 6, 15, 12, 0, 0, 500);
        final DateTime t = DateTime(2024, 6, 15, 12, 0, 0, 0);
        // 500ms apart: below 45s, descriptive "a moment", not the == "now".
        expect(t.relativeTime(now: now), equals('a moment ago'));
      });
    });

    // --- relativeTime: past/future symmetry -----------------------------------
    group('relativeTime past/future symmetry', () {
      test('same magnitude yields identical body with ago vs from now', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        final DateTime past = DateTime(2024, 6, 15, 9); // 3h before
        final DateTime future = DateTime(2024, 6, 15, 15); // 3h after
        expect(past.relativeTime(now: now), equals('3 hours ago'));
        expect(future.relativeTime(now: now), equals('3 hours from now'));
      });
    });

    // --- relativeTime: bucket boundaries (just-below and just-at) --------------
    group('relativeTime bucket boundaries', () {
      final DateTime now = DateTime(2024, 6, 15, 12);

      DateTime before(Duration d) => now.subtract(d);

      test('just below 45s -> a moment', () {
        expect(
          before(const Duration(seconds: 44)).relativeTime(now: now),
          equals('a moment ago'),
        );
      });

      test('at 45s -> a minute', () {
        expect(
          before(const Duration(seconds: 45)).relativeTime(now: now),
          equals('a minute ago'),
        );
      });

      test('just below 90s -> a minute', () {
        expect(
          before(const Duration(seconds: 89)).relativeTime(now: now),
          equals('a minute ago'),
        );
      });

      test('at 90s -> 1 minute (numeric band starts)', () {
        expect(
          before(const Duration(seconds: 90)).relativeTime(now: now),
          equals('1 minute ago'),
        );
      });

      test('just below 45 minutes -> N minutes', () {
        expect(
          before(const Duration(minutes: 44)).relativeTime(now: now),
          equals('44 minutes ago'),
        );
      });

      test('at 45 minutes -> about an hour', () {
        expect(
          before(const Duration(minutes: 45)).relativeTime(now: now),
          equals('about an hour ago'),
        );
      });

      test('just below 100 minutes -> about an hour', () {
        expect(
          before(const Duration(minutes: 99)).relativeTime(now: now),
          equals('about an hour ago'),
        );
      });

      test('at 100 minutes -> 1 hour (hour band starts)', () {
        expect(
          before(const Duration(minutes: 100)).relativeTime(now: now),
          equals('1 hour ago'),
        );
      });

      test('just below 24 hours -> N hours', () {
        expect(
          before(const Duration(hours: 23)).relativeTime(now: now),
          equals('23 hours ago'),
        );
      });

      test('at 24 hours -> a day', () {
        expect(
          before(const Duration(hours: 24)).relativeTime(now: now),
          equals('a day ago'),
        );
      });

      test('just below 48 hours -> a day', () {
        expect(
          before(const Duration(hours: 47)).relativeTime(now: now),
          equals('a day ago'),
        );
      });

      test('at 48 hours -> 2 days (day band starts)', () {
        expect(
          before(const Duration(hours: 48)).relativeTime(now: now),
          equals('2 days ago'),
        );
      });

      test('just below 30 days -> N days', () {
        expect(
          before(const Duration(days: 29)).relativeTime(now: now),
          equals('29 days ago'),
        );
      });

      test('at 30 days -> about a month', () {
        expect(
          before(const Duration(days: 30)).relativeTime(now: now),
          equals('about a month ago'),
        );
      });

      test('just below 60 days -> about a month', () {
        expect(
          before(const Duration(days: 59)).relativeTime(now: now),
          equals('about a month ago'),
        );
      });

      test('at 60 days -> 2 months (month band starts)', () {
        expect(
          before(const Duration(days: 60)).relativeTime(now: now),
          equals('2 months ago'),
        );
      });

      test('just below 365 days resolves via the calendar-year path to months', () {
        // 364 days < 365 stays in the month band -> 12 months (364/30 floored).
        expect(
          before(const Duration(days: 364)).relativeTime(now: now),
          equals('12 months ago'),
        );
      });
    });

    // --- relativeTime: roundUp vs floor at fractional units --------------------
    group('relativeTime roundUp behavior', () {
      final DateTime now = DateTime(2024, 6, 15, 12);

      test('89.6 minutes: floor stays within "about an hour" band', () {
        // 89.6 min < 100 min -> still the about-an-hour cusp regardless of round.
        final DateTime t = now.subtract(const Duration(minutes: 89, seconds: 36));
        expect(t.relativeTime(now: now), equals('about an hour ago'));
        expect(
          t.relativeTime(now: now, roundUp: true),
          equals('about an hour ago'),
        );
      });

      test('2.6 days: floor -> 2 days, roundUp -> 3 days', () {
        final DateTime t = now.subtract(const Duration(days: 2, hours: 14, minutes: 24));
        expect(t.relativeTime(now: now), equals('2 days ago'));
        expect(t.relativeTime(now: now, roundUp: true), equals('3 days ago'));
      });

      test('1.6 hours within hour band: floor -> 1 hour, roundUp -> 2 hours', () {
        // 1.6h == 96 minutes, which is in the about-an-hour band (<100), so the
        // hour-band numeric rounding is exercised at 2.6h instead; here confirm
        // the 100-minute crossing: 1h40m = 100min -> 1 hour both ways.
        final DateTime t = now.subtract(const Duration(minutes: 100));
        expect(t.relativeTime(now: now), equals('1 hour ago'));
        expect(t.relativeTime(now: now, roundUp: true), equals('2 hours ago'));
      });
    });

    // --- relativeTime: singular vs plural -------------------------------------
    group('relativeTime plural and singular', () {
      final DateTime now = DateTime(2024, 6, 15, 12);

      test('1 minute vs 2 minutes', () {
        expect(
          now.subtract(const Duration(seconds: 90)).relativeTime(now: now),
          equals('1 minute ago'),
        );
        expect(
          now.subtract(const Duration(minutes: 2)).relativeTime(now: now),
          equals('2 minutes ago'),
        );
      });

      test('1 hour vs 2 hours', () {
        expect(
          now.subtract(const Duration(minutes: 100)).relativeTime(now: now),
          equals('1 hour ago'),
        );
        expect(
          now.subtract(const Duration(hours: 2)).relativeTime(now: now),
          equals('2 hours ago'),
        );
      });

      test('2 days (singular "a day" is the cusp, plural is N days)', () {
        expect(
          now.subtract(const Duration(hours: 24)).relativeTime(now: now),
          equals('a day ago'),
        );
        expect(
          now.subtract(const Duration(days: 2)).relativeTime(now: now),
          equals('2 days ago'),
        );
      });

      test('2 months', () {
        expect(
          now.subtract(const Duration(days: 60)).relativeTime(now: now),
          equals('2 months ago'),
        );
      });

      test('exactly 1 year -> "about a year" (not "1 year")', () {
        final DateTime oneYearAgo = DateTime(2023, 6, 15, 12);
        expect(oneYearAgo.relativeTime(now: now), equals('about a year ago'));
      });

      test('2 years -> "2 years"', () {
        final DateTime twoYearsAgo = DateTime(2022, 6, 15, 12);
        expect(twoYearsAgo.relativeTime(now: now), equals('2 years ago'));
      });
    });

    // --- relativeTime: terse mode exact tokens --------------------------------
    group('relativeTime terse mode (isDescriptive: false)', () {
      final DateTime now = DateTime(2024, 6, 15, 12);

      String? terse(DateTime t) => t.relativeTime(now: now, isDescriptive: false);

      test('now (sub-45s)', () {
        expect(terse(now.subtract(const Duration(seconds: 10))), equals('now ago'));
      });

      test('a min (45-90s)', () {
        expect(terse(now.subtract(const Duration(seconds: 60))), equals('a min ago'));
      });

      test('N min', () {
        expect(terse(now.subtract(const Duration(minutes: 5))), equals('5 min ago'));
      });

      test('~1h (45-100 min cusp)', () {
        expect(terse(now.subtract(const Duration(minutes: 50))), equals('~1h ago'));
      });

      test('N hr', () {
        expect(terse(now.subtract(const Duration(hours: 5))), equals('5 hr ago'));
      });

      test('~1d (24-48h cusp)', () {
        expect(terse(now.subtract(const Duration(hours: 30))), equals('~1d ago'));
      });

      test('N d', () {
        expect(terse(now.subtract(const Duration(days: 5))), equals('5 d ago'));
      });

      test('~1mo (30-60d cusp)', () {
        expect(terse(now.subtract(const Duration(days: 40))), equals('~1mo ago'));
      });

      test('N mo', () {
        expect(terse(now.subtract(const Duration(days: 90))), equals('3 mo ago'));
      });

      test('~1y (exactly one calendar year)', () {
        expect(terse(DateTime(2023, 6, 15, 12)), equals('~1y ago'));
      });

      test('N y', () {
        expect(terse(DateTime(2021, 6, 15, 12)), equals('3 y ago'));
      });
    });

    // --- relativeTime: suffix toggle ------------------------------------------
    group('relativeTime suffix toggle (isDescriptiveTimeSuffix: false)', () {
      final DateTime now = DateTime(2024, 6, 15, 12);

      test('strips "ago" in descriptive mode', () {
        expect(
          now
              .subtract(const Duration(minutes: 5))
              .relativeTime(now: now, isDescriptiveTimeSuffix: false),
          equals('5 minutes'),
        );
      });

      test('strips "from now" in descriptive mode', () {
        expect(
          now
              .add(const Duration(minutes: 5))
              .relativeTime(now: now, isDescriptiveTimeSuffix: false),
          equals('5 minutes'),
        );
      });

      test('combined with terse mode', () {
        expect(
          now
              .subtract(const Duration(hours: 5))
              .relativeTime(
                now: now,
                isDescriptive: false,
                isDescriptiveTimeSuffix: false,
              ),
          equals('5 hr'),
        );
      });
    });

    // --- relativeTime: calendar-year off-by-one near anniversaries -------------
    group('relativeTime year algorithm near anniversaries', () {
      test('birthday not yet reached this year -> 23 years, not 24', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime birth = DateTime(2000, 12, 31);
        // Dec-31 anniversary has not happened by Jun-15-2024, so back off one.
        expect(birth.relativeTime(now: now), equals('23 years ago'));
      });

      test('exactly on the anniversary -> 24 years', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime birth = DateTime(2000, 6, 15);
        expect(birth.relativeTime(now: now), equals('24 years ago'));
      });

      test('one day before the anniversary -> 23 years', () {
        final DateTime now = DateTime(2024, 6, 15);
        final DateTime birth = DateTime(2000, 6, 16);
        expect(birth.relativeTime(now: now), equals('23 years ago'));
      });
    });

    // --- relativeTime: leap-day anniversary -----------------------------------
    group('relativeTime leap-day anniversary (from 2020-02-29)', () {
      final DateTime birth = DateTime(2020, 2, 29);

      test('one day before the anniversary (2024-02-28) -> 3 years', () {
        // Feb-29 anniversary not yet reached on Feb-28 -> back off one to 3.
        expect(birth.relativeTime(now: DateTime(2024, 2, 28)), equals('3 years ago'));
      });

      test('on the leap anniversary (2024-02-29) -> 4 years', () {
        expect(birth.relativeTime(now: DateTime(2024, 2, 29)), equals('4 years ago'));
      });

      test('day after (2024-03-01) -> 4 years', () {
        expect(birth.relativeTime(now: DateTime(2024, 3)), equals('4 years ago'));
      });
    });

    // --- relativeTime: extremes -----------------------------------------------
    group('relativeTime extremes', () {
      test('epoch 0 receiver against a much later now produces sane years', () {
        final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
        final DateTime now = DateTime.utc(2024, 6, 15);
        final String? result = epoch.relativeTime(now: now);
        expect(result, equals('54 years ago'));
      });

      test('far-future receiver yields a finite "from now" year count', () {
        final DateTime now = DateTime.utc(2024, 6, 15);
        final DateTime farFuture = DateTime.utc(9999, 12, 31);
        final String? result = farFuture.relativeTime(now: now);
        expect(result, contains('years from now'));
        // No Infinity / NaN leaks into the rendered string.
        expect(result, isNot(contains('Infinity')));
        expect(result, isNot(contains('NaN')));
      });

      test('far-past receiver yields a finite "ago" year count', () {
        final DateTime now = DateTime.utc(2024, 6, 15);
        final DateTime farPast = DateTime.utc(1, 1);
        final String? result = farPast.relativeTime(now: now);
        expect(result, contains('years ago'));
        expect(result, isNot(contains('Infinity')));
        expect(result, isNot(contains('NaN')));
      });
    });

    // --- relativeTime: UTC receiver with local now ----------------------------
    group('relativeTime UTC receiver', () {
      test('UTC receiver and UTC now are zone-safe (absolute-instant math)', () {
        final DateTime now = DateTime.utc(2024, 6, 15, 12);
        final DateTime t = DateTime.utc(2024, 6, 15, 9); // 3h earlier
        expect(t.relativeTime(now: now), equals('3 hours ago'));
      });
    });

    // --- relativeTime: null contract and no non-finite leakage ----------------
    group('relativeTime null and finiteness contract', () {
      test('ordinary inputs never return null', () {
        final DateTime now = DateTime(2024, 6, 15, 12);
        final List<DateTime> samples = <DateTime>[
          now.subtract(const Duration(seconds: 10)),
          now.subtract(const Duration(minutes: 5)),
          now.subtract(const Duration(hours: 5)),
          now.subtract(const Duration(days: 5)),
          now.subtract(const Duration(days: 90)),
          DateTime(2020, 6, 15),
          now.add(const Duration(days: 400)),
        ];
        for (final DateTime s in samples) {
          expect(s.relativeTime(now: now), isNotNull);
        }
      });

      test('a span crossing year bands stays finite (no Infinity/NaN)', () {
        final DateTime now = DateTime.utc(2024, 6, 15);
        final DateTime t = DateTime.utc(1900);
        final String? result = t.relativeTime(now: now);
        expect(result, isNotNull);
        expect(result, isNot(contains('Infinity')));
        expect(result, isNot(contains('NaN')));
      });
    });

    // --- relativeTime: DST-band millisecond correctness -----------------------
    group('relativeTime DST band uses millisecond math, not wall-clock', () {
      test('a 25-hour real span still lands in the day band as ~2 days floor', () {
        // Build the span from an explicit Duration so the math is absolute
        // milliseconds regardless of any host DST rules.
        final DateTime now = DateTime.utc(2024, 11, 4, 12);
        final DateTime t = now.subtract(const Duration(hours: 49)); // ~2.04 days
        expect(t.relativeTime(now: now), equals('2 days ago'));
      });
    });
  });
}
