import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/datetime/timeseries_gap_utils.dart';

void main() {
  group('findGaps', () {
    const Duration hourly = Duration(hours: 1);

    test('should find no gaps in an evenly spaced series', () {
      final List<({DateTime start, DateTime end})> gaps = findGaps(
        <DateTime>[
          DateTime(2026, 1, 1, 0),
          DateTime(2026, 1, 1, 1),
          DateTime(2026, 1, 1, 2),
        ],
        hourly,
      );

      expect(gaps, isEmpty);
    });

    test('should tolerate jitter within the tolerance band', () {
      // 1h20m is under the 1.5h threshold, so it is not a gap.
      final List<({DateTime start, DateTime end})> gaps = findGaps(
        <DateTime>[DateTime(2026, 1, 1, 0), DateTime(2026, 1, 1, 1, 20)],
        hourly,
      );

      expect(gaps, isEmpty);
    });

    test('should detect a single gap beyond the threshold', () {
      final List<({DateTime start, DateTime end})> gaps = findGaps(
        <DateTime>[DateTime(2026, 1, 1, 0), DateTime(2026, 1, 1, 3)],
        hourly,
      );

      expect(gaps.length, equals(1));
      expect(gaps.first.start, equals(DateTime(2026, 1, 1, 0)));
      expect(gaps.first.end, equals(DateTime(2026, 1, 1, 3)));
    });

    test('should detect multiple gaps and sort unordered input', () {
      final List<({DateTime start, DateTime end})> gaps = findGaps(
        <DateTime>[
          DateTime(2026, 1, 1, 5),
          DateTime(2026, 1, 1, 0),
          DateTime(2026, 1, 1, 1),
          DateTime(2026, 1, 1, 9),
        ],
        hourly,
      );

      expect(gaps.length, equals(2));
      expect(gaps[0].start, equals(DateTime(2026, 1, 1, 1)));
      expect(gaps[0].end, equals(DateTime(2026, 1, 1, 5)));
      expect(gaps[1].start, equals(DateTime(2026, 1, 1, 5)));
      expect(gaps[1].end, equals(DateTime(2026, 1, 1, 9)));
    });

    test('should return empty for a single sample', () {
      expect(findGaps(<DateTime>[DateTime(2026, 1, 1)], hourly), isEmpty);
    });

    test('should return empty for no samples', () {
      expect(findGaps(<DateTime>[], hourly), isEmpty);
    });
  });

  group('fillMissing', () {
    const Duration hourly = Duration(hours: 1);

    test('should build the complete regular grid from min to max', () {
      final List<DateTime> grid = fillMissing(
        <DateTime>[DateTime(2026, 1, 1, 0), DateTime(2026, 1, 1, 3)],
        hourly,
      );

      expect(
        grid,
        equals(<DateTime>[
          DateTime(2026, 1, 1, 0),
          DateTime(2026, 1, 1, 1),
          DateTime(2026, 1, 1, 2),
          DateTime(2026, 1, 1, 3),
        ]),
      );
    });

    test('should sort input before spanning the grid', () {
      final List<DateTime> grid = fillMissing(
        <DateTime>[DateTime(2026, 1, 1, 2), DateTime(2026, 1, 1, 0)],
        hourly,
      );

      expect(grid.length, equals(3));
      expect(grid.first, equals(DateTime(2026, 1, 1, 0)));
      expect(grid.last, equals(DateTime(2026, 1, 1, 2)));
    });

    test('should return a single sample unchanged', () {
      expect(
        fillMissing(<DateTime>[DateTime(2026, 1, 1)], hourly),
        equals(<DateTime>[DateTime(2026, 1, 1)]),
      );
    });

    test('should return empty for no samples', () {
      expect(fillMissing(<DateTime>[], hourly), isEmpty);
    });

    test('should return the input sorted for a zero/negative interval (no hang)', () {
      // A non-positive interval cannot advance the grid; the fill loop must NOT
      // spin forever. The samples come back sorted instead.
      final List<DateTime> input = <DateTime>[DateTime(2026, 1, 1, 3), DateTime(2026, 1, 1)];
      expect(
        fillMissing(input, Duration.zero),
        equals(<DateTime>[DateTime(2026, 1, 1), DateTime(2026, 1, 1, 3)]),
      );
    });
  });

  group('forwardFill', () {
    test('should carry the last non-null value forward', () {
      expect(
        forwardFill(<num?>[1, null, null, 3, null]),
        equals(<num?>[1, 1, 1, 3, 3]),
      );
    });

    test('should leave leading nulls null', () {
      expect(
        forwardFill(<num?>[null, null, 2, null]),
        equals(<num?>[null, null, 2, 2]),
      );
    });

    test('should return an empty list unchanged', () {
      expect(forwardFill(<num?>[]), isEmpty);
    });

    test('should pass through a fully populated list', () {
      expect(forwardFill(<num?>[1, 2, 3]), equals(<num?>[1, 2, 3]));
    });
  });
}
