import 'package:meta/meta.dart';

/// DateTime More: is same day, is morning/afternoon/evening, duration between, within last N, etc. Roadmap #304-310.
extension DateTimeMoreExtensions on DateTime {
  /// True if this date is the same calendar day as [other].
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  /// True if hour is in 5..11 (morning).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isMorning => hour >= 5 && hour < 12;

  /// True if hour is in 12..16 (afternoon).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isAfternoon => hour >= 12 && hour < 17;

  /// True if hour is >= 17 or < 5 (evening/night).
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isEvening => hour >= 17 || hour < 5;

  /// True if this is on or after [now] minus [n] days and not after [now].
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool isWithinLastDays(int n, DateTime now) {
    final DateTime cutoff = DateTime(now.year, now.month, now.day - n);
    return !isBefore(cutoff) && !isAfter(now);
  }

  /// True if this is within the last [n] hours before [now].
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool isWithinLastHours(int n, DateTime now) {
    final DateTime cutoff = now.subtract(Duration(hours: n));
    return !isBefore(cutoff) && !isAfter(now);
  }
}

/// Returns the absolute [Duration] between [a] and [b], regardless of order.
///
/// Example:
/// ```dart
/// durationBetween(DateTime(2020), DateTime(2020, 1, 2)); // 1 day
/// ```
/// Audited: 2026-06-12 11:26 EDT
Duration durationBetween(DateTime a, DateTime b) => b.difference(a).abs();

/// Returns the first day of each month from [start] through [end] inclusive.
/// The day and time components of the inputs are ignored.
///
/// Example:
/// ```dart
/// monthsBetween(DateTime(2020, 1, 15), DateTime(2020, 3, 1));
/// // [2020-01-01, 2020-02-01, 2020-03-01]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<DateTime> monthsBetween(DateTime start, DateTime end) {
  final List<DateTime> out = <DateTime>[];
  DateTime d = DateTime(start.year, start.month);
  final DateTime e = DateTime(end.year, end.month);
  while (!d.isAfter(e)) {
    out.add(d);
    d = DateTime(d.year, d.month + 1);
  }
  return out;
}

/// List of years from [start].year through [end].year (inclusive).
/// Audited: 2026-06-12 11:26 EDT
List<int> yearsBetween(DateTime start, DateTime end) {
  final List<int> out = <int>[];
  for (int y = start.year; y <= end.year; y++) {
    out.add(y);
  }
  return out;
}
