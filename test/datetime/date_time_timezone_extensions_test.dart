// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_timezone_extensions.dart';

void main() {
  group('DateTimeTimezoneOffsetExtensions', () {
    group('timeZoneOffsetString', () {
      test('UTC instant yields +00:00 (timezone-independent)', () {
        // UTC DateTime always reports a zero offset regardless of the host
        // machine's local timezone, keeping this assertion deterministic.
        expect(DateTime.utc(2023, 6, 15, 12).timeZoneOffsetString, '+00:00');
      });

      test('local instant produces a sign and zero-padded HH:MM format', () {
        // The exact local offset is environment-dependent, so assert the shape
        // rather than a fixed value: leading +/-, two-digit hours, two-digit
        // minutes separated by a colon.
        final String result = DateTime(2023, 6, 15, 12).timeZoneOffsetString;
        expect(result, matches(RegExp(r'^[+-]\d{2}:\d{2}$')));
      });
    });
  });
}
