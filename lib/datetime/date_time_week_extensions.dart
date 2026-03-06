import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_time_calendar_extensions.dart';

/// Week number in month; ISO week string format/parse.
extension DateTimeWeekInMonthExtensions on DateTime {
  /// Week number within the month (1-based). First partial week is 1.
  @useResult
  int get weekNumberInMonth {
    final int dayOfMonth = day;
    final DateTime first = DateTime(year, month);
    final int firstWeekday = first.weekday;
    final int daysInFirstWeek = 8 - firstWeekday; // Sunday = 7
    if (dayOfMonth <= daysInFirstWeek) return 1;
    return ((dayOfMonth - daysInFirstWeek - 1) / 7).floor() + 2;
  }

  /// ISO week string (e.g. "2026-W09").
  @useResult
  String get toIsoWeekString {
    final int w = weekNumber();
    return '$year-W${w.toString().padLeft(2, '0')}';
  }
}

/// Parses ISO week string "2026-W09" to the Monday of that week.
DateTime? parseIsoWeekString(String s) {
  final RegExp re = RegExp(r'^(\d{4})-W(\d{2})$');
  final RegExpMatch? m = re.firstMatch(s.trim());
  if (m == null) return null;
  final yearGroup = m.group(1);
  final weekGroup = m.group(2);
  if (yearGroup == null || weekGroup == null) return null;
  final int? yearVal = int.tryParse(yearGroup);
  final int? weekVal = int.tryParse(weekGroup);
  if (yearVal == null || weekVal == null || weekVal < 1 || weekVal > 53) return null;
  final DateTime jan4 = DateTime(yearVal, 1, 4);
  final int jan4Weekday = jan4.weekday;
  final DateTime monday = DateTime(yearVal, 1, 4 - (jan4Weekday - 1));
  final DateTime targetMonday = DateTime(monday.year, monday.month, monday.day + (weekVal - 1) * 7);
  if (targetMonday.year != yearVal && weekVal > 1) return null;
  return targetMonday;
}
