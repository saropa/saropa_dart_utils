import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_text_extensions.dart';

/// Clock- and word-style formatters for [Duration].
///
/// These complement the existing top-level `formatDuration(Duration d, ...)`
/// in `duration_format_utils.dart`, which rolls up to **days** and uses
/// space-separated short labels. The members here deliberately differ:
///
/// - [displayTime] renders a stopwatch/media `HH:MM:SS.mmm` clock string and
///   never rolls hours into days (a 25-hour duration shows as `25:...`).
/// - [formatDuration] renders a comma-joined human list of non-zero units down
///   to **microseconds**, returning `'Instantaneous'` for [Duration.zero].
/// - [reverse] returns the sign-negated duration.
///
/// All operations are pure integer arithmetic on [Duration] fields — no
/// locale, no wall-clock date, so there are no DST / timezone / leap-year
/// concerns (those apply to [DateTime], not [Duration]).
extension DurationClockFormatExtensions on Duration {
  /// Formats this duration as a zero-padded stopwatch clock string.
  ///
  /// - When [showHours] is `true` (default): `'HH:MM:SS.mmm'`.
  /// - When [showHours] is `false`: `'MM:SS.mmm'`.
  ///
  /// Hours are NEVER reduced modulo 24 — a duration longer than a day shows
  /// the full hour count (`Duration(hours: 25)` -> `'25:00:00.000'`). This is
  /// the intended difference from the day-aware top-level `formatDuration`,
  /// and makes the output correct for elapsed timers that exceed 24 hours.
  /// `padLeft(2)` is a minimum width, not a truncation, so triple-digit hours
  /// (`Duration(hours: 100)`) render in full as `'100:00:00.000'`.
  ///
  /// Microseconds are intentionally dropped: only whole-millisecond precision
  /// is shown, so `Duration(microseconds: 500)` yields `'...00:00.000'`.
  ///
  /// Negative durations are NOT special-cased. Because Dart's `%` returns a
  /// non-negative result for a positive divisor, the minute/second/millisecond
  /// components wrap rather than show a `-` sign (e.g. `Duration(seconds: -5)`
  /// -> `'00:00:55.000'`, since `-5 % 60 == 55`). Callers that need a signed
  /// clock should [reverse] first and prefix the sign themselves.
  ///
  /// Example:
  /// ```dart
  /// Duration(hours: 1, minutes: 30, seconds: 45, milliseconds: 123)
  ///     .displayTime(); // '01:30:45.123'
  /// Duration(minutes: 5, seconds: 30, milliseconds: 50)
  ///     .displayTime(showHours: false); // '05:30.050'
  /// ```
  @useResult
  String displayTime({bool showHours = true}) {
    // Hours are unbounded (no mod-24) so timers past a day stay correct.
    final String hoursStr = showHours ? '${inHours.toString().padLeft(2, '0')}:' : '';
    final String minutesStr = '${(inMinutes % 60).toString().padLeft(2, '0')}:';
    final String secondsStr = (inSeconds % 60).toString().padLeft(2, '0');

    // Millisecond fraction only; microseconds are deliberately not surfaced.
    final String millisecondsStr = '.${(inMilliseconds % 1000).toString().padLeft(3, '0')}';

    return '$hoursStr$minutesStr$secondsStr$millisecondsStr';
  }

  /// Formats this duration as a comma-joined human-readable list of units.
  ///
  /// Emits only the non-zero components from hours down to microseconds, in
  /// descending order, joined with `', '` (e.g. `'1 hr, 30 mins'`). Hours are
  /// the largest unit — there is no day rollup, so `Duration(days: 10000)`
  /// renders as `'240000 hrs'`.
  ///
  /// - [showLeadingZeros]: when `true`, single-digit hour/minute/second values
  ///   are zero-padded (`'05 mins'` vs `'5 mins'`). Milliseconds and
  ///   microseconds are never padded.
  /// - [shortForm]: when `true` (default), uses `hr`/`min`/`sec`/`ms`/`μs`;
  ///   when `false`, uses pluralized long words (`hour`/`minute`/...).
  ///
  /// [Duration.zero] always returns `'Instantaneous'` regardless of either
  /// flag — there are no non-zero units to list.
  ///
  /// Negative durations are not special-cased: [int.remainder] preserves sign,
  /// so each component keeps its `-` (e.g. `Duration(seconds: -90)` ->
  /// `'-1 mins, -30 secs'`). [reverse] first if you want positive magnitudes.
  ///
  /// Returns nullable to match the source API, but the implementation never
  /// returns `null` — non-zero durations always yield a (possibly multi-unit)
  /// string and zero yields `'Instantaneous'`.
  ///
  /// Example:
  /// ```dart
  /// Duration(hours: 2, minutes: 30).formatDuration(); // '2 hrs, 30 mins'
  /// Duration(hours: 1).formatDuration(shortForm: false); // '1 hour'
  /// Duration.zero.formatDuration(); // 'Instantaneous'
  /// ```
  @useResult
  String? formatDuration({bool showLeadingZeros = false, bool shortForm = true}) {
    // Zero has no units to enumerate; sentinel avoids an empty join result.
    if (this == Duration.zero) {
      return 'Instantaneous';
    }

    final List<String> formatted = _unitParts(showLeadingZeros: showLeadingZeros, shortForm: shortForm);

    // The list only ever holds non-null strings; the filter drops any empties
    // (inlined replacement for the app's joinNotNullOrEmpty helper).
    return formatted.where((String s) => s.isNotEmpty).join(', ');
  }

  /// Returns the sign-negated duration (positive <-> negative).
  ///
  /// `Duration.zero.reverse()` is `Duration.zero` (Dart has no negative-zero
  /// duration), and a double reverse is the identity: `d.reverse().reverse()`
  /// equals `d`.
  ///
  /// Example:
  /// ```dart
  /// Duration(hours: 1).reverse().inHours; // -1
  /// Duration(hours: -1).reverse().inHours; // 1
  /// ```
  @useResult
  Duration reverse() => this * -1;

  /// Builds the ordered list of non-zero unit labels for [formatDuration].
  ///
  /// Extracted so [formatDuration] stays under the 20-line limit. Uses
  /// [int.remainder] (sign-preserving) rather than `%` so the joined output
  /// matches the source app's behavior for negative inputs.
  List<String> _unitParts({required bool showLeadingZeros, required bool shortForm}) {
    /// Pad to two digits only when the value is single-digit AND padding asked.
    String twoDigits(int n) => n >= 10 || !showLeadingZeros ? '$n' : '0$n';

    final int minRemainder = inMinutes.remainder(60);
    final int secRemainder = inSeconds.remainder(60);
    final int millisecondRemainder = inMilliseconds.remainder(1000);
    final int microRemainder = inMicroseconds.remainder(1000);

    return <String>[
      if (inHours != 0)
        '${twoDigits(inHours)} ${(shortForm ? 'hr' : 'hour').pluralize(inHours, simple: true)}',
      if (minRemainder != 0)
        '${twoDigits(minRemainder)} ${(shortForm ? 'min' : 'minute').pluralize(minRemainder, simple: true)}',
      if (secRemainder != 0)
        '${twoDigits(secRemainder)} ${(shortForm ? 'sec' : 'second').pluralize(secRemainder, simple: true)}',
      if (millisecondRemainder != 0)
        '$millisecondRemainder ${shortForm ? 'ms' : 'millisecond'.pluralize(millisecondRemainder, simple: true)}',
      // 'microsecond' short form is the Greek small letter mu: 'μs'.
      if (microRemainder != 0)
        '$microRemainder ${shortForm ? 'μs' : 'microsecond'.pluralize(microRemainder, simple: true)}',
    ];
  }
}
