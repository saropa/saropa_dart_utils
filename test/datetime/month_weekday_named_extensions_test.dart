// Tests for DayInMonthCalculations — named weekday-of-month wrappers plus
// February day count and month-boundary helpers.
//
// Out-of-scope axes (all inputs are `int` / `DateTime`): empty/null strings,
// Unicode/emoji, infinity/NaN, and locale do not apply to this util.
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/month_weekday_named_extensions.dart';
import 'package:saropa_dart_utils/datetime/month_weekday_utils.dart';

void main() {
  group('DayInMonthCalculations', () {
    group('daysInFebruary', () {
      test('should return 29 for a standard leap year (divisible by 4)', () {
        expect(DayInMonthCalculations.daysInFebruary(2024), 29);
        expect(DayInMonthCalculations.daysInFebruary(2028), 29);
      });

      test('should return 28 for a common year', () {
        expect(DayInMonthCalculations.daysInFebruary(2023), 28);
        expect(DayInMonthCalculations.daysInFebruary(2025), 28);
      });

      test('should return 28 for a century non-leap year (÷100 not ÷400)', () {
        expect(DayInMonthCalculations.daysInFebruary(1900), 28);
        expect(DayInMonthCalculations.daysInFebruary(2100), 28);
      });

      test('should return 29 for a century leap year (÷400)', () {
        expect(DayInMonthCalculations.daysInFebruary(2000), 29);
        expect(DayInMonthCalculations.daysInFebruary(2400), 29);
      });

      test('should return 29 for year 0 (divisible by 400)', () {
        expect(DayInMonthCalculations.daysInFebruary(0), 29);
      });

      test('should not throw for a negative year', () {
        expect(() => DayInMonthCalculations.daysInFebruary(-4), returnsNormally);
      });
    });

    group('firstDayOfMonth', () {
      test('should return the first calendar day of the month', () {
        expect(DayInMonthCalculations.firstDayOfMonth(2024, 3), DateTime(2024, 3));
      });

      test('should return a local (non-UTC) DateTime at midnight', () {
        final DateTime first = DayInMonthCalculations.firstDayOfMonth(2024, 3);
        expect(first.isUtc, isFalse);
        expect(<int>[first.hour, first.minute, first.second, first.millisecond], <int>[0, 0, 0, 0]);
      });
    });

    group('lastDay', () {
      test('should return day 31 for a 31-day month', () {
        for (final int month in <int>[1, 3, 5, 7, 8, 10, 12]) {
          expect(DayInMonthCalculations.lastDay(2024, month).day, 31);
        }
      });

      test('should return day 30 for a 30-day month', () {
        for (final int month in <int>[4, 6, 9, 11]) {
          expect(DayInMonthCalculations.lastDay(2024, month).day, 30);
        }
      });

      test('should return Feb 29 in a leap year and Feb 28 in a common year', () {
        expect(DayInMonthCalculations.lastDay(2024, 2), DateTime(2024, 2, 29));
        expect(DayInMonthCalculations.lastDay(2023, 2), DateTime(2023, 2, 28));
      });

      test('should handle the December month-13 roll-over path', () {
        expect(DayInMonthCalculations.lastDay(2024, 1), DateTime(2024, 1, 31));
        expect(DayInMonthCalculations.lastDay(2026, 12), DateTime(2026, 12, 31));
      });
    });

    group('named ordinal-weekday wrappers — sample cases', () {
      test('firstMonday should return the correct date', () {
        // January 2024 starts on a Monday.
        expect(DayInMonthCalculations.firstMonday(2024, 1), DateTime(2024, 1));
        // February 2024 first Monday is Feb 5.
        expect(DayInMonthCalculations.firstMonday(2024, 2), DateTime(2024, 2, 5));
      });

      test('secondMonday should return the correct date', () {
        expect(DayInMonthCalculations.secondMonday(2024, 1), DateTime(2024, 1, 8));
      });

      test('thirdMonday should return the correct date', () {
        expect(DayInMonthCalculations.thirdMonday(2024, 1), DateTime(2024, 1, 15));
      });

      test('thirdSaturday should return the correct non-null date', () {
        // September 2024: first Saturday Sep 7, third is Sep 21.
        expect(DayInMonthCalculations.thirdSaturday(2024, 9), DateTime(2024, 9, 21));
      });

      test('firstThursday should return the correct date', () {
        // March 2024: first Thursday is Mar 7.
        expect(DayInMonthCalculations.firstThursday(2024, 3), DateTime(2024, 3, 7));
        expect(DayInMonthCalculations.firstThursday(2024, 3).weekday, DateTime.thursday);
      });

      test('firstFriday should return the correct date', () {
        // November 2024: first Friday is Nov 1.
        expect(DayInMonthCalculations.firstFriday(2024, 11), DateTime(2024, 11));
        expect(DayInMonthCalculations.firstFriday(2024, 11).weekday, DateTime.friday);
      });

      test('firstSaturday should return the correct date', () {
        // June 2024: first Saturday is Jun 1.
        expect(DayInMonthCalculations.firstSaturday(2024, 6), DateTime(2024, 6));
        expect(DayInMonthCalculations.firstSaturday(2024, 6).weekday, DateTime.saturday);
      });

      test('secondFriday should return the correct date', () {
        // August 2024: first Friday Aug 2, second is Aug 9.
        expect(DayInMonthCalculations.secondFriday(2024, 8), DateTime(2024, 8, 9));
        expect(DayInMonthCalculations.secondFriday(2024, 8).weekday, DateTime.friday);
      });

      test('secondSaturday should return the correct date', () {
        // August 2024: first Saturday Aug 3, second is Aug 10.
        expect(DayInMonthCalculations.secondSaturday(2024, 8), DateTime(2024, 8, 10));
        expect(DayInMonthCalculations.secondSaturday(2024, 8).weekday, DateTime.saturday);
      });
    });

    group('named last-weekday wrappers — sample cases', () {
      test('lastMonday should return the correct date', () {
        // January 2024 last Monday is Jan 29.
        expect(DayInMonthCalculations.lastMonday(2024, 1), DateTime(2024, 1, 29));
      });

      test('lastFriday should return the correct date', () {
        // February 2024 last Friday is Feb 23.
        expect(DayInMonthCalculations.lastFriday(2024, 2), DateTime(2024, 2, 23));
        expect(DayInMonthCalculations.lastFriday(2024, 2).weekday, DateTime.friday);
      });

      test('lastSaturday should return the correct date', () {
        // February 2024 last Saturday is Feb 24.
        expect(DayInMonthCalculations.lastSaturday(2024, 2), DateTime(2024, 2, 24));
        expect(DayInMonthCalculations.lastSaturday(2024, 2).weekday, DateTime.saturday);
      });
    });

    group('real DST anchor dates', () {
      test('US DST start = 2nd Sunday of March', () {
        expect(DayInMonthCalculations.secondSunday(2026, 3), DateTime(2026, 3, 8));
        expect(DayInMonthCalculations.secondSunday(2025, 3), DateTime(2025, 3, 9));
      });

      test('US DST end = 1st Sunday of November', () {
        expect(DayInMonthCalculations.firstSunday(2026, 11), DateTime(2026, 11));
      });

      test('EU/GB DST start = last Sunday of March', () {
        expect(DayInMonthCalculations.lastSunday(2026, 3), DateTime(2026, 3, 29));
        expect(DayInMonthCalculations.lastSunday(2025, 3), DateTime(2025, 3, 30));
      });

      test('EU/GB DST end = last Sunday of October', () {
        expect(DayInMonthCalculations.lastSunday(2026, 10), DateTime(2026, 10, 25));
      });

      test('Egypt DST end = last Thursday of October', () {
        expect(DayInMonthCalculations.lastThursday(2026, 10), DateTime(2026, 10, 29));
      });
    });

    group('5th-occurrence existence via MonthWeekdayUtils', () {
      // The named wrappers never expose a 5th-occurrence query; that genuinely
      // nullable case is served by MonthWeekdayUtils.nthWeekdayOfMonth directly.
      test('5th Monday of January 2024 exists', () {
        expect(
          MonthWeekdayUtils.nthWeekdayOfMonth(2024, 1, 5, DateTime.monday),
          DateTime(2024, 1, 29),
        );
      });

      test('5th Monday of February 2024 does not exist (null)', () {
        expect(MonthWeekdayUtils.nthWeekdayOfMonth(2024, 2, 5, DateTime.monday), isNull);
      });

      // For each weekday, one month where the 5th exists and one where it is absent.
      const Map<int, List<int>> fifthPresentAbsent = <int, List<int>>{
        DateTime.monday: <int>[1, 2],
        DateTime.tuesday: <int>[1, 2],
        DateTime.wednesday: <int>[1, 2],
        DateTime.thursday: <int>[2, 1],
        DateTime.friday: <int>[3, 1],
        DateTime.saturday: <int>[3, 1],
        DateTime.sunday: <int>[3, 1],
      };

      test('every weekday has a present and an absent 5th occurrence in 2024', () {
        fifthPresentAbsent.forEach((int weekday, List<int> months) {
          final int presentMonth = months[0];
          final int absentMonth = months[1];
          expect(
            MonthWeekdayUtils.nthWeekdayOfMonth(2024, presentMonth, 5, weekday),
            isNotNull,
            reason: 'weekday $weekday should have a 5th in month $presentMonth',
          );
          expect(
            MonthWeekdayUtils.nthWeekdayOfMonth(2024, absentMonth, 5, weekday),
            isNull,
            reason: 'weekday $weekday should lack a 5th in month $absentMonth',
          );
        });
      });
    });

    group('nullability-consistency — 1st/2nd/3rd/4th never null', () {
      // A 4th occurrence (and any earlier) of every weekday always exists, so
      // the underlying nth query must be non-null for every weekday across all
      // 12 months of several sample years. This locks the non-null contract of
      // the named wrappers (including thirdSaturday / thirdSunday).
      test('1..4 occurrences are non-null for all 7 weekdays, all 12 months', () {
        for (final int year in <int>[2023, 2024, 2025, 2000]) {
          for (int month = 1; month <= 12; month++) {
            for (int weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
              for (int n = 1; n <= 4; n++) {
                expect(
                  MonthWeekdayUtils.nthWeekdayOfMonth(year, month, n, weekday),
                  isNotNull,
                  reason: 'y=$year m=$month wd=$weekday n=$n must exist',
                );
              }
            }
          }
        }
      });
    });

    group('argument-validation edge cases', () {
      // Named non-null wrappers throw StateError when month is out of 1..12,
      // surfacing the bad argument at the call site rather than returning a
      // plausible-but-wrong neighboring-month date.
      test('firstMonday should throw StateError for an out-of-range month', () {
        expect(() => DayInMonthCalculations.firstMonday(2024, 0), throwsStateError);
        expect(() => DayInMonthCalculations.firstMonday(2024, 13), throwsStateError);
        expect(() => DayInMonthCalculations.firstMonday(2024, -1), throwsStateError);
      });

      test('underlying nthWeekdayOfMonth returns null for invalid n/month/weekday', () {
        expect(MonthWeekdayUtils.nthWeekdayOfMonth(2024, 1, 0, DateTime.monday), isNull);
        expect(MonthWeekdayUtils.nthWeekdayOfMonth(2024, 13, 1, DateTime.monday), isNull);
        expect(MonthWeekdayUtils.nthWeekdayOfMonth(2024, 1, 1, 0), isNull);
        expect(MonthWeekdayUtils.nthWeekdayOfMonth(2024, 1, 1, 8), isNull);
      });
    });

    group('DateTime construction subtleties', () {
      test('ordinal-wrapper results are local midnight (not UTC)', () {
        final DateTime result = DayInMonthCalculations.secondSunday(2026, 3);
        expect(result.isUtc, isFalse);
        expect(
          <int>[result.hour, result.minute, result.second, result.millisecond],
          <int>[0, 0, 0, 0],
        );
      });

      test('last-wrapper results are local midnight even across a DST fold', () {
        // `subtract(Duration(days:))` on a local DateTime must not introduce a
        // 23:00 offset across the EU DST fold (last Sunday of October).
        final DateTime result = DayInMonthCalculations.lastSunday(2026, 10);
        expect(result.isUtc, isFalse);
        expect(
          <int>[result.hour, result.minute, result.second, result.millisecond],
          <int>[0, 0, 0, 0],
        );
      });
    });

    group('extreme years and roll-over', () {
      test('firstMonday(9999, 12) is a Monday with no throw', () {
        final DateTime result = DayInMonthCalculations.firstMonday(9999, 12);
        expect(result, DateTime(9999, 12, 6));
        expect(result.weekday, DateTime.monday);
      });

      test('lastSunday(1, 1) is a Sunday with no throw', () {
        final DateTime result = DayInMonthCalculations.lastSunday(1, 1);
        expect(result, DateTime(1, 1, 28));
        expect(result.weekday, DateTime.sunday);
      });
    });
  });
}
