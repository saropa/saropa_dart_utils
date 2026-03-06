/// Relative date bucketing ("today", "yesterday", "last 7 days") — roadmap #616.
library;

const String _kToday = 'today';
const String _kYesterday = 'yesterday';
const String _kLast7Days = 'last 7 days';
const String _kLast30Days = 'last 30 days';
const String _kOlder = 'older';

/// Bucket label for [date] relative to [today]. Returns short label.
String relativeDateBucket(DateTime date, DateTime today) {
  final DateTime d = DateTime(date.year, date.month, date.day);
  final DateTime t = DateTime(today.year, today.month, today.day);
  final int days = t.difference(d).inDays;
  if (days == 0) return _kToday;
  if (days == 1) return _kYesterday;
  if (days > 1 && days <= 7) return _kLast7Days;
  if (days > 7 && days <= 30) return _kLast30Days;
  return _kOlder;
}
