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
}
