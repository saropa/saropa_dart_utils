/// Locale-correct `DateTime` display via `intl` skeletons — the one opt-in
/// module in `lib/datetime/` that pulls the `intl` dependency.
///
/// The rest of this package deliberately avoids `intl` (see
/// `date_format_preset_utils.dart`, which formats manually with injectable
/// names in a FIXED layout). These extensions exist because a fixed layout
/// cannot reorder components per locale: intl skeletons (`yMMMd`, `MMMEd`,
/// `jm`, ...) render "Jan 15, 1945" for en_US but "15 janv. 1945" for fr_FR
/// and "1945年1月15日" for ja_JP, AND auto-detect each locale's clock
/// convention (12h AM/PM vs 24h). None of the logic is domain-specific; it
/// operates on any `DateTime`.
///
/// Callers that format non-English locales MUST call
/// `initializeDateFormatting()` (from `package:intl/date_symbol_data_local.dart`)
/// once per process before invoking these methods — intl throws for an
/// unloaded locale, and every method here catches that and degrades rather
/// than propagating.
///
/// Split across `part` files purely to honor the project's 200-line file cap.
/// The display methods are grouped into three extensions on `DateTime` —
/// [DateTimeIntlDisplayExtensions] (offset + explicit-pattern formatting),
/// [DateTimeIntlDateDisplayExtensions] (calendar-date renderings), and
/// [DateTimeIntlTimeDisplayExtensions] (clock renderings). All of it is ONE
/// library, so the private helpers stay shared across the parts and every
/// method is still called on a plain `DateTime` exactly as before; the split
/// is invisible to callers, who import this file via the barrel.
library;

import 'package:intl/intl.dart';

part 'date_time_intl_display_offset.dart';
part 'date_time_intl_display_helpers.dart';
part 'date_time_intl_display_render.dart';
part 'date_time_intl_date_display_extensions.dart';
part 'date_time_intl_time_display_extensions.dart';

// These are wall-clock display helpers: they intentionally render the
// DateTime's local fields without a timezone marker, because the timezone is
// shown separately via getUtcOffset. Requiring a tz token in every clock
// pattern here would corrupt the locale-correct skeleton output this module
// exists to produce.
// ignore_for_file: require_timezone_display -- wall-clock display; tz shown via getUtcOffset

/// Locale-correct `DateTime` display: UTC offset and explicit-pattern
/// formatting. [locale] throughout is an intl locale string (e.g. `'en_US'`,
/// `'fr_FR'`); `null` lets intl use its default.
extension DateTimeIntlDisplayExtensions on DateTime {
  /// UTC offset for this `DateTime` as `UTC+H:MM` / `UTC-H` / `UTC±0`.
  ///
  /// Reads the host [timeZoneOffset], so the result depends on the running
  /// environment's timezone — for deterministic formatting in tests, call the
  /// top-level [formatUtcOffset] with a fixed `Duration` instead. Returns
  /// `null` on any failure so a display string never throws. See
  /// [formatUtcOffset] for the verbose/minute-eliding rules and examples.
  String? getUtcOffset({bool verbose = false}) {
    try {
      return formatUtcOffset(timeZoneOffset, verbose: verbose);
      // Defensive: timeZoneOffset is host-provided; null on any failure.
      // ignore: require_catch_logging -- display contract: never throw, callers fall back on null
    } on Object {
      return null;
    }
  }

  /// Formats this `DateTime` with an explicit intl [format] pattern.
  ///
  /// Returns `''` (never throws) on an invalid pattern, honoring the
  /// "always renders something" contract callers rely on for display.
  /// [showLogTimeMilliseconds] appends a 4-digit `.0137` millisecond suffix for
  /// log timestamps.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2026, 1, 15, 22, 30).toDateFormat('HH:mm'); // '22:30'
  /// ```
  String toDateFormat(
    String format, {
    String? locale,
    bool showLogTimeMilliseconds = false,
  }) {
    // intl echoes unrecognized field letters (e.g. 'q') as literals instead of
    // throwing, so the try/catch alone cannot enforce the contract — reject
    // unknown fields up front so an invalid pattern degrades to '' as documented.
    if (_patternHasUnknownField(format)) {
      return '';
    }
    try {
      final String suffix =
          showLogTimeMilliseconds ? '.${millisecond.toString().padLeft(4, '0')}' : '';
      return DateFormat(format, locale).format(this) + suffix;
      // Invalid pattern / locale must degrade to empty rather than crash a UI.
      // ignore: require_catch_logging -- display contract: never throw, callers get ''
    } on Object {
      return '';
    }
  }
}
