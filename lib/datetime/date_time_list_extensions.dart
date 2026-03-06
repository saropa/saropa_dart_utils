import 'package:meta/meta.dart';

/// Min/max of list of [DateTime]; sort; generate date range.
extension DateTimeListMinMaxExtensions on List<DateTime> {
  /// Returns the earliest [DateTime], or `null` if empty.
  DateTime? get minOrNull =>
      isEmpty ? null : reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);

  /// Returns the latest [DateTime], or `null` if empty.
  DateTime? get maxOrNull =>
      isEmpty ? null : reduce((DateTime a, DateTime b) => a.isAfter(b) ? a : b);

  /// Returns a new list sorted by date (earliest first).
  @useResult
  List<DateTime> sortedByDate() => List<DateTime>.of(this)..sort();
}

/// Generates a range of dates from [start] to [end] inclusive, stepping by [stepDays] days.
Iterable<DateTime> dateRange(DateTime start, DateTime end, {int stepDays = 1}) sync* {
  if (stepDays <= 0) return;
  final DateTime startDate = DateTime(start.year, start.month, start.day);
  final DateTime endDate = DateTime(end.year, end.month, end.day);
  DateTime current = startDate;
  while (!current.isAfter(endDate)) {
    yield current;
    current = DateTime(current.year, current.month, current.day + stepDays);
  }
}
