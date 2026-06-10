import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_bounds_extensions.dart';

void main() {
  // 2026-01-01 is a Thursday — used as a fixed reference.
  final DateTime thursday = DateTime(2026, 1, 1, 9, 30);

  group('startOfWeek', () {
    test('returns the Monday of the week by default', () {
      final DateTime start = thursday.startOfWeek();
      expect(start.weekday, DateTime.monday);
      expect(start.isAfter(thursday), isFalse);
    });

    test('honors a custom first weekday', () {
      expect(thursday.startOfWeek(firstWeekday: DateTime.sunday).weekday, DateTime.sunday);
    });
  });

  group('endOfWeek', () {
    test('returns the Sunday of the week by default', () {
      expect(thursday.endOfWeek().weekday, DateTime.sunday);
    });

    test('end of week is after start of week', () {
      expect(thursday.endOfWeek().isAfter(thursday.startOfWeek()), isTrue);
    });
  });

  group('sameTimeOn', () {
    test('keeps the receiver date but takes the other time-of-day', () {
      final DateTime result = DateTime(2026, 1, 1).sameTimeOn(DateTime(2026, 6, 15, 14, 45));
      expect(result.year, 2026);
      expect(result.month, 1);
      expect(result.day, 1);
      expect(result.hour, 14);
      expect(result.minute, 45);
    });
  });
}
