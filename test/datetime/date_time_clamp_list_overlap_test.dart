import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/date_time_clamp_extensions.dart';
import 'package:saropa_dart_utils/datetime/date_time_list_extensions.dart';
import 'package:saropa_dart_utils/datetime/date_time_overlap_utils.dart';

void main() {
  group('clampTo', () {
    test('clamps to range', () {
      final DateTime min = DateTime(2024, 1, 1);
      final DateTime max = DateTime(2024, 12, 31);
      final DateTime d = DateTime(2024, 6, 15);
      expect(d.clampTo(min, max), d);
      expect(DateTime(2023, 1, 1).clampTo(min, max), min);
      expect(DateTime(2025, 1, 1).clampTo(min, max), max);
    });
  });
  group('minOrNull maxOrNull', () {
    test('min and max of list', () {
      final DateTime a = DateTime(2024, 1, 1);
      final DateTime b = DateTime(2024, 6, 1);
      expect(<DateTime>[b, a].minOrNull, a);
      expect(<DateTime>[b, a].maxOrNull, b);
      expect(<DateTime>[].minOrNull, isNull);
    });
  });
  group('dateRange', () {
    test('generates range', () {
      final DateTime start = DateTime(2024, 6, 1);
      final DateTime end = DateTime(2024, 6, 3);
      expect(dateRange(start, end).toList(), hasLength(3));
    });
  });
  group('dateRangeOverlap', () {
    test('overlap exists', () {
      final (DateTime start, DateTime end)? r = dateRangeOverlap(
        DateTime(2024, 1, 1),
        DateTime(2024, 6, 1),
        DateTime(2024, 3, 1),
        DateTime(2024, 12, 1),
      );
      expect(r != null, isTrue);
      final (DateTime start, DateTime end) = r!;
      expect(start, DateTime(2024, 3, 1));
      expect(end, DateTime(2024, 6, 1));
    });
    test('no overlap', () {
      expect(
        dateRangeOverlap(
          DateTime(2024, 1, 1),
          DateTime(2024, 2, 1),
          DateTime(2024, 3, 1),
          DateTime(2024, 4, 1),
        ),
        isNull,
      );
    });
  });
}
