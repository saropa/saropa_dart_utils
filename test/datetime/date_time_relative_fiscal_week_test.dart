import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_fiscal_extensions.dart';
import 'package:saropa_dart_utils/datetime/date_time_relative_utils.dart';
import 'package:saropa_dart_utils/datetime/date_time_week_extensions.dart';

void main() {
  group('relativeTimeString', () {
    test('just now when within minute', () {
      final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
      expect(relativeTimeString(now.subtract(const Duration(seconds: 30)), clock: now), 'just now');
    });
    test('hours ago', () {
      final DateTime now = DateTime(2024, 6, 15, 12, 0, 0);
      expect(
        relativeTimeString(now.subtract(const Duration(hours: 2)), clock: now),
        '2 hours ago',
      );
    });
  });
  group('fiscalYear', () {
    test('April start', () {
      expect(DateTime(2024, 6, 1).fiscalYear(startMonth: 4), 2024);
      expect(DateTime(2024, 2, 1).fiscalYear(startMonth: 4), 2023);
    });
  });
  group('toIsoWeekString', () {
    test('formats ISO week', () {
      final DateTime d = DateTime(2024, 1, 15); // week 3
      expect(d.toIsoWeekString, '2024-W03');
    });
  });
  group('parseIsoWeekString', () {
    test('parses to Monday', () {
      final DateTime? m = parseIsoWeekString('2024-W03');
      expect(m != null, isTrue);
      expect(m!.weekday, DateTime.monday);
    });

    test('rejects a week the year does not have (2025 has 52 ISO weeks)', () {
      // 2025-W53 is invalid: its Monday (2025-12-29) stays in 2025 but its
      // Thursday lands in 2026, so the week belongs to 2026-W01, not 2025.
      expect(parseIsoWeekString('2025-W53'), isNull);
    });

    test('accepts week 53 in a year that actually has it (2026)', () {
      // 2026 starts on a Thursday, so it has 53 ISO weeks.
      expect(parseIsoWeekString('2026-W53'), isNotNull);
    });
  });
}
