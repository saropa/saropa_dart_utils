import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/duration_clock_format_extensions.dart';

void main() {
  group('DurationClockFormatExtensions', () {
    group('displayTime', () {
      // --- Spec sample tests (verbatim expectations) ---
      test('should format correctly with hours', () {
        const Duration duration = Duration(hours: 1, minutes: 30, seconds: 45, milliseconds: 123);
        expect(duration.displayTime(), '01:30:45.123');
      });

      test('should format correctly without hours', () {
        const Duration duration = Duration(minutes: 5, seconds: 30, milliseconds: 50);
        expect(duration.displayTime(showHours: false), '05:30.050');
      });

      // --- Bulletproofing: zero ---
      test('should render all-zero with hours', () {
        expect(Duration.zero.displayTime(), '00:00:00.000');
      });

      test('should render all-zero without hours', () {
        expect(Duration.zero.displayTime(showHours: false), '00:00.000');
      });

      // --- Bulletproofing: hours never roll into days ---
      test('should keep hours past a full day un-modded', () {
        expect(const Duration(hours: 25, minutes: 1).displayTime(), '25:01:00.000');
      });

      test('should render triple-digit hours without truncation', () {
        expect(const Duration(hours: 100).displayTime(), '100:00:00.000');
      });

      // --- Bulletproofing: negative durations (the sharp edge) ---
      // Dart's % returns a non-negative result for a positive divisor, so the
      // seconds component wraps (-5 % 60 == 55) instead of showing a sign.
      test('should wrap negative seconds via non-negative modulo', () {
        expect(const Duration(seconds: -5).displayTime(), '00:00:55.000');
      });

      // --- Bulletproofing: millisecond boundary and carry ---
      test('should render the 999ms boundary', () {
        expect(const Duration(milliseconds: 999).displayTime(), '00:00:00.999');
      });

      test('should carry 1000ms into one second', () {
        expect(const Duration(milliseconds: 1000).displayTime(), '00:00:01.000');
      });

      // --- Bulletproofing: sub-millisecond input is dropped ---
      test('should drop sub-millisecond microseconds', () {
        expect(const Duration(microseconds: 500).displayTime(), '00:00:00.000');
      });

      // --- Bulletproofing: exact 60s / 60min carry ---
      test('should carry 60 seconds into one minute', () {
        expect(const Duration(seconds: 60).displayTime(), '00:01:00.000');
      });

      test('should carry 60 minutes into one hour', () {
        expect(const Duration(minutes: 60).displayTime(), '01:00:00.000');
      });
    });

    group('formatDuration', () {
      // --- Spec sample tests ---
      test('should return Instantaneous for zero', () {
        expect(Duration.zero.formatDuration(), 'Instantaneous');
      });

      test('should format hours and minutes', () {
        const Duration duration = Duration(hours: 2, minutes: 30);
        final String? result = duration.formatDuration();
        expect(result, contains('2 hrs'));
        expect(result, contains('30 mins'));
      });

      test('should format milliseconds', () {
        const Duration duration = Duration(milliseconds: 137);
        expect(duration.formatDuration(), contains('137 ms'));
      });

      test('should format microseconds', () {
        const Duration duration = Duration(microseconds: 456);
        expect(duration.formatDuration(), contains('456'));
      });

      // --- Bulletproofing: each unit in isolation (short form) ---
      test('should format hours-only', () {
        expect(const Duration(hours: 3).formatDuration(), '3 hrs');
      });

      test('should format minutes-only', () {
        expect(const Duration(minutes: 7).formatDuration(), '7 mins');
      });

      test('should format seconds-only', () {
        expect(const Duration(seconds: 9).formatDuration(), '9 secs');
      });

      test('should format milliseconds-only', () {
        expect(const Duration(milliseconds: 250).formatDuration(), '250 ms');
      });

      test('should format microseconds-only', () {
        expect(const Duration(microseconds: 42).formatDuration(), '42 μs');
      });

      // --- Bulletproofing: full stack with exact join + field order ---
      test('should join all five units in descending order', () {
        const Duration duration = Duration(
          hours: 1,
          minutes: 2,
          seconds: 3,
          milliseconds: 4,
          microseconds: 5,
        );
        expect(duration.formatDuration(), '1 hr, 2 mins, 3 secs, 4 ms, 5 μs');
      });

      // --- Bulletproofing: long-word pluralization at 1 vs N ---
      test('should use singular long words at exactly one', () {
        const Duration duration = Duration(
          hours: 1,
          minutes: 1,
          seconds: 1,
          milliseconds: 1,
          microseconds: 1,
        );
        expect(
          duration.formatDuration(shortForm: false),
          '1 hour, 1 minute, 1 second, 1 millisecond, 1 microsecond',
        );
      });

      test('should use plural long words above one', () {
        const Duration duration = Duration(
          hours: 2,
          minutes: 3,
          seconds: 4,
          milliseconds: 5,
          microseconds: 6,
        );
        expect(
          duration.formatDuration(shortForm: false),
          '2 hours, 3 minutes, 4 seconds, 5 milliseconds, 6 microseconds',
        );
      });

      // --- Bulletproofing: leading zeros toggle ---
      test('should omit leading zeros by default', () {
        expect(const Duration(minutes: 5).formatDuration(), '5 mins');
      });

      test('should pad leading zeros when requested', () {
        expect(
          const Duration(minutes: 5).formatDuration(showLeadingZeros: true),
          '05 mins',
        );
      });

      // --- Bulletproofing: singular boundaries short vs long ---
      test('should give singular short hr at exactly one', () {
        expect(const Duration(hours: 1).formatDuration(), '1 hr');
      });

      test('should give singular long hour at exactly one', () {
        expect(const Duration(hours: 1).formatDuration(shortForm: false), '1 hour');
      });

      // --- Bulletproofing: zero-valued interior unit is skipped ---
      test('should skip a zero minutes component', () {
        expect(const Duration(hours: 1, seconds: 3).formatDuration(), '1 hr, 3 secs');
      });

      // --- Bulletproofing: negative leaks the sign into each unit ---
      // remainder() preserves sign, so both components stay negative; pluralize
      // appends 's' for any count != 1, hence 'mins' not 'min'.
      test('should leak the sign into each unit for negative durations', () {
        expect(const Duration(seconds: -90).formatDuration(), '-1 mins, -30 secs');
      });

      // --- Bulletproofing: extremes ---
      test('should not roll days up — large hours count', () {
        expect(const Duration(days: 10000).formatDuration(), '240000 hrs');
      });

      test('should format a near-max-microsecond duration without throwing', () {
        // Large but within int range; arithmetic must not overflow or throw.
        const Duration huge = Duration(microseconds: 9007199254740991);
        expect(huge.formatDuration(), isNotEmpty);
      });

      // --- Bulletproofing: zero ignores both flags ---
      test('should return Instantaneous regardless of flags', () {
        expect(
          Duration.zero.formatDuration(showLeadingZeros: true, shortForm: false),
          'Instantaneous',
        );
      });

      // --- Bulletproofing: unicode glyph guard for the mu short form ---
      test('should preserve the Greek mu glyph, not ASCII-flatten it', () {
        expect(const Duration(microseconds: 2).formatDuration(), contains('μs'));
      });
    });

    group('reverse', () {
      // --- Spec sample test ---
      test('should negate a positive duration', () {
        expect(const Duration(hours: 1).reverse().inHours, -1);
      });

      // --- Bulletproofing ---
      test('should leave zero as zero (no negative-zero surprise)', () {
        expect(Duration.zero.reverse(), Duration.zero);
      });

      test('should negate a negative duration back to positive', () {
        expect(const Duration(hours: -1).reverse().inHours, 1);
      });

      test('should be the identity when applied twice', () {
        const Duration d = Duration(hours: 3, minutes: 17, seconds: 9);
        expect(d.reverse().reverse(), d);
      });

      test('should negate a very large duration without overflow', () {
        const Duration big = Duration(microseconds: 4503599627370495);
        expect(big.reverse(), const Duration(microseconds: -4503599627370495));
      });
    });

    // --- Cross-cutting note: locale/DST/leap-year are N/A for Duration ---
    // These formatters operate on Duration fields (pure integer arithmetic),
    // not wall-clock DateTime, so there is no calendar/timezone surface to
    // test. The only non-ASCII output is the microsecond mu glyph, guarded
    // above. The receiver is a non-null Duration, so there are no null/empty
    // input cases either.
  });
}
