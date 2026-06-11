// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/simple_relative_day_utils.dart';

void main() {
  group('SimpleRelativeDay', () {
    // Sunday 2024-12-29 is the canonical reference for most cases so the
    // weekday math ("Last/Next Wednesday") is deterministic.
    group('getSimpleRelativeDay', () {
      test('should return today for the same calendar day', () {
        final DateTime now = DateTime(2024, 12, 29, 10, 30);
        final DateTime date = DateTime(2024, 12, 29, 15, 45);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.today);
      });

      test('should return yesterday for the previous day', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 28);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.yesterday);
      });

      test('should return tomorrow for the next day', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 30);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.tomorrow);
      });

      test('should return beforeYesterday for 2 days ago', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 27);

        expect(
          date.getSimpleRelativeDay(now: now),
          SimpleRelativeDay.beforeYesterday,
        );
      });

      test('should return afterTomorrow for 2 days ahead', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 31);

        expect(
          date.getSimpleRelativeDay(now: now),
          SimpleRelativeDay.afterTomorrow,
        );
      });

      test('should return nextWeekday for 3-6 days ahead', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 1, 1); // 3 days ahead

        expect(
          date.getSimpleRelativeDay(now: now),
          SimpleRelativeDay.nextWeekday,
        );
      });

      test('should return lastWeekday for 3-6 days ago', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 25); // 4 days ago

        expect(
          date.getSimpleRelativeDay(now: now),
          SimpleRelativeDay.lastWeekday,
        );
      });

      test('should return nextWeekday for 7-13 days ahead', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 1, 7); // 9 days ahead

        expect(
          date.getSimpleRelativeDay(now: now),
          SimpleRelativeDay.nextWeekday,
        );
      });

      test('should return lastWeekday for 7-13 days ago', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 19); // 10 days ago

        expect(
          date.getSimpleRelativeDay(now: now),
          SimpleRelativeDay.lastWeekday,
        );
      });

      test('should return nextMonth for dates in the next month', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 1, 20); // 22 days ahead

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.nextMonth);
      });

      test('should return lastMonth for dates in the previous month', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 11, 15);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.lastMonth);
      });

      test('should return null for same month but more than 2 weeks away', () {
        final DateTime now = DateTime(2024, 12, 1);
        final DateTime date = DateTime(2024, 12, 25); // 24 days ahead, same month

        expect(date.getSimpleRelativeDay(now: now), isNull);
      });

      test('should return null for dates more than a month away', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 3, 15);

        expect(date.getSimpleRelativeDay(now: now), isNull);
      });
    });

    // The library drops the excluded l10n displayLabel; these mirror the
    // original displayLabel assertions as type + weekdayName checks.
    group('getRelativeDayResult', () {
      test('should classify today with no weekday name', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 29);

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.today);
        expect(result?.weekdayName, isNull);
      });

      test('should classify yesterday with no weekday name', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 28);

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.yesterday);
        expect(result?.weekdayName, isNull);
      });

      test('should classify tomorrow with no weekday name', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 30);

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.tomorrow);
        expect(result?.weekdayName, isNull);
      });

      test('should classify the day before yesterday', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 27);

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.beforeYesterday);
        expect(result?.weekdayName, isNull);
      });

      test('should classify the day after tomorrow', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 31);

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.afterTomorrow);
        expect(result?.weekdayName, isNull);
      });

      test('should give nextWeekday + Wednesday for 3 days ahead on Sunday', () {
        final DateTime now = DateTime(2024, 12, 29); // Sunday
        final DateTime date = DateTime(2025, 1, 1); // Wednesday

        final RelativeDayResult? result = date.getRelativeDayResult(
          now: now,
          weekdayFormatter: _weekdayName,
        );
        expect(result?.type, SimpleRelativeDay.nextWeekday);
        expect(result?.weekdayName, 'Wednesday');
      });

      test('should give lastWeekday + Wednesday for Christmas on Sunday', () {
        final DateTime now = DateTime(2024, 12, 29); // Sunday
        final DateTime date = DateTime(2024, 12, 25); // Wednesday

        final RelativeDayResult? result = date.getRelativeDayResult(
          now: now,
          weekdayFormatter: _weekdayName,
        );
        expect(result?.type, SimpleRelativeDay.lastWeekday);
        expect(result?.weekdayName, 'Wednesday');
      });

      test('should give nextWeekday + Sunday for 7 days ahead', () {
        final DateTime now = DateTime(2024, 12, 29); // Sunday
        final DateTime date = DateTime(2025, 1, 5); // Sunday

        final RelativeDayResult? result = date.getRelativeDayResult(
          now: now,
          weekdayFormatter: _weekdayName,
        );
        expect(result?.type, SimpleRelativeDay.nextWeekday);
        expect(result?.weekdayName, 'Sunday');
      });

      test('should give lastWeekday + Sunday for 7 days ago', () {
        final DateTime now = DateTime(2024, 12, 29); // Sunday
        final DateTime date = DateTime(2024, 12, 22); // Sunday

        final RelativeDayResult? result = date.getRelativeDayResult(
          now: now,
          weekdayFormatter: _weekdayName,
        );
        expect(result?.type, SimpleRelativeDay.lastWeekday);
        expect(result?.weekdayName, 'Sunday');
      });

      test('should give nextMonth (no weekday) beyond 2 weeks next month', () {
        final DateTime now = DateTime(2024, 12, 15);
        final DateTime date = DateTime(2025, 1, 20); // next month

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.nextMonth);
        expect(result?.weekdayName, isNull);
      });

      test('should give lastMonth for dates in the previous month', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 11, 10);

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.lastMonth);
        expect(result?.weekdayName, isNull);
      });

      test('should return null for dates several months away', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 6, 15);

        expect(date.getRelativeDayResult(now: now), isNull);
      });
    });

    // Off-by-one across bucket edges is the dominant failure mode; lock every
    // boundary explicitly on both sides.
    group('exact bucket boundaries', () {
      final DateTime now = DateTime(2024, 12, 29);

      test('should treat +2 as afterTomorrow and +3 as nextWeekday', () {
        expect(
          DateTime(2024, 12, 31).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.afterTomorrow,
        );
        expect(
          DateTime(2025, 1, 1).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.nextWeekday,
        );
      });

      test('should treat -2 as beforeYesterday and -3 as lastWeekday', () {
        expect(
          DateTime(2024, 12, 27).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.beforeYesterday,
        );
        expect(
          DateTime(2024, 12, 26).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.lastWeekday,
        );
      });

      test('should keep both +6 and +7 in nextWeekday (no internal gap)', () {
        expect(
          DateTime(2025, 1, 4).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.nextWeekday,
        );
        expect(
          DateTime(2025, 1, 5).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.nextWeekday,
        );
      });

      test('should keep both -6 and -7 in lastWeekday (no internal gap)', () {
        expect(
          DateTime(2024, 12, 23).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.lastWeekday,
        );
        expect(
          DateTime(2024, 12, 22).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.lastWeekday,
        );
      });

      test('should treat +13 as nextWeekday and +14 falls through', () {
        // now = Dec 29. +13 = Jan 11 (still weekday window). +14 = Jan 12 is in
        // the NEXT calendar month (monthDiff == +1), so per the spec it falls
        // through the weekday window to nextMonth, not null.
        expect(
          DateTime(2025, 1, 11).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.nextWeekday,
        );
        expect(
          DateTime(2025, 1, 12).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.nextMonth,
        );
      });

      test('should treat -13 as lastWeekday and -14 falls through', () {
        // -13 = Dec 16 (weekday window); -14 = Dec 15 same month → null.
        expect(
          DateTime(2024, 12, 16).getSimpleRelativeDay(now: now),
          SimpleRelativeDay.lastWeekday,
        );
        expect(DateTime(2024, 12, 15).getSimpleRelativeDay(now: now), isNull);
      });
    });

    // The null window vs monthDiff interaction is the subtle zone.
    group('null boundary and monthDiff interaction', () {
      test('should return null for +14..+20 in the same calendar month', () {
        final DateTime now = DateTime(2024, 12, 1);
        expect(DateTime(2024, 12, 15).getSimpleRelativeDay(now: now), isNull);
        expect(DateTime(2024, 12, 21).getSimpleRelativeDay(now: now), isNull);
      });

      test('should return nextMonth when +14 lands in the next month', () {
        final DateTime now = DateTime(2025, 1, 20);
        final DateTime date = DateTime(2025, 2, 3); // 14 days, monthDiff == 1

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.nextMonth);
      });

      test('should return nextMonth even when the day delta is large', () {
        final DateTime now = DateTime(2025, 1, 1);
        final DateTime date = DateTime(2025, 2, 28); // ~58 days, monthDiff == 1

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.nextMonth);
      });

      test('should return null for monthDiff of +2 and -2', () {
        final DateTime now = DateTime(2025, 1, 15);
        expect(
          DateTime(2025, 3, 15).getSimpleRelativeDay(now: now),
          isNull,
        ); // +2
        expect(
          DateTime(2024, 11, 15).getSimpleRelativeDay(now: now),
          isNull,
        ); // -2
      });

      test('should treat Dec→Jan cross-year as nextMonth', () {
        final DateTime now = DateTime(2024, 12, 20);
        final DateTime date = DateTime(2025, 1, 20); // monthDiff == 1

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.nextMonth);
      });

      test('should treat Jan→Dec cross-year as lastMonth', () {
        final DateTime now = DateTime(2025, 1, 20);
        final DateTime date = DateTime(2024, 12, 20); // monthDiff == -1

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.lastMonth);
      });
    });

    // Month-length and leap edges where day arithmetic is easy to get wrong.
    group('month-length and leap edges', () {
      test('should treat Feb 29 → Mar 1 in a leap year as tomorrow', () {
        final DateTime now = DateTime(2024, 2, 29);
        final DateTime date = DateTime(2024, 3, 1);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.tomorrow);
      });

      test('should treat Feb 29 → Feb 28 in a leap year as yesterday', () {
        final DateTime now = DateTime(2024, 2, 29);
        final DateTime date = DateTime(2024, 2, 28);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.yesterday);
      });

      test('should return null for Jan 31 → Mar 1 (monthDiff == 2)', () {
        // Skips short February; the day delta is large but monthDiff wins.
        final DateTime now = DateTime(2024, 1, 31);
        final DateTime date = DateTime(2024, 3, 1);

        expect(date.getSimpleRelativeDay(now: now), isNull);
      });

      test('should treat Mar 31 → Feb 28 as lastMonth (monthDiff == -1)', () {
        final DateTime now = DateTime(2024, 3, 31);
        final DateTime date = DateTime(2024, 2, 28);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.lastMonth);
      });
    });

    group('year and month boundary rollovers', () {
      test('should treat year boundary as tomorrow', () {
        final DateTime now = DateTime(2024, 12, 31);
        final DateTime date = DateTime(2025, 1, 1);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.tomorrow);
      });

      test('should treat year boundary as yesterday', () {
        final DateTime now = DateTime(2025, 1, 1);
        final DateTime date = DateTime(2024, 12, 31);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.yesterday);
      });

      test('should treat Jan 31 → Feb 15 as nextMonth', () {
        final DateTime now = DateTime(2024, 1, 31);
        final DateTime date = DateTime(2024, 2, 15);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.nextMonth);
      });

      test('should treat Feb 1 → Jan 15 as lastMonth', () {
        final DateTime now = DateTime(2024, 2, 1);
        final DateTime date = DateTime(2024, 1, 15);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.lastMonth);
      });
    });

    // Time-of-day must be fully dropped; only the calendar day matters.
    group('time component is dropped', () {
      test('should ignore time of day at a midnight boundary', () {
        final DateTime now = DateTime(2024, 12, 29, 23, 59, 59);
        final DateTime date = DateTime(2024, 12, 30, 0, 0, 1);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.tomorrow);
      });

      test('should treat exact-midnight equal dates as today', () {
        final DateTime now = DateTime(2024, 12, 29, 0, 0, 0);
        final DateTime date = DateTime(2024, 12, 29, 0, 0, 0);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.today);
      });

      test('should drop a one-microsecond difference around midnight', () {
        // 23:59:59.999999 same calendar day → today, not yesterday.
        final DateTime now = DateTime(2024, 12, 29, 12);
        final DateTime date = DateTime(2024, 12, 29, 23, 59, 59, 999, 999);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.today);
      });
    });

    // The real inDays correctness risk: DST short days and UTC/local kind.
    group('DST and UTC/local kind', () {
      test('should yield whole calendar days across a DST spring-forward', () {
        // US spring-forward 2024-03-10 is a 23-hour local day; date-only
        // truncation must still report a one-day delta, not zero.
        final DateTime now = DateTime(2024, 3, 10, 1, 30);
        final DateTime date = DateTime(2024, 3, 11, 1, 30);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.tomorrow);
      });

      test('should keep same-kind UTC inputs on whole-day boundaries', () {
        final DateTime now = DateTime.utc(2024, 12, 29, 23, 59);
        final DateTime date = DateTime.utc(2024, 12, 30, 0, 1);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.tomorrow);
      });

      test('should classify same-kind UTC dates the same as local', () {
        final DateTime now = DateTime.utc(2024, 12, 29);
        final DateTime date = DateTime.utc(2024, 12, 28);

        expect(date.getSimpleRelativeDay(now: now), SimpleRelativeDay.yesterday);
      });
    });

    group('extremes and degenerate inputs', () {
      test('should not throw and not crash at Dart DateTime extremes', () {
        final DateTime low = DateTime(1);
        // Dart's max instant is 275760-09-13 in UTC, but the LOCAL max lands a
        // few hours earlier, so DateTime(275760, 9, 13) throws on construction
        // in a behind-UTC zone. Use the day before, which is constructible in
        // every zone and still exercises the far-extreme overflow path.
        final DateTime high = DateTime(275760, 9, 12);

        // Same extreme value compares as today; far-apart extremes are null,
        // and the (year - year) * 12 product must not overflow or throw.
        expect(low.getSimpleRelativeDay(now: low), SimpleRelativeDay.today);
        expect(high.getSimpleRelativeDay(now: high), SimpleRelativeDay.today);
        expect(high.getSimpleRelativeDay(now: low), isNull);
        expect(low.getSimpleRelativeDay(now: high), isNull);
      });

      test('should not throw when now defaults to DateTime.now()', () {
        // Cannot assert an exact bucket against the wall clock; assert only
        // that the same-day call is non-throwing and typed.
        final DateTime date = DateTime.now();

        expect(date.getSimpleRelativeDay(), isA<SimpleRelativeDay?>());
      });
    });

    // No call may ever produce a value the classifier does not define; sweep a
    // wide delta range and assert membership in the supported set.
    group('only supported buckets are ever returned', () {
      test('should never return an unsupported bucket across ±400 days', () {
        final DateTime now = DateTime(2024, 6, 15);
        const Set<SimpleRelativeDay> supported = <SimpleRelativeDay>{
          SimpleRelativeDay.today,
          SimpleRelativeDay.yesterday,
          SimpleRelativeDay.tomorrow,
          SimpleRelativeDay.beforeYesterday,
          SimpleRelativeDay.afterTomorrow,
          SimpleRelativeDay.lastWeekday,
          SimpleRelativeDay.nextWeekday,
          SimpleRelativeDay.lastMonth,
          SimpleRelativeDay.nextMonth,
        };

        for (int delta = -400; delta <= 400; delta++) {
          final DateTime date = now.add(Duration(days: delta));
          final SimpleRelativeDay? bucket = date.getSimpleRelativeDay(now: now);
          if (bucket != null) {
            expect(supported.contains(bucket), isTrue, reason: 'delta=$delta');
          }
        }
      });
    });

    // The weekday label is entirely the caller's: forwarded verbatim, never
    // invoked for non-weekday buckets, and never swallowed when it throws.
    group('weekday formatter behavior', () {
      test('should forward the formatter output verbatim', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 1, 1); // nextWeekday

        final RelativeDayResult? result = date.getRelativeDayResult(
          now: now,
          weekdayFormatter: (_) => 'CUSTOM-LABEL',
        );
        expect(result?.weekdayName, 'CUSTOM-LABEL');
      });

      test('should not invoke the formatter for exact buckets', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 30); // tomorrow
        bool invoked = false;

        final RelativeDayResult? result = date.getRelativeDayResult(
          now: now,
          weekdayFormatter: (_) {
            invoked = true;
            return 'X';
          },
        );
        expect(result?.type, SimpleRelativeDay.tomorrow);
        expect(result?.weekdayName, isNull);
        expect(invoked, isFalse);
      });

      test('should leave weekdayName null for weekday bucket without a '
          'formatter', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 1, 1); // nextWeekday

        final RelativeDayResult? result = date.getRelativeDayResult(now: now);
        expect(result?.type, SimpleRelativeDay.nextWeekday);
        expect(result?.weekdayName, isNull);
      });

      test('should propagate a throwing formatter for weekday buckets', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2025, 1, 1); // nextWeekday

        expect(
          () => date.getRelativeDayResult(
            now: now,
            weekdayFormatter: (_) => throw StateError('locale failure'),
          ),
          throwsStateError,
        );
      });

      test('should not invoke a throwing formatter for exact buckets', () {
        final DateTime now = DateTime(2024, 12, 29);
        final DateTime date = DateTime(2024, 12, 29); // today

        // The formatter must never run for exact buckets, so a throwing one is
        // harmless here.
        final RelativeDayResult? result = date.getRelativeDayResult(
          now: now,
          weekdayFormatter: (_) => throw StateError('should not run'),
        );
        expect(result?.type, SimpleRelativeDay.today);
        expect(result?.weekdayName, isNull);
      });
    });

    group('RelativeDayResult value', () {
      test('should default weekdayName to null', () {
        const RelativeDayResult result = RelativeDayResult(
          SimpleRelativeDay.today,
        );
        expect(result.type, SimpleRelativeDay.today);
        expect(result.weekdayName, isNull);
      });

      test('should retain a supplied weekdayName for nextWeekday', () {
        const RelativeDayResult result = RelativeDayResult(
          SimpleRelativeDay.nextWeekday,
          weekdayName: 'Friday',
        );
        expect(result.type, SimpleRelativeDay.nextWeekday);
        expect(result.weekdayName, 'Friday');
      });

      test('should retain a supplied weekdayName for lastWeekday', () {
        const RelativeDayResult result = RelativeDayResult(
          SimpleRelativeDay.lastWeekday,
          weekdayName: 'Monday',
        );
        expect(result.type, SimpleRelativeDay.lastWeekday);
        expect(result.weekdayName, 'Monday');
      });
    });
  });
}

/// Deterministic English weekday name for tests, mirroring the labels the app's
/// locale-bound `DateFormat(DateFormat.WEEKDAY)` would produce — used so the
/// library tests never import `intl`. [DateTime.weekday] is 1 (Monday)..7.
String _weekdayName(DateTime date) {
  const List<String> names = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return names[date.weekday - 1];
}
