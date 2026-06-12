part of 'date_time_intl_display_extensions.dart';

/// Locale-correct calendar-date renderings (no clock). [locale] is an intl
/// locale string (e.g. `'en_US'`, `'fr_FR'`); `null` lets intl use its default.
extension DateTimeIntlDateDisplayExtensions on DateTime {
  /// Display date like `Jan 15, 1945` (or `Jan 15th, 1945` with
  /// [showDayOrdinal]). When [showCurrentYear] is false, the year is omitted for
  /// dates in the current year (determined against [now], injectable for tests).
  ///
  /// Named skeletons (`yMMMd` / `MMMMd` / ...) reorder per locale; the ordinal
  /// path does not, because English ordinals lock English month-day order.
  /// `monthFormat == 'MMMM'` selects the full month name; any other value uses
  /// the abbreviated skeleton.
  ///
  /// Example:
  /// ```dart
  /// DateTime(1945, 1, 15).dateDisplay(locale: 'en_US'); // 'Jan 15, 1945'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  String dateDisplay({
    String monthFormat = 'MMM',
    bool showDayOrdinal = false,
    bool showCurrentYear = true,
    String? locale,
    DateTime? now,
  }) {
    final DateTime today = now ?? DateTime.now();
    final bool showYear = showCurrentYear || year != today.year;
    // English-ordinal path keeps fixed month-day order; it cannot localize.
    if (showDayOrdinal) {
      return _ordinalDateDisplay(this, monthFormat, locale, showYear);
    }
    return _skeletonDateDisplay(this, monthFormat, locale, showYear);
  }

  /// Display date with weekday like `Thu, Jul 21, 2020` (locale-ordered).
  ///
  /// Returns `null` on failure (unloaded locale) so callers can fall back. The
  /// year is shown only when [showYear] is true AND either [showCurrentYear] is
  /// set or the date is not in the current year (against [now]) AND `year > 0`
  /// — the `year > 0` guard suppresses the year for the BCE/placeholder dates
  /// `DateTime(0)` produces, which would otherwise render a misleading "1".
  /// [showWeekday] toggles the leading weekday.
  /// Audited: 2026-06-12 11:26 EDT
  String? makeDisplayDate({
    bool showYear = true,
    bool showCurrentYear = false,
    bool showWeekday = true,
    String? locale,
    DateTime? now,
  }) {
    try {
      final DateTime today = now ?? DateTime.now();
      // Combine all three year-suppression rules; year > 0 blocks year-zero noise.
      final bool renderYear = showYear && (showCurrentYear || year != today.year) && year > 0;
      return _displayDateFor(this, renderYear, showWeekday, locale);
      // Unloaded/malformed locale must degrade to null, never crash a UI.
      // ignore: require_catch_logging -- display contract: never throw, callers fall back on null
    } on Object {
      return null;
    }
  }

  /// Locale-ordered full month name, day, year: `January 15, 1945` (en_US),
  /// `15 janvier 1945` (fr_FR), `1945年1月15日` (ja_JP).
  ///
  /// Uses the `yMMMMd` skeleton so component order follows the language — a
  /// literal `'d MMMM yyyy'` pattern would lock English order. Returns `''`
  /// (never throws) on an unloaded locale.
  /// Audited: 2026-06-12 11:26 EDT
  String fullDateDisplay({String? locale}) {
    try {
      return DateFormat.yMMMMd(locale).format(this);
      // Unloaded/malformed locale must degrade to empty, never crash a UI.
      // ignore: require_catch_logging -- display contract: never throw, callers get ''
    } on Object {
      return '';
    }
  }

  /// Locale short date: en_US `08/16/2023`, en_GB/fr_FR `16/08/2023`.
  ///
  /// [ddMMyyFormat] forces the fixed `dd MMM yy` pattern instead of the locale
  /// `yMd` skeleton. Returns `null` on failure (unloaded locale) so callers can
  /// fall back to another format.
  /// Audited: 2026-06-12 11:26 EDT
  String? formatByLocale({String? locale, bool ddMMyyFormat = false}) {
    try {
      return ddMMyyFormat
          ? DateFormat('dd MMM yy', locale).format(this)
          : DateFormat.yMd(locale).format(this);
      // Unloaded/malformed locale must degrade to null, never crash a UI.
      // ignore: require_catch_logging -- display contract: never throw, callers fall back on null
    } on Object {
      return null;
    }
  }
}
