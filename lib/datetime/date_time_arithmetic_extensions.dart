import 'package:jiffy/jiffy.dart';
import 'package:meta/meta.dart';

/// Extensions on [DateTime] for add, subtract, and difference operations.
extension DateTimeArithmeticExtensions on DateTime {
  /// Returns the time difference in milliseconds between this [DateTime] and
  /// [compareTo], or `null` if [compareTo] is `null`.
  ///
  /// When [isAlwaysPositive] is `true` (default), the result is always
  /// non-negative.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  int? getTimeDifferenceMs(DateTime? compareTo, {bool isAlwaysPositive = true}) {
    if (compareTo == null) {
      return null;
    }

    final int inMilliseconds = difference(compareTo).inMilliseconds;

    return isAlwaysPositive ? inMilliseconds.abs() : inMilliseconds;
  }

  /// Adds the specified number of years to the current [DateTime].
  ///
  /// Note: When adding a year to February 29th, it returns February 28th
  ///  (not March 1st)
  ///
  /// Args:
  ///   years (int): The number of years to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added years.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime addYears(int years) {
    if (years == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).add(years: years).dateTime;
  }

  /// Adds the specified number of months to the current [DateTime].
  ///
  /// Args:
  ///   months (int): The number of months to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added months.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime addMonths(int months) {
    if (months == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).add(months: months).dateTime;
  }

  /// Adds the specified number of days to the current [DateTime].
  ///
  /// Args:
  ///   days (int): The number of days to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added days.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime addDays(int days) {
    if (days == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).add(days: days).dateTime;
  }

  /// Adds the specified number of hours to the current [DateTime].
  ///
  /// Args:
  ///   hours (int): The number of hours to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added hours.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime addHours(int hours) {
    if (hours == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).add(hours: hours).dateTime;
  }

  /// Adds the specified number of minutes to the current [DateTime].
  ///
  /// Args:
  ///   minutes (int): The number of minutes to add.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the added minutes.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime addMinutes(int minutes) {
    if (minutes == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).add(minutes: minutes).dateTime;
  }

  /// Subtracts the specified number of minutes from the current [DateTime].
  ///
  /// Args:
  ///   minutes (int): The number of minutes to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted minutes.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime subtractMinutes(int minutes) {
    if (minutes == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).subtract(minutes: minutes).dateTime;
  }

  /// Subtracts the specified number of hours from the current [DateTime].
  ///
  /// Args:
  ///   hours (int): The number of hours to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted hours.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime subtractHours(int hours) {
    if (hours == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).subtract(hours: hours).dateTime;
  }

  /// Subtracts the specified number of months from the current [DateTime].
  ///
  /// Args:
  ///   months (int): The number of months to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted months.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime subtractMonths(int months) {
    if (months == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).subtract(months: months).dateTime;
  }

  /// Subtracts the specified number of years from the current [DateTime].
  ///
  /// NOTE: you WILL lose Feb 29th when adding and subtracting 1 year
  ///
  /// Args:
  ///   years (int): The number of years to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted years.
  ///
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime subtractYears(int years) {
    if (years == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).subtract(years: years).dateTime;
  }

  /// Subtracts the specified number of days from the current [DateTime].
  ///
  /// Args:
  ///   days (int?): The number of days to subtract.
  ///
  /// Returns:
  ///   DateTime: A new [DateTime] object with the subtracted days.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  DateTime subtractDays(int? days) {
    if (days == null || days == 0) {
      return this;
    }

    return Jiffy.parseFromDateTime(this).subtract(days: days).dateTime;
  }
}
