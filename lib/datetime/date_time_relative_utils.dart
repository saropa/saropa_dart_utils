const String _kSuffixAgo = ' ago';
const String _kPrefixIn = 'in ';
const String _kJustNow = 'just now';
const String _kInAMoment = 'in a moment';
const String _kMinute = 'minute';
const String _kMinutes = 'minutes';
const String _kHour = 'hour';
const String _kHours = 'hours';
const String _kYesterday = 'yesterday';
const String _kTomorrow = 'tomorrow';
const String _kDays = 'days';
const String _kWeek = 'week';
const String _kWeeks = 'weeks';
const String _kMonth = 'month';
const String _kMonths = 'months';
const String _kYear = 'year';
const String _kYears = 'years';

String _relativeUnit(int n, String singular, String plural) => n == 1 ? singular : plural;

/// Returns a relative time string: "2 hours ago", "in 3 days", "just now".
///
/// [clock] defaults to [DateTime.now]. English only.
String relativeTimeString(DateTime dateTime, {DateTime? clock}) {
  final DateTime now = clock ?? DateTime.now();
  final Duration diff = dateTime.difference(now);
  final int sec = diff.inSeconds.abs();
  final int min = diff.inMinutes.abs();
  final int hour = diff.inHours.abs();
  final int day = diff.inDays.abs();
  final bool isPast = diff.isNegative;
  final String suffix = isPast ? _kSuffixAgo : '';
  final String prefix = isPast ? '' : _kPrefixIn;
  if (sec < 60) return isPast ? _kJustNow : _kInAMoment;
  if (min < 60) return '$prefix$min ${_relativeUnit(min, _kMinute, _kMinutes)}$suffix';
  if (hour < 24) return '$prefix$hour ${_relativeUnit(hour, _kHour, _kHours)}$suffix';
  if (day == 1) return isPast ? _kYesterday : _kTomorrow;
  if (day < 7) return '$prefix$day $_kDays$suffix';
  final int weeks = (day / 7).floor();
  if (day < 30) return '$prefix$weeks ${_relativeUnit(weeks, _kWeek, _kWeeks)}$suffix';
  final int months = (day / 30).floor();
  if (day < 365) return '$prefix$months ${_relativeUnit(months, _kMonth, _kMonths)}$suffix';
  final int years = (day / 365).floor();
  return '$prefix$years ${_relativeUnit(years, _kYear, _kYears)}$suffix';
}
