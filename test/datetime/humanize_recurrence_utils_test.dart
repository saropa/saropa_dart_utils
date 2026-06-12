import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/humanize_recurrence_utils.dart';

void main() {
  group('humanizeRecurrence', () {
    group('daily', () {
      test('should say "every day" for interval 1', () {
        expect(
          humanizeRecurrence(const RecurrenceSpec(RecurrenceFrequency.daily)),
          equals('every day'),
        );
      });

      test('should say "every N days" for interval > 1', () {
        expect(
          humanizeRecurrence(const RecurrenceSpec(RecurrenceFrequency.daily, interval: 2)),
          equals('every 2 days'),
        );
      });
    });

    group('weekly', () {
      test('should say "weekly on <Weekday>" for interval 1', () {
        expect(
          humanizeRecurrence(
            const RecurrenceSpec(RecurrenceFrequency.weekly, weekday: DateTime.monday),
          ),
          equals('weekly on Monday'),
        );
      });

      test('should say "every N weeks on <Weekday>" for interval > 1', () {
        expect(
          humanizeRecurrence(
            const RecurrenceSpec(
              RecurrenceFrequency.weekly,
              interval: 2,
              weekday: DateTime.tuesday,
            ),
          ),
          equals('every 2 weeks on Tuesday'),
        );
      });

      test('should drop the weekday clause when none is given', () {
        expect(
          humanizeRecurrence(const RecurrenceSpec(RecurrenceFrequency.weekly)),
          equals('weekly'),
        );
      });
    });

    group('monthly', () {
      test('should say "monthly on the <ordinal>" by month day', () {
        expect(
          humanizeRecurrence(const RecurrenceSpec(RecurrenceFrequency.monthly, monthDay: 15)),
          equals('monthly on the 15th'),
        );
      });

      test('should say "every <ordinal> <Weekday> of the month" for nth-weekday', () {
        expect(
          humanizeRecurrence(
            const RecurrenceSpec(
              RecurrenceFrequency.monthly,
              weekOfMonth: 2,
              weekday: DateTime.tuesday,
            ),
          ),
          equals('every 2nd Tuesday of the month'),
        );
      });

      test('should honor the interval for month-day phrasing', () {
        expect(
          humanizeRecurrence(
            const RecurrenceSpec(RecurrenceFrequency.monthly, interval: 3, monthDay: 1),
          ),
          equals('every 3 months on the 1st'),
        );
      });
    });

    group('yearly', () {
      test('should say "yearly on <Month> <day>"', () {
        expect(
          humanizeRecurrence(
            const RecurrenceSpec(RecurrenceFrequency.yearly, month: 3, monthDay: 5),
          ),
          equals('yearly on March 5'),
        );
      });

      test('should fall back to the interval phrase without a month', () {
        expect(
          humanizeRecurrence(const RecurrenceSpec(RecurrenceFrequency.yearly, interval: 2)),
          equals('every 2 years'),
        );
      });
    });

    group('ordinals', () {
      // Drive the private _ordinal helper through monthly month-day phrasing.
      String monthDayPhrase(int day) => humanizeRecurrence(
        RecurrenceSpec(RecurrenceFrequency.monthly, monthDay: day),
      );

      test('should use st/nd/rd for 1/2/3', () {
        expect(monthDayPhrase(1), equals('monthly on the 1st'));
        expect(monthDayPhrase(2), equals('monthly on the 2nd'));
        expect(monthDayPhrase(3), equals('monthly on the 3rd'));
      });

      test('should use th for the 11/12/13 teens exception', () {
        expect(monthDayPhrase(11), equals('monthly on the 11th'));
        expect(monthDayPhrase(12), equals('monthly on the 12th'));
        expect(monthDayPhrase(13), equals('monthly on the 13th'));
      });

      test('should resume st/nd/rd at 21/22/23', () {
        expect(monthDayPhrase(21), equals('monthly on the 21st'));
        expect(monthDayPhrase(22), equals('monthly on the 22nd'));
        expect(monthDayPhrase(23), equals('monthly on the 23rd'));
      });
    });

    test('should reject an interval below 1', () {
      expect(
        () => RecurrenceSpec(RecurrenceFrequency.daily, interval: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
