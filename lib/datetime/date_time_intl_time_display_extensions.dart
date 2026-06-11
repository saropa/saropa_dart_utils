part of 'date_time_intl_display_extensions.dart';

/// Locale-correct clock renderings. [locale] is an intl locale string (e.g.
/// `'en_US'`, `'fr_FR'`); `null` lets intl use its default.
extension DateTimeIntlTimeDisplayExtensions on DateTime {
  /// Display time like `3:30 PM` / `15:30` (locale clock), or hour-only when
  /// minutes are zero.
  ///
  /// Defaults to the locale's clock convention (12h AM/PM vs 24h), detected from
  /// intl's `jm` skeleton (an `'H'` in the pattern means 24h); override with
  /// [hour24] / [showAMPM]. [omitZeroMinutes] drops the `:00` on whole hours.
  /// The clock and its AM/PM marker are joined with a non-breaking space
  /// (U+00A0) so a bare time never wraps across two lines; any `, N s` seconds
  /// suffix stays breakable. Returns `null` on failure.
  String? makeDisplayTime({
    bool showSeconds = false,
    bool? showAMPM,
    bool? hour24,
    bool omitZeroMinutes = true,
    String? locale,
  }) {
    // A capital-H hour token in the jm skeleton means the locale uses a 24h
    // clock; its absence means a 12h clock with an AM/PM marker.
    try {
      final bool localeUses24Hour = DateFormat.jm(locale).pattern?.contains('H') ?? false;
      final bool is24 = hour24 ?? localeUses24Hour;
      final _ClockSpec spec = _ClockSpec(
        is24Hour: is24,
        // AM/PM is meaningless on a 24h clock; suppress it whenever 24h is in effect.
        hasAMPM: (showAMPM ?? !localeUses24Hour) && !is24,
        shouldOmitZeroMinutes: omitZeroMinutes,
        hasSeconds: showSeconds,
      );
      return _composeDisplayTime(this, spec, locale);
      // Unloaded/malformed locale must degrade to null, never crash a UI.
      // ignore: require_catch_logging -- display contract: never throw, callers fall back on null
    } on Object {
      return null;
    }
  }

  /// Fixed-form clock display selected by [type] (see [UtcTimeDisplayEnum]).
  ///
  /// ASCII spaces in the result are converted to non-breaking (U+00A0) so the
  /// clock never wraps across lines; patterns with no space (e.g. `20:31`) are
  /// returned unchanged.
  ///
  /// Example:
  /// ```dart
  /// DateTime(2026, 1, 15, 20, 31)
  ///     .utcTimeDisplay(UtcTimeDisplayEnum.twelveHourAMPM); // '8:31 PM'
  /// ```
  String utcTimeDisplay(UtcTimeDisplayEnum type, {String? locale}) {
    final String formatted = switch (type) {
      UtcTimeDisplayEnum.twelveHourWithSecondsAMPM => DateFormat.jms(locale).format(this),
      UtcTimeDisplayEnum.twelveHourAMPM => DateFormat.jm(locale).format(this),
      UtcTimeDisplayEnum.twentyFourHourWithSeconds => DateFormat.Hms(locale).format(this),
      UtcTimeDisplayEnum.twentyFourHour => DateFormat.Hm(locale).format(this),
      UtcTimeDisplayEnum.twelveHour => DateFormat('h:mm', locale).format(this),
      UtcTimeDisplayEnum.amPmOnly => DateFormat('a', locale).format(this),
    };
    return formatted.replaceAll(' ', ' ');
  }
}
