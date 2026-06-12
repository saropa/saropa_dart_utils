import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/calendar_heatmap_utils.dart';

void main() {
  group('dailyCounts', () {
    test('should aggregate multiple events on the same day, ignoring time', () {
      final Map<DateTime, int> counts = dailyCounts(<DateTime>[
        DateTime(2026, 3, 1, 9),
        DateTime(2026, 3, 1, 23, 59),
        DateTime(2026, 3, 2, 0, 1),
      ]);

      expect(counts[DateTime(2026, 3, 1)], equals(2));
      expect(counts[DateTime(2026, 3, 2)], equals(1));
    });

    test('should return an empty map for no events', () {
      expect(dailyCounts(<DateTime>[]), isEmpty);
    });
  });

  group('heatmapGrid', () {
    test('should build a single Monday-aligned week of length 7', () {
      final Map<DateTime, int> daily = dailyCounts(<DateTime>[DateTime(2026, 3, 3)]);

      // 2026-03-02 is a Monday; the week runs Mon..Sun.
      final List<List<int>> grid = heatmapGrid(
        daily,
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 8),
      );

      expect(grid.length, equals(1));
      expect(grid.first.length, equals(7));
      // Tuesday (index 1) carries the single event.
      expect(grid.first, equals(<int>[0, 1, 0, 0, 0, 0, 0]));
    });

    test('should back-pad a partial first week to the week start', () {
      // 2026-03-04 is a Wednesday; the row still begins on the prior Monday.
      final List<List<int>> grid = heatmapGrid(
        <DateTime, int>{},
        DateTime(2026, 3, 4),
        DateTime(2026, 3, 8),
      );

      expect(grid.length, equals(1));
      expect(grid.first.length, equals(7));
      // Days before start (Mon, Tue) are padded 0 along with the rest.
      expect(grid.first, equals(<int>[0, 0, 0, 0, 0, 0, 0]));
    });

    test('should span multiple weeks and keep every row length 7', () {
      final List<List<int>> grid = heatmapGrid(
        <DateTime, int>{},
        DateTime(2026, 3, 2),
        DateTime(2026, 3, 20),
      );

      expect(grid.length, equals(3));
      for (final List<int> week in grid) {
        expect(week.length, equals(7));
      }
    });

    test('should respect a Sunday week start', () {
      final Map<DateTime, int> daily = dailyCounts(<DateTime>[DateTime(2026, 3, 1)]);

      // 2026-03-01 is a Sunday; with weekStartsOn Sunday it is index 0.
      final List<List<int>> grid = heatmapGrid(
        daily,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 7),
        weekStartsOn: DateTime.sunday,
      );

      expect(grid.length, equals(1));
      expect(grid.first, equals(<int>[1, 0, 0, 0, 0, 0, 0]));
    });
  });

  group('heatmapStats', () {
    test('should compute max, total, and active days', () {
      final Map<DateTime, int> daily = <DateTime, int>{
        DateTime(2026, 3, 1): 2,
        DateTime(2026, 3, 2): 5,
        DateTime(2026, 3, 3): 0,
      };

      final ({int maxCount, int total, int activeDays}) stats = heatmapStats(daily);

      expect(stats.maxCount, equals(5));
      expect(stats.total, equals(7));
      // The stored 0 is not an active day.
      expect(stats.activeDays, equals(2));
    });

    test('should return zeros for an empty map', () {
      final ({int maxCount, int total, int activeDays}) stats = heatmapStats(<DateTime, int>{});

      expect(stats.maxCount, equals(0));
      expect(stats.total, equals(0));
      expect(stats.activeDays, equals(0));
    });
  });
}
