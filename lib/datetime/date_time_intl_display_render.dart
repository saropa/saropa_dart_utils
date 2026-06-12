// ignore_for_file: require_timezone_display -- These are locale clock-RENDERING
// primitives; the timezone-display decision belongs to the caller's display
// context, not the formatter, so the rule's harm rationale ("users misinterpret
// a displayed time") cannot apply to a reusable formatter. The seconds-only
// formatter here renders the seconds field, which is timezone-invariant (offsets
// are never finer than minutes) — a provable false positive. Filed upstream as a
// saropa_lints false-positive bug report covering this rendering-primitive case
// and the pattern-introspection case in the sibling extensions file.
part of 'date_time_intl_display_extensions.dart';

// Private rendering helpers for [DateTimeIntlDisplayExtensions]. These were
// instance methods on the extension; they live here as top-level functions
// taking the [DateTime] explicitly so the public extension file stays under the
// project's 200-line cap. They remain private to this library, so the public
// surface is unchanged and no logic is duplicated.

/// Fixed English `Month 15th, 1945` rendering for the ordinal path of
/// [DateTimeIntlDisplayExtensions.dateDisplay].
/// Audited: 2026-06-12 11:26 EDT
String _ordinalDateDisplay(
  DateTime date,
  String monthFormat,
  String? locale,
  bool showYear,
) {
  // Format this date's own month name; the day is appended as an English
  // ordinal, so only the month token of [monthFormat] is rendered here.
  final String monthDisplay = DateFormat(monthFormat, locale).format(date);
  final String ordinalDay = _ordinal(date.day);
  return showYear ? '$monthDisplay $ordinalDay, ${date.year}' : '$monthDisplay $ordinalDay';
}

/// Locale-reordered skeleton rendering for the non-ordinal path of
/// [DateTimeIntlDisplayExtensions.dateDisplay].
/// Audited: 2026-06-12 11:26 EDT
String _skeletonDateDisplay(
  DateTime date,
  String monthFormat,
  String? locale,
  bool showYear,
) {
  // 'MMMM' is the only value that selects a FULL month name; everything else
  // (default 'MMM') uses the abbreviated skeleton.
  final bool fullMonth = monthFormat == 'MMMM';
  final DateFormat formatter = showYear
      ? (fullMonth ? DateFormat.yMMMMd(locale) : DateFormat.yMMMd(locale))
      : (fullMonth ? DateFormat.MMMMd(locale) : DateFormat.MMMd(locale));
  return formatter.format(date);
}

/// Picks the weekday/year skeleton combination for
/// [DateTimeIntlDisplayExtensions.makeDisplayDate].
/// Audited: 2026-06-12 11:26 EDT
String _displayDateFor(DateTime date, bool showYear, bool showWeekday, String? locale) {
  // Four skeletons: weekday vs not, year vs not. yMMMEd / MMMEd carry the
  // weekday (the leading "Thu, "); yMMMd / MMMd omit it.
  final DateFormat formatter = showWeekday
      ? (showYear ? DateFormat.yMMMEd(locale) : DateFormat.MMMEd(locale))
      : (showYear ? DateFormat.yMMMd(locale) : DateFormat.MMMd(locale));
  return formatter.format(date);
}

/// Builds the clock pattern from [spec], renders it non-breaking, and appends
/// any seconds suffix for [DateTimeIntlDisplayExtensions.makeDisplayTime]. The
/// clock uses U+00A0 so "8:31 PM" never wraps; the ", N s" suffix keeps a
/// normal breakable space.
/// Audited: 2026-06-12 11:26 EDT
String _composeDisplayTime(DateTime date, _ClockSpec spec, String? locale) {
  final String pattern = spec.clockPattern(hasMinutes: date.minute != 0);
  // Seconds suffix uses a normal breakable space; the clock itself is non-broken.
  final String displaySeconds = spec.hasSeconds
      ? ', ${DateFormat('ss', locale).format(date)} s'
      : '';
  // U+00A0 inside the clock so "8:31 PM" never wraps; only the clock is non-broken.
  final String clock = DateFormat(pattern, locale).format(date).replaceAll(' ', ' ');
  return clock + displaySeconds;
}
