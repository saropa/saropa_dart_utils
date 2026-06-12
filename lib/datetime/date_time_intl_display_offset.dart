part of 'date_time_intl_display_extensions.dart';

/// Clock-display presets for [DateTimeIntlDisplayExtensions.utcTimeDisplay].
///
/// Each value maps to an intl skeleton (or raw pattern) so the rendered clock
/// follows the requested precision and 12h/24h convention. Example outputs are
/// for the en_US locale.
enum UtcTimeDisplayEnum {
  /// Displays hours, minutes, seconds, and AM/PM (e.g. 10:30:45 PM).
  twelveHourWithSecondsAMPM,

  /// Displays hours, minutes, and AM/PM (e.g. 10:30 PM).
  twelveHourAMPM,

  /// Displays hours, minutes, and seconds (e.g. 22:30:45).
  twentyFourHourWithSeconds,

  /// Displays hours and minutes (e.g. 22:30).
  twentyFourHour,

  /// Displays hours and minutes without AM/PM (e.g. 10:30).
  twelveHour,

  /// Displays only AM/PM (e.g. PM).
  amPmOnly,
}

/// Formats a UTC offset [Duration] as `UTC+H:MM` / `UTC-H` / `UTC±0`.
///
/// Pure Dart (no intl). Pulled out as a top-level function so tests can pass a
/// FIXED [offset] — [DateTime.timeZoneOffset] is host-environment dependent and
/// would make the extension form non-deterministic in CI.
///
/// Minutes are elided when zero (`UTC+5`, not `UTC+5:00`) for a cleaner display,
/// and zero uses the `±` plus-minus sign rather than an arbitrary `+`/`-`.
/// [verbose] renders zero as the full `UTC±00:00`.
///
/// Edge cases: whole-hour positive/negative (`UTC+5`, `UTC-8`), half-hour
/// (`UTC+5:30`), 45-minute (`UTC+5:45`), and extreme offsets (`UTC+14`,
/// `UTC-12`) all render without overflow because the math is plain integer
/// arithmetic on the duration.
///
/// Example:
/// ```dart
/// formatUtcOffset(const Duration(hours: 5, minutes: 30)); // 'UTC+5:30'
/// formatUtcOffset(Duration.zero, verbose: true);          // 'UTC±00:00'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String formatUtcOffset(Duration offset, {bool verbose = false}) {
  // Zero is signless: '±' communicates "no offset" without picking a direction.
  if (offset.inSeconds == 0) {
    return verbose ? 'UTC±00:00' : 'UTC±0';
  }
  final String offsetSign = offset.isNegative ? '-' : '+';
  final int offsetHours = offset.inHours.abs();
  // Keep only the sub-hour minutes — the thirty in a five-thirty offset.
  final int offsetMinutes = offset.inMinutes.remainder(60).abs();
  // Only display minutes when non-zero so whole-hour offsets stay compact.
  if (offsetMinutes > 0) {
    return 'UTC$offsetSign$offsetHours:${offsetMinutes.toString().padLeft(2, '0')}';
  }
  return 'UTC$offsetSign$offsetHours';
}
