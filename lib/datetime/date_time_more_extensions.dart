import 'package:meta/meta.dart';

/// DateTime More: is same day, is morning/afternoon/evening, duration between, within last N, etc. Roadmap #304-310.
extension DateTimeMoreExtensions on DateTime {
  /// True if this date is the same calendar day as [other].
  @useResult
  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;

  /// True if hour is in 5..11 (morning).
  @useResult
  bool get isMorning => hour >= 5 && hour < 12;

  /// True if hour is in 12..16 (afternoon).
  @useResult
  bool get isAfternoon => hour >= 12 && hour < 17;

  /// True if hour is >= 17 or < 5 (evening/night).
  @useResult
  bool get isEvening => hour >= 17 || hour < 5;

  /// True if this is on or after [now] minus [n] days and not after [now].
  @useResult
  bool isWithinLastDays(int n, DateTime now) {
    final DateTime cutoff = DateTime(now.year, now.month, now.day - n);
    return !isBefore(cutoff) && !isAfter(now);
  }

  /// True if this is within the last [n] hours before [now].
  @useResult
  bool isWithinLastHours(int n, DateTime now) {
    final DateTime cutoff = now.subtract(Duration(hours: n));
    return !isBefore(cutoff) && !isAfter(now);
  }
}

Duration durationBetween(DateTime a, DateTime b) => b.difference(a).abs();

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
List<int> yearsBetween(DateTime start, DateTime end) {
  final List<int> out = <int>[];
  for (int y = start.year; y <= end.year; y++) out.add(y);
  return out;
}
