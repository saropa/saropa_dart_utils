import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/datetime/date_time_calendar_extensions.dart';

/// Week number in month; ISO week string format/parse.
extension DateTimeWeekInMonthExtensions on DateTime {
  /// Week number within the month (1-based). First partial week is 1.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  int get weekNumberInMonth {
    final int dayOfMonth = day;
    final DateTime first = DateTime(year, month);
    final int firstWeekday = first.weekday;
    // weekday is Mon=1..Sun=7, so 8 - weekday gives remaining days in week 1
    final int daysInFirstWeek = 8 - firstWeekday;
    if (dayOfMonth <= daysInFirstWeek) return 1;
    return ((dayOfMonth - daysInFirstWeek - 1) / 7).floor() + 2;
  }

  /// ISO week string (e.g. "2026-W09").
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String get toIsoWeekString {
    final int w = weekNumber();
    return '$year-W${w.toString().padLeft(2, '0')}';
  }
}

/// Parses ISO week string "2026-W09" to the Monday of that week.
/// Audited: 2026-06-12 11:26 EDT
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
  // ISO-8601: week 1 is always the week containing Jan 4 (equivalently, the week
  // with the year's first Thursday). Anchoring on Jan 4 sidesteps the edge case
  // where Jan 1 falls in the final week of the previous year.
  final DateTime jan4 = DateTime(yearVal, 1, 4);
  final int jan4Weekday = jan4.weekday;
  // Step back to that week's Monday (weekday Mon=1), then add whole weeks.
  // Day overflow past month/year end is handled by DateTime's normalization.
  final DateTime monday = DateTime(yearVal, 1, 4 - (jan4Weekday - 1));
  final DateTime targetMonday = DateTime(monday.year, monday.month, monday.day + (weekVal - 1) * 7);
  // Reject a week number the year does not have (e.g. 2025-W53 — 2025 has only
  // 52 ISO weeks). The ISO week-YEAR of any week is the calendar year of that
  // week's Thursday; if the Thursday is not in yearVal, the week is not part of
  // yearVal. (The previous year-of-Monday check missed 2025-W53, whose Monday
  // 2025-12-29 stays in 2025 but whose Thursday lands in 2026.)
  final DateTime thursday = DateTime(targetMonday.year, targetMonday.month, targetMonday.day + 3);
  if (thursday.year != yearVal) return null;
  return targetMonday;
}
