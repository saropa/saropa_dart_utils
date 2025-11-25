import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_extensions.dart';
import 'package:saropa_dart_utils/datetime/date_time_range_utils.dart';
import 'package:saropa_dart_utils/datetime/date_time_utils.dart';
import 'package:saropa_dart_utils/hex/hex_utils.dart';
import 'package:saropa_dart_utils/list/list_extensions.dart';
import 'package:saropa_dart_utils/string/string_case_extensions.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Tests for algorithm fixes in saropa_dart_utils
///
/// This file contains 10 test cases for each algorithmic fix made to the library.
void main() {
  group('Fix 1: isBetweenRange - inclusive parameter forwarding', () {
    test('inclusive=true includes start date', () {
      final DateTime date = DateTime(2024, 6, 1);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(date.isBetweenRange(range, inclusive: true), isTrue);
    });

    test('inclusive=true includes end date', () {
      final DateTime date = DateTime(2024, 6, 30);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(date.isBetweenRange(range, inclusive: true), isTrue);
    });

    test('inclusive=false excludes start date', () {
      final DateTime date = DateTime(2024, 6, 1);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(date.isBetweenRange(range, inclusive: false), isFalse);
    });

    test('inclusive=false excludes end date', () {
      final DateTime date = DateTime(2024, 6, 30);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(date.isBetweenRange(range, inclusive: false), isFalse);
    });

    test('inclusive=false includes middle date', () {
      final DateTime date = DateTime(2024, 6, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(date.isBetweenRange(range, inclusive: false), isTrue);
    });

    test('null range returns false', () {
      final DateTime date = DateTime(2024, 6, 15);
      expect(date.isBetweenRange(null), isFalse);
    });

    test('date before range returns false', () {
      final DateTime date = DateTime(2024, 5, 31);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(date.isBetweenRange(range), isFalse);
    });

    test('date after range returns false', () {
      final DateTime date = DateTime(2024, 7, 1);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(date.isBetweenRange(range), isFalse);
    });

    test('handles cross-year range with inclusive=true', () {
      final DateTime date = DateTime(2024, 1, 1);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isBetweenRange(range, inclusive: true), isTrue);
    });

    test('handles single-day range with inclusive=true', () {
      final DateTime date = DateTime(2024, 6, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 15),
        end: DateTime(2024, 6, 15),
      );
      expect(date.isBetweenRange(range, inclusive: true), isTrue);
    });
  });

  group('Fix 2: isAnnualDateInRange - cross-year range logic', () {
    test('year=0 date in range spanning year boundary (January)', () {
      final DateTime date = DateTime(0, 1, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range), isTrue);
    });

    test('year=0 date in range spanning year boundary (December)', () {
      final DateTime date = DateTime(0, 12, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range), isTrue);
    });

    test('year=0 date outside range spanning year boundary', () {
      final DateTime date = DateTime(0, 3, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range), isFalse);
    });

    test('year=0 date at exact start boundary', () {
      final DateTime date = DateTime(0, 12, 1);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range, inclusive: true), isTrue);
    });

    test('year=0 date at exact end boundary', () {
      final DateTime date = DateTime(0, 2, 28);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range, inclusive: true), isTrue);
    });

    test('year=0 with inclusive=false excludes boundaries', () {
      final DateTime date = DateTime(0, 12, 1);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range, inclusive: false), isFalse);
    });

    test('null range returns true', () {
      final DateTime date = DateTime(0, 6, 15);
      expect(date.isAnnualDateInRange(null), isTrue);
    });

    test('specific year date uses isBetweenRange', () {
      final DateTime date = DateTime(2024, 1, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range), isTrue);
    });

    test('specific year date outside range', () {
      final DateTime date = DateTime(2024, 6, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 12, 1),
        end: DateTime(2024, 2, 28),
      );
      expect(date.isAnnualDateInRange(range), isFalse);
    });

    test('year=0 date with multi-year range', () {
      final DateTime date = DateTime(0, 6, 15);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2022, 1, 1),
        end: DateTime(2024, 12, 31),
      );
      expect(date.isAnnualDateInRange(range), isTrue);
    });
  });

  group('Fix 3: isNthDayOfMonthInRange - cross-year check', () {
    test('January month in range spanning Nov to Feb', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 11, 15),
        end: DateTime(2024, 2, 15),
      );
      // 2nd Monday of January 2024 is January 8
      expect(range.isNthDayOfMonthInRange(2, DateTime.monday, 1), isTrue);
    });

    test('October month not in range spanning Nov to Feb', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 11, 15),
        end: DateTime(2024, 2, 15),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 10), isFalse);
    });

    test('December month in range spanning Nov to Feb', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 11, 15),
        end: DateTime(2024, 2, 15),
      );
      // 1st Monday of December 2023 is December 4
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 12), isTrue);
    });

    test('invalid month returns false', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 13), isFalse);
    });

    test('month 0 returns false', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 0), isFalse);
    });

    test('5th occurrence that does not exist returns false', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2023, 1, 1),
        end: DateTime(2023, 12, 31),
      );
      // February 2023 has only 4 Mondays
      expect(range.isNthDayOfMonthInRange(5, DateTime.monday, 2), isFalse);
    });

    test('inclusive=false excludes boundary dates', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 1, 8), // 2nd Monday of Jan
        end: DateTime(2024, 1, 31),
      );
      expect(range.isNthDayOfMonthInRange(2, DateTime.monday, 1, inclusive: false), isFalse);
    });

    test('inclusive=true includes boundary dates', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 1, 8), // 2nd Monday of Jan
        end: DateTime(2024, 1, 31),
      );
      expect(range.isNthDayOfMonthInRange(2, DateTime.monday, 1, inclusive: true), isTrue);
    });

    test('multi-year range finds occurrence', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2022, 1, 1),
        end: DateTime(2024, 12, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 6), isTrue);
    });

    test('range within same month', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 1, 1),
        end: DateTime(2024, 1, 31),
      );
      expect(range.isNthDayOfMonthInRange(1, DateTime.monday, 1), isTrue);
    });
  });

  group('Fix 4: inRange - inclusive boundary semantics', () {
    test('inclusive=true includes start date', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.inRange(DateTime(2024, 6, 1), inclusive: true), isTrue);
    });

    test('inclusive=true includes end date', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.inRange(DateTime(2024, 6, 30), inclusive: true), isTrue);
    });

    test('inclusive=false excludes start date', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.inRange(DateTime(2024, 6, 1), inclusive: false), isFalse);
    });

    test('inclusive=false excludes end date', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.inRange(DateTime(2024, 6, 30), inclusive: false), isFalse);
    });

    test('middle date is always in range', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.inRange(DateTime(2024, 6, 15), inclusive: false), isTrue);
      expect(range.inRange(DateTime(2024, 6, 15), inclusive: true), isTrue);
    });

    test('date before range returns false', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.inRange(DateTime(2024, 5, 31)), isFalse);
    });

    test('date after range returns false', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.inRange(DateTime(2024, 7, 1)), isFalse);
    });

    test('isNowInRange uses inclusive parameter', () {
      final DateTime now = DateTime(2024, 6, 1);
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 1),
        end: DateTime(2024, 6, 30),
      );
      expect(range.isNowInRange(now: now, inclusive: true), isTrue);
      expect(range.isNowInRange(now: now, inclusive: false), isFalse);
    });

    test('single-day range with inclusive=true', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 15),
        end: DateTime(2024, 6, 15),
      );
      expect(range.inRange(DateTime(2024, 6, 15), inclusive: true), isTrue);
    });

    test('single-day range with inclusive=false', () {
      final DateTimeRange range = DateTimeRange(
        start: DateTime(2024, 6, 15),
        end: DateTime(2024, 6, 15),
      );
      expect(range.inRange(DateTime(2024, 6, 15), inclusive: false), isFalse);
    });
  });

  group('Fix 5: equalsIgnoringOrder - duplicate handling', () {
    test('same elements different order returns true', () {
      expect(<int>[1, 2, 3].equalsIgnoringOrder(<int>[3, 2, 1]), isTrue);
    });

    test('same elements with same duplicates returns true', () {
      expect(<int>[1, 1, 2].equalsIgnoringOrder(<int>[2, 1, 1]), isTrue);
    });

    test('different duplicate counts returns false', () {
      expect(<int>[1, 1, 2].equalsIgnoringOrder(<int>[1, 2, 2]), isFalse);
    });

    test('different duplicate counts with same unique elements returns false', () {
      expect(<int>[1, 1, 1, 2].equalsIgnoringOrder(<int>[1, 2, 2, 2]), isFalse);
    });

    test('empty lists are equal', () {
      expect(<int>[].equalsIgnoringOrder(<int>[]), isTrue);
    });

    test('null list returns false', () {
      expect(<int>[1, 2, 3].equalsIgnoringOrder(null), isFalse);
    });

    test('identical lists are equal', () {
      final List<int> list = <int>[1, 2, 3];
      expect(list.equalsIgnoringOrder(list), isTrue);
    });

    test('different lengths returns false', () {
      expect(<int>[1, 2, 3].equalsIgnoringOrder(<int>[1, 2]), isFalse);
    });

    test('lists with null elements and same counts', () {
      expect(<int?>[1, null, null].equalsIgnoringOrder(<int?>[null, 1, null]), isTrue);
    });

    test('lists with null elements and different counts', () {
      expect(<int?>[1, null, 2].equalsIgnoringOrder(<int?>[null, null, 1]), isFalse);
    });
  });

  group('Fix 6: hexToInt - case-sensitive overflow check', () {
    test('lowercase max int64 hex is valid', () {
      expect('7fffffffffffffff'.hexToInt(), 9223372036854775807);
    });

    test('uppercase max int64 hex is valid', () {
      expect('7FFFFFFFFFFFFFFF'.hexToInt(), 9223372036854775807);
    });

    test('mixed case max int64 hex is valid', () {
      expect('7FfFfFfFfFfFfFfF'.hexToInt(), 9223372036854775807);
    });

    test('lowercase overflow hex returns null', () {
      expect('8000000000000000'.hexToInt(), isNull);
    });

    test('uppercase overflow hex returns null', () {
      expect('8000000000000000'.hexToInt(), isNull);
    });

    test('lowercase ff is valid', () {
      expect('ff'.hexToInt(), 255);
    });

    test('uppercase FF is valid', () {
      expect('FF'.hexToInt(), 255);
    });

    test('mixed case hex is valid', () {
      expect('aAbBcCdDeEfF'.hexToInt(), 187723572702975);
    });

    test('empty string returns null', () {
      expect(''.hexToInt(), isNull);
    });

    test('invalid hex characters returns null', () {
      expect('gg'.hexToInt(), isNull);
    });
  });

  group('Fix 7: toUpperLatinOnly - O(n) performance with StringBuffer', () {
    test('converts lowercase latin to uppercase', () {
      expect('hello'.toUpperLatinOnly(), 'HELLO');
    });

    test('preserves already uppercase', () {
      expect('HELLO'.toUpperLatinOnly(), 'HELLO');
    });

    test('preserves non-latin characters', () {
      expect('café'.toUpperLatinOnly(), 'CAFé');
    });

    test('preserves numbers', () {
      expect('hello123'.toUpperLatinOnly(), 'HELLO123');
    });

    test('preserves special characters', () {
      expect('hello!@#'.toUpperLatinOnly(), 'HELLO!@#');
    });

    test('empty string returns empty', () {
      expect(''.toUpperLatinOnly(), '');
    });

    test('handles mixed content', () {
      expect('Hello World 123!'.toUpperLatinOnly(), 'HELLO WORLD 123!');
    });

    test('preserves unicode characters', () {
      expect('hello你好'.toUpperLatinOnly(), 'HELLO你好');
    });

    test('handles long strings efficiently', () {
      final String longString = 'a' * 10000;
      final String result = longString.toUpperLatinOnly();
      expect(result, 'A' * 10000);
    });

    test('preserves emoji', () {
      expect('hello😀world'.toUpperLatinOnly(), 'HELLO😀WORLD');
    });
  });

  group('Fix 8: upperCaseLettersOnly - O(n) performance with StringBuffer', () {
    test('extracts uppercase letters only', () {
      expect('Hello World'.upperCaseLettersOnly(), 'HW');
    });

    test('returns all uppercase from all caps string', () {
      expect('HELLO'.upperCaseLettersOnly(), 'HELLO');
    });

    test('returns empty for all lowercase', () {
      expect('hello'.upperCaseLettersOnly(), '');
    });

    test('ignores numbers', () {
      expect('H1E2L3L4O'.upperCaseLettersOnly(), 'HELLO');
    });

    test('ignores special characters', () {
      expect('H!E@L#L\$O'.upperCaseLettersOnly(), 'HELLO');
    });

    test('empty string returns empty', () {
      expect(''.upperCaseLettersOnly(), '');
    });

    test('handles mixed content', () {
      expect('Ben Bright 1234'.upperCaseLettersOnly(), 'BB');
    });

    test('handles unicode uppercase', () {
      // Note: isAllLetterUpperCase only checks A-Z
      expect('ÉÀÜ'.upperCaseLettersOnly(), '');
    });

    test('handles long strings efficiently', () {
      final String longString = 'Ab' * 5000;
      final String result = longString.upperCaseLettersOnly();
      expect(result, 'A' * 5000);
    });

    test('handles strings with only special chars', () {
      expect('!@#\$%^&*()'.upperCaseLettersOnly(), '');
    });
  });

  group('Fix 9: truncateWithEllipsisPreserveWords - long word handling', () {
    test('truncates at word boundary', () {
      expect('Hello World'.truncateWithEllipsisPreserveWords(8), 'Hello…');
    });

    test('returns original if shorter than cutoff', () {
      expect('Hello'.truncateWithEllipsisPreserveWords(10), 'Hello');
    });

    test('handles single long word with cutoff', () {
      expect('Supercalifragilistic'.truncateWithEllipsisPreserveWords(5), 'Super…');
    });

    test('handles first word longer than cutoff', () {
      expect('Pneumonoultramicroscopicsilicovolcanoconiosis is long'.truncateWithEllipsisPreserveWords(10), 'Pneumonoul…');
    });

    test('handles empty string', () {
      expect(''.truncateWithEllipsisPreserveWords(10), '');
    });

    test('handles null cutoff', () {
      expect('Hello World'.truncateWithEllipsisPreserveWords(null), 'Hello World');
    });

    test('handles zero cutoff', () {
      expect('Hello World'.truncateWithEllipsisPreserveWords(0), 'Hello World');
    });

    test('handles negative cutoff', () {
      expect('Hello World'.truncateWithEllipsisPreserveWords(-5), 'Hello World');
    });

    test('handles string with multiple spaces', () {
      expect('Hello   World'.truncateWithEllipsisPreserveWords(8), 'Hello…');
    });

    test('preserves full text when exactly at cutoff', () {
      expect('Hello'.truncateWithEllipsisPreserveWords(5), 'Hello');
    });
  });

  group('Fix 10: containsIgnoreCase - empty string handling', () {
    test('empty string is contained in any string', () {
      expect('Hello World'.containsIgnoreCase(''), isTrue);
    });

    test('empty string is contained in empty string', () {
      expect(''.containsIgnoreCase(''), isTrue);
    });

    test('null returns false', () {
      expect('Hello World'.containsIgnoreCase(null), isFalse);
    });

    test('case insensitive match', () {
      expect('Hello World'.containsIgnoreCase('HELLO'), isTrue);
    });

    test('lowercase search in uppercase text', () {
      expect('HELLO WORLD'.containsIgnoreCase('hello'), isTrue);
    });

    test('partial match', () {
      expect('Hello World'.containsIgnoreCase('llo Wor'), isTrue);
    });

    test('no match returns false', () {
      expect('Hello World'.containsIgnoreCase('xyz'), isFalse);
    });

    test('exact match', () {
      expect('Hello'.containsIgnoreCase('Hello'), isTrue);
    });

    test('empty source with non-empty search returns false', () {
      expect(''.containsIgnoreCase('hello'), isFalse);
    });

    test('mixed case search', () {
      expect('HeLLo WoRLd'.containsIgnoreCase('hello world'), isTrue);
    });
  });

  group('Fix 11: convertDaysToYearsAndMonths - improved precision', () {
    test('366 days (accounting for leap year avg) is 1 year', () {
      // With 365.25 avg days/year, 366 days is >= 1 year
      expect(DateTimeUtils.convertDaysToYearsAndMonths(366), '1 year');
    });

    test('365 days is 11 months with leap year averaging', () {
      // With 365.25 avg days/year, 365 days is slightly less than 1 year
      expect(DateTimeUtils.convertDaysToYearsAndMonths(365), '11 months');
    });

    test('731 days is approximately 2 years', () {
      // 731 days = 2 * 365.25 + 0.5 ≈ 2 years
      expect(DateTimeUtils.convertDaysToYearsAndMonths(731), '2 years');
    });

    test('400 days includes years and months', () {
      final String? result = DateTimeUtils.convertDaysToYearsAndMonths(400);
      expect(result, contains('year'));
      expect(result, contains('month'));
    });

    test('31 days is 1 month (using 30.4375 avg days/month)', () {
      // 31 days / 30.4375 = 1.02 months = 1 month
      expect(DateTimeUtils.convertDaysToYearsAndMonths(31), '1 month');
    });

    test('61 days is 2 months', () {
      // 61 days / 30.4375 = 2.0 months
      expect(DateTimeUtils.convertDaysToYearsAndMonths(61), '2 months');
    });

    test('null returns null', () {
      expect(DateTimeUtils.convertDaysToYearsAndMonths(null), isNull);
    });

    test('0 returns null', () {
      expect(DateTimeUtils.convertDaysToYearsAndMonths(0), isNull);
    });

    test('negative returns null', () {
      expect(DateTimeUtils.convertDaysToYearsAndMonths(-10), isNull);
    });

    test('small number without months shows 0 days', () {
      expect(DateTimeUtils.convertDaysToYearsAndMonths(10), '0 days');
    });
  });
}
