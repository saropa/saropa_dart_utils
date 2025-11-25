import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_constants.dart';

void main() {
  group('unixEpochDate', () {
    test('returns the correct Unix epoch date', () {
      expect(DateConstants.unixEpochDate, equals(DateTime.utc(1970)));
    });

    test('returns a date with year 1970', () {
      expect(DateConstants.unixEpochDate.year, equals(1970));
    });

    test('returns a date with month 1', () {
      expect(DateConstants.unixEpochDate.month, equals(1));
    });

    test('returns a date with day 1', () {
      expect(DateConstants.unixEpochDate.day, equals(1));
    });

    test('returns a date with hour 0', () {
      expect(DateConstants.unixEpochDate.hour, equals(0));
    });

    test('returns a date with minute 0', () {
      expect(DateConstants.unixEpochDate.minute, equals(0));
    });

    test('returns a date with second 0', () {
      expect(DateConstants.unixEpochDate.second, equals(0));
    });

    test('returns a date with millisecond 0', () {
      expect(DateConstants.unixEpochDate.millisecond, equals(0));
    });

    test('returns a date with microsecond 0', () {
      expect(DateConstants.unixEpochDate.microsecond, equals(0));
    });

    test('returns a date with timezone offset of 0', () {
      expect(DateConstants.unixEpochDate.timeZoneOffset, equals(Duration.zero));
    });
  });

  group('MonthUtils', () {
    group('monthLongNames', () {
      test('1. January', () => expect(MonthUtils.monthLongNames[1], 'January'));
      test('2. February', () => expect(MonthUtils.monthLongNames[2], 'February'));
      test('3. March', () => expect(MonthUtils.monthLongNames[3], 'March'));
      test('4. April', () => expect(MonthUtils.monthLongNames[4], 'April'));
      test('5. May', () => expect(MonthUtils.monthLongNames[5], 'May'));
      test('6. June', () => expect(MonthUtils.monthLongNames[6], 'June'));
      test('7. July', () => expect(MonthUtils.monthLongNames[7], 'July'));
      test('8. August', () => expect(MonthUtils.monthLongNames[8], 'August'));
      test('9. September', () => expect(MonthUtils.monthLongNames[9], 'September'));
      test('10. October', () => expect(MonthUtils.monthLongNames[10], 'October'));
      test('11. November', () => expect(MonthUtils.monthLongNames[11], 'November'));
      test('12. December', () => expect(MonthUtils.monthLongNames[12], 'December'));
      test('13. Invalid month 0', () => expect(MonthUtils.monthLongNames[0], isNull));
      test('14. Invalid month 13', () => expect(MonthUtils.monthLongNames[13], isNull));
      test('15. Has 12 entries', () => expect(MonthUtils.monthLongNames.length, 12));
    });

    group('monthShortNames', () {
      test('1. Jan', () => expect(MonthUtils.monthShortNames[1], 'Jan'));
      test('2. Feb', () => expect(MonthUtils.monthShortNames[2], 'Feb'));
      test('3. Mar', () => expect(MonthUtils.monthShortNames[3], 'Mar'));
      test('4. Apr', () => expect(MonthUtils.monthShortNames[4], 'Apr'));
      test('5. May', () => expect(MonthUtils.monthShortNames[5], 'May'));
      test('6. Jun', () => expect(MonthUtils.monthShortNames[6], 'Jun'));
      test('7. Jul', () => expect(MonthUtils.monthShortNames[7], 'Jul'));
      test('8. Aug', () => expect(MonthUtils.monthShortNames[8], 'Aug'));
      test('9. Sep', () => expect(MonthUtils.monthShortNames[9], 'Sep'));
      test('10. Oct', () => expect(MonthUtils.monthShortNames[10], 'Oct'));
      test('11. Nov', () => expect(MonthUtils.monthShortNames[11], 'Nov'));
      test('12. Dec', () => expect(MonthUtils.monthShortNames[12], 'Dec'));
      test('13. Invalid month 0', () => expect(MonthUtils.monthShortNames[0], isNull));
      test('14. Invalid month 13', () => expect(MonthUtils.monthShortNames[13], isNull));
      test('15. Has 12 entries', () => expect(MonthUtils.monthShortNames.length, 12));
    });

    group('monthNumbers', () {
      test('1. First month is 1', () => expect(MonthUtils.monthNumbers.first, 1));
      test('2. Last month is 12', () => expect(MonthUtils.monthNumbers.last, 12));
      test('3. Has 12 entries', () => expect(MonthUtils.monthNumbers.length, 12));
      test('4. Contains June (6)', () => expect(MonthUtils.monthNumbers.contains(6), isTrue));
      test('5. Does not contain 0', () => expect(MonthUtils.monthNumbers.contains(0), isFalse));
      test('6. Does not contain 13', () => expect(MonthUtils.monthNumbers.contains(13), isFalse));
      test('7. Is sequential', () {
        for (int i = 0; i < MonthUtils.monthNumbers.length; i++) {
          expect(MonthUtils.monthNumbers[i], i + 1);
        }
      });
    });

    group('getMonthLongName', () {
      test('1. Valid month 1', () => expect(MonthUtils.getMonthLongName(1), 'January'));
      test('2. Valid month 6', () => expect(MonthUtils.getMonthLongName(6), 'June'));
      test('3. Valid month 12', () => expect(MonthUtils.getMonthLongName(12), 'December'));
      test('4. Invalid month 0', () => expect(MonthUtils.getMonthLongName(0), isNull));
      test('5. Invalid month 13', () => expect(MonthUtils.getMonthLongName(13), isNull));
      test('6. Negative month', () => expect(MonthUtils.getMonthLongName(-1), isNull));
      test('7. Valid month 3', () => expect(MonthUtils.getMonthLongName(3), 'March'));
      test('8. Valid month 9', () => expect(MonthUtils.getMonthLongName(9), 'September'));
      test('9. Valid month 11', () => expect(MonthUtils.getMonthLongName(11), 'November'));
      test('10. Large invalid month', () => expect(MonthUtils.getMonthLongName(100), isNull));
    });

    group('getMonthShortName', () {
      test('1. Valid month 1', () => expect(MonthUtils.getMonthShortName(1), 'Jan'));
      test('2. Valid month 6', () => expect(MonthUtils.getMonthShortName(6), 'Jun'));
      test('3. Valid month 12', () => expect(MonthUtils.getMonthShortName(12), 'Dec'));
      test('4. Invalid month 0', () => expect(MonthUtils.getMonthShortName(0), isNull));
      test('5. Invalid month 13', () => expect(MonthUtils.getMonthShortName(13), isNull));
      test('6. Null input', () => expect(MonthUtils.getMonthShortName(null), isNull));
      test('7. Valid month 3', () => expect(MonthUtils.getMonthShortName(3), 'Mar'));
      test('8. Valid month 9', () => expect(MonthUtils.getMonthShortName(9), 'Sep'));
      test('9. Negative month', () => expect(MonthUtils.getMonthShortName(-1), isNull));
      test('10. Valid month 5', () => expect(MonthUtils.getMonthShortName(5), 'May'));
    });
  });

  group('WeekdayUtils', () {
    group('dayLongNames', () {
      test('1. Monday', () => expect(WeekdayUtils.dayLongNames[DateTime.monday], 'Monday'));
      test('2. Tuesday', () => expect(WeekdayUtils.dayLongNames[DateTime.tuesday], 'Tuesday'));
      test('3. Wednesday', () => expect(WeekdayUtils.dayLongNames[DateTime.wednesday], 'Wednesday'));
      test('4. Thursday', () => expect(WeekdayUtils.dayLongNames[DateTime.thursday], 'Thursday'));
      test('5. Friday', () => expect(WeekdayUtils.dayLongNames[DateTime.friday], 'Friday'));
      test('6. Saturday', () => expect(WeekdayUtils.dayLongNames[DateTime.saturday], 'Saturday'));
      test('7. Sunday', () => expect(WeekdayUtils.dayLongNames[DateTime.sunday], 'Sunday'));
      test('8. Invalid day 0', () => expect(WeekdayUtils.dayLongNames[0], isNull));
      test('9. Invalid day 8', () => expect(WeekdayUtils.dayLongNames[8], isNull));
      test('10. Has 7 entries', () => expect(WeekdayUtils.dayLongNames.length, 7));
    });

    group('dayShortNames', () {
      test('1. Mon', () => expect(WeekdayUtils.dayShortNames[DateTime.monday], 'Mon'));
      test('2. Tue', () => expect(WeekdayUtils.dayShortNames[DateTime.tuesday], 'Tue'));
      test('3. Wed', () => expect(WeekdayUtils.dayShortNames[DateTime.wednesday], 'Wed'));
      test('4. Thu', () => expect(WeekdayUtils.dayShortNames[DateTime.thursday], 'Thu'));
      test('5. Fri', () => expect(WeekdayUtils.dayShortNames[DateTime.friday], 'Fri'));
      test('6. Sat', () => expect(WeekdayUtils.dayShortNames[DateTime.saturday], 'Sat'));
      test('7. Sun', () => expect(WeekdayUtils.dayShortNames[DateTime.sunday], 'Sun'));
      test('8. Invalid day 0', () => expect(WeekdayUtils.dayShortNames[0], isNull));
      test('9. Invalid day 8', () => expect(WeekdayUtils.dayShortNames[8], isNull));
      test('10. Has 7 entries', () => expect(WeekdayUtils.dayShortNames.length, 7));
    });

    group('getDayLongName', () {
      test('1. Monday', () => expect(WeekdayUtils.getDayLongName(DateTime.monday), 'Monday'));
      test('2. Friday', () => expect(WeekdayUtils.getDayLongName(DateTime.friday), 'Friday'));
      test('3. Sunday', () => expect(WeekdayUtils.getDayLongName(DateTime.sunday), 'Sunday'));
      test('4. Invalid day 0', () => expect(WeekdayUtils.getDayLongName(0), isNull));
      test('5. Invalid day 8', () => expect(WeekdayUtils.getDayLongName(8), isNull));
      test('6. Null input', () => expect(WeekdayUtils.getDayLongName(null), isNull));
      test('7. Wednesday', () => expect(WeekdayUtils.getDayLongName(DateTime.wednesday), 'Wednesday'));
      test('8. Negative day', () => expect(WeekdayUtils.getDayLongName(-1), isNull));
      test('9. Saturday', () => expect(WeekdayUtils.getDayLongName(DateTime.saturday), 'Saturday'));
      test('10. Tuesday', () => expect(WeekdayUtils.getDayLongName(DateTime.tuesday), 'Tuesday'));
    });

    group('getDayShortName', () {
      test('1. Mon', () => expect(WeekdayUtils.getDayShortName(DateTime.monday), 'Mon'));
      test('2. Fri', () => expect(WeekdayUtils.getDayShortName(DateTime.friday), 'Fri'));
      test('3. Sun', () => expect(WeekdayUtils.getDayShortName(DateTime.sunday), 'Sun'));
      test('4. Invalid day 0', () => expect(WeekdayUtils.getDayShortName(0), isNull));
      test('5. Invalid day 8', () => expect(WeekdayUtils.getDayShortName(8), isNull));
      test('6. Null input', () => expect(WeekdayUtils.getDayShortName(null), isNull));
      test('7. Wed', () => expect(WeekdayUtils.getDayShortName(DateTime.wednesday), 'Wed'));
      test('8. Negative day', () => expect(WeekdayUtils.getDayShortName(-1), isNull));
      test('9. Sat', () => expect(WeekdayUtils.getDayShortName(DateTime.saturday), 'Sat'));
      test('10. Tue', () => expect(WeekdayUtils.getDayShortName(DateTime.tuesday), 'Tue'));
    });
  });

  group('SerialDateUtils', () {
    group('serialToDateTime', () {
      test('1. Valid ISO date', () {
        expect(SerialDateUtils.serialToDateTime('2023-06-15'), DateTime(2023, 6, 15));
      });
      test('2. Valid ISO datetime', () {
        expect(SerialDateUtils.serialToDateTime('2023-06-15T12:30:45'), DateTime(2023, 6, 15, 12, 30, 45));
      });
      test('3. Null input', () {
        expect(SerialDateUtils.serialToDateTime(null), isNull);
      });
      test('4. Empty string', () {
        expect(SerialDateUtils.serialToDateTime(''), isNull);
      });
      test('5. Invalid format', () {
        expect(SerialDateUtils.serialToDateTime('not-a-date'), isNull);
      });
      test('6. Compact format', () {
        expect(SerialDateUtils.serialToDateTime('20230615'), DateTime(2023, 6, 15));
      });
      test('7. Compact datetime format', () {
        expect(SerialDateUtils.serialToDateTime('20230615T123045'), DateTime(2023, 6, 15, 12, 30, 45));
      });
      test('8. Midnight', () {
        expect(SerialDateUtils.serialToDateTime('2023-06-15T00:00:00'), DateTime(2023, 6, 15));
      });
      test('9. End of day', () {
        expect(SerialDateUtils.serialToDateTime('2023-06-15T23:59:59'), DateTime(2023, 6, 15, 23, 59, 59));
      });
      test('10. Leap year date', () {
        expect(SerialDateUtils.serialToDateTime('2024-02-29'), DateTime(2024, 2, 29));
      });
      test('11. Year only (invalid)', () {
        expect(SerialDateUtils.serialToDateTime('2023'), isNull);
      });
      test('12. With milliseconds', () {
        final DateTime? result = SerialDateUtils.serialToDateTime('2023-06-15T12:30:45.123');
        expect(result?.year, 2023);
        expect(result?.millisecond, 123);
      });
      test('13. UTC timezone', () {
        expect(SerialDateUtils.serialToDateTime('2023-06-15T12:30:45Z'), isNotNull);
      });
      test('14. Whitespace only', () {
        expect(SerialDateUtils.serialToDateTime('   '), isNull);
      });
      test('15. January 1', () {
        expect(SerialDateUtils.serialToDateTime('2024-01-01'), DateTime(2024));
      });
    });
  });
}
