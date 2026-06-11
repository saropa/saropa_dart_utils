part of 'date_time_intl_display_extensions.dart';

/// Resolved clock options for [DateTimeIntlDisplayExtensions.makeDisplayTime].
///
/// Bundling the four flags into one value keeps the pattern-building helper
/// within the project's three-parameter limit and lets the clock-convention
/// resolution (12h vs 24h, AM/PM, minute-eliding) live in one place.
class _ClockSpec {
  const _ClockSpec({
    required this.is24Hour,
    required this.hasAMPM,
    required this.shouldOmitZeroMinutes,
    required this.hasSeconds,
  });

  /// Whether to render a 24-hour clock (no AM/PM marker).
  final bool is24Hour;

  /// Whether to append an AM/PM marker (only meaningful on a 12h clock).
  final bool hasAMPM;

  /// Whether a whole-hour time drops its `:00` minutes.
  final bool shouldOmitZeroMinutes;

  /// Whether a seconds suffix is appended.
  final bool hasSeconds;

  /// intl pattern for the clock portion, given whether the time has minutes.
  String clockPattern({required bool hasMinutes}) {
    // Bare hour only when eliding is on, the time is on the hour, and no seconds.
    final bool isHourOnly = shouldOmitZeroMinutes && !hasMinutes && !hasSeconds;
    final String base = is24Hour ? (isHourOnly ? 'HH' : 'HH:mm') : (isHourOnly ? 'h' : 'h:mm');
    return hasAMPM ? '$base a' : base;
  }
}

/// The ASCII letters intl's `DateFormat` recognizes as field tokens (CLDR
/// subset actually implemented by intl 0.20.x: `GyMkSEahKHcLQdDmsvzZ`). Any
/// OTHER ASCII letter is silently echoed as a literal by intl rather than
/// throwing, so [_patternHasUnknownField] uses this set to reject invalid
/// patterns up front. Sourced from intl's own pattern matcher
/// (`date_format.dart` `_matchers`), so it tracks what intl will actually
/// render; if intl gains a field letter, update this string.
const String _intlFieldLetters = 'GyMkSEahKHcLQdDmsvzZ';

/// True if [pattern] contains an ASCII letter that intl does NOT implement as a
/// field — e.g. `'q'`, `'x'`, `'b'`, `'w'`. intl echoes such letters as literal
/// text instead of throwing, so the only way to honor the "invalid pattern → ''"
/// contract is to detect them before formatting. Letters inside single-quoted
/// literal sections are skipped because there they are intended as literal text.
bool _patternHasUnknownField(String pattern) {
  bool inQuotes = false;
  for (final int unit in pattern.codeUnits) {
    // Toggle on the single-quote so letters inside 'literal text' are exempt.
    if (unit == 0x27) {
      inQuotes = !inQuotes;
      continue;
    }
    final bool isAsciiLetter =
        (unit >= 0x41 && unit <= 0x5A) || (unit >= 0x61 && unit <= 0x7A);
    if (!inQuotes && isAsciiLetter && !_intlFieldLetters.contains(String.fromCharCode(unit))) {
      return true;
    }
  }
  return false;
}

/// English ordinal suffix for a day-of-month [n] (1st, 2nd, 3rd, 21st, ...).
///
/// The `% 100 in 11..13` carve-out is the classic ordinal bug: 11/12/13 are
/// "th" despite ending in 1/2/3, so the teens exception is checked BEFORE the
/// ones digit. English-only by design — ordinals do not localize, which is why
/// callers that want ordinals accept fixed English month-day order.
String _ordinal(int n) {
  // Teens (…11, …12, …13) are always 'th' regardless of the ones digit.
  if (n % 100 >= 11 && n % 100 <= 13) {
    return '${n}th';
  }
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}
