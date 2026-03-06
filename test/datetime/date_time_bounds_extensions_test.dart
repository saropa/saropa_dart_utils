import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_bounds_extensions.dart';

void main() {
  group('startOfDay', () {
    test('strips time', () {
      final DateTime d = DateTime(2024, 6, 15, 14, 30);
      expect(d.startOfDay, DateTime(2024, 6, 15));
    });
  });
  group('endOfDay', () {
    test('last moment of day', () {
      final DateTime d = DateTime(2024, 6, 15);
      expect(d.endOfDay, DateTime(2024, 6, 15, 23, 59, 59, 999, 999));
    });
  });
  group('quarter', () {
    test('Q1–Q4', () {
      expect(DateTime(2024, 1, 1).quarter, 1);
      expect(DateTime(2024, 4, 1).quarter, 2);
      expect(DateTime(2024, 7, 1).quarter, 3);
      expect(DateTime(2024, 10, 1).quarter, 4);
    });
  });
  group('isWeekend', () {
    test('Saturday and Sunday', () {
      expect(DateTime(2024, 6, 15).isWeekend, isTrue); // Sat
      expect(DateTime(2024, 6, 16).isWeekend, isTrue); // Sun
      expect(DateTime(2024, 6, 17).isWeekend, isFalse);
    });
  });
  group('nextWeekday', () {
    test('skips to Monday from Saturday', () {
      final DateTime sat = DateTime(2024, 6, 15);
      expect(sat.nextWeekday(), DateTime(2024, 6, 17));
    });
  });
  group('startOfMonth endOfMonth', () {
    test('bounds', () {
      final DateTime d = DateTime(2024, 6, 15);
      expect(d.startOfMonth, DateTime(2024, 6));
      expect(d.endOfMonth.day, 30);
    });
  });
}
