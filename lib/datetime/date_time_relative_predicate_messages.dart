part of 'date_time_relative_predicate_extensions.dart';

/// Sub-minute bands: under 45s renders "a moment" / "now"; 45–90s renders the
/// singular "a minute" / "a min". Returns `null` above 90s so the caller
/// advances to the minute band.
String? _relativeSubMinuteMessage(num seconds, bool isDescriptive) {
  if (seconds < 45) {
    return isDescriptive ? 'a moment' : relativeNowTime;
  }

  if (seconds < 90) {
    return isDescriptive ? 'a minute' : 'a min';
  }

  return null;
}

/// Minute band: under 45 minutes renders "N minutes"; 45–100 minutes is the
/// "about an hour" / "~1h" cusp. Returns `null` at/above 100 minutes so the
/// caller advances to the hour band.
String? _relativeMinuteMessage(num minutes, bool isDescriptive, bool roundUp) {
  if (minutes < 45) {
    final int display = roundUp ? minutes.round() : minutes.floor();

    // Terse "min" is never pluralized ("5 min", not "5 mins").
    final String unit = isDescriptive ? 'minute'.pluralize(display) : 'min';

    return '$display $unit';
  }

  if (minutes < 100) {
    return isDescriptive ? 'about an hour' : '~1h';
  }

  return null;
}

/// Hour band: under 24 hours renders "N hours"; 24–48 hours is the "a day" /
/// "~1d" cusp. Returns `null` at/above 48 hours so the caller advances to the
/// day band.
String? _relativeHourMessage(num hours, bool isDescriptive, bool roundUp) {
  if (hours < 24) {
    final int display = roundUp ? hours.round() : hours.floor();

    // Terse "hr" is never pluralized ("5 hr", not "5 hrs").
    final String unit = isDescriptive ? 'hour'.pluralize(display) : 'hr';

    return '$display $unit';
  }

  if (hours < 48) {
    return isDescriptive ? 'a day' : '~1d';
  }

  return null;
}

/// Day band and above: "N days" under 30d, the "about a month" cusp at 30–60d,
/// "N months" (rough 30-day month) under 365d, then the "about a year" cusp and
/// "N years" (days/365.25) as the final fallback for year-level spans that the
/// calendar-year path declined.
String _relativeDayMessage(num days, bool isDescriptive, bool roundUp) {
  if (days < 30) {
    final int display = roundUp ? days.round() : days.floor();

    // Terse "d" is never pluralized ("5 d", not "5 ds").
    final String unit = isDescriptive ? 'day'.pluralize(display) : 'd';

    return '$display $unit';
  }

  if (days < 60) {
    return isDescriptive ? 'about a month' : '~1mo';
  }

  // A 30-day average month is acceptable for display-only phrasing.
  if (days < 365) {
    final num months = days / 30;
    final int display = roundUp ? months.round() : months.floor();

    // Terse "mo" is never pluralized ("3 mo", not "3 mos").
    final String unit = isDescriptive ? 'month'.pluralize(display) : 'mo';

    return '$display $unit';
  }

  return _relativeFallbackYearMessage(days, isDescriptive, roundUp);
}

/// Year fallback reached only when the calendar-year algorithm declined a
/// year-level span: uses days/365.25, with a "about a year" cusp under 1.1
/// years. Kept separate so [_relativeDayMessage] stays within the length limit.
String _relativeFallbackYearMessage(num days, bool isDescriptive, bool roundUp) {
  final num years = days / 365.25;

  if (years < 1.1) {
    return isDescriptive ? 'about a year' : '~1y';
  }

  final int display = roundUp ? years.round() : years.floor();

  // Terse "y" is never pluralized ("3 y", not "3 ies").
  final String unit = isDescriptive ? 'year'.pluralize(display) : 'y';

  return '$display $unit';
}
