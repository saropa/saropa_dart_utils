import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/session_clustering_utils.dart';

void main() {
  // A tiny event type so the timestamp accessor is exercised, not just identity.
  DateTime at(int minute) => DateTime(2026, 1, 1, 0, minute);

  group('clusterIntoSessions', () {
    const Duration gap = Duration(minutes: 30);

    test('should return no sessions for empty input', () {
      expect(
        clusterIntoSessions<DateTime>(
          <DateTime>[],
          timestamp: (DateTime d) => d,
          maxGap: gap,
        ),
        isEmpty,
      );
    });

    test('should return one single-item session for one item', () {
      final List<List<DateTime>> result = clusterIntoSessions<DateTime>(
        <DateTime>[at(5)],
        timestamp: (DateTime d) => d,
        maxGap: gap,
      );

      expect(result, hasLength(1));
      expect(result.first, equals(<DateTime>[at(5)]));
    });

    test('should keep all items within the gap in a single session', () {
      final List<DateTime> items = <DateTime>[at(0), at(10), at(25), at(50)];

      final List<List<DateTime>> result = clusterIntoSessions<DateTime>(
        items,
        timestamp: (DateTime d) => d,
        maxGap: gap,
      );

      expect(result, hasLength(1));
      expect(result.first, hasLength(4));
    });

    test('should split into a new session when the gap is exceeded', () {
      // 0..25 are within 30 min of each other; 90 jumps a 65-min gap.
      final List<DateTime> items = <DateTime>[at(0), at(25), at(90), at(100)];

      final List<List<DateTime>> result = clusterIntoSessions<DateTime>(
        items,
        timestamp: (DateTime d) => d,
        maxGap: gap,
      );

      expect(result, hasLength(2));
      expect(result.first, equals(<DateTime>[at(0), at(25)]));
      expect(result.last, equals(<DateTime>[at(90), at(100)]));
    });

    test('should treat a gap exactly equal to maxGap as the same session', () {
      // A 30-min gap does not EXCEED maxGap, so it stays in one session.
      final List<DateTime> items = <DateTime>[at(0), at(30)];

      final List<List<DateTime>> result = clusterIntoSessions<DateTime>(
        items,
        timestamp: (DateTime d) => d,
        maxGap: gap,
      );

      expect(result, hasLength(1));
    });

    test('should keep items with equal timestamps in the same session', () {
      final List<DateTime> items = <DateTime>[at(5), at(5), at(5)];

      final List<List<DateTime>> result = clusterIntoSessions<DateTime>(
        items,
        timestamp: (DateTime d) => d,
        maxGap: gap,
      );

      expect(result, hasLength(1));
      expect(result.first, hasLength(3));
    });

    test('should sort unsorted input before sessionizing', () {
      final List<DateTime> items = <DateTime>[at(100), at(0), at(90), at(25)];

      final List<List<DateTime>> result = clusterIntoSessions<DateTime>(
        items,
        timestamp: (DateTime d) => d,
        maxGap: gap,
      );

      // Same data as the split test but shuffled — must produce the same split.
      expect(result, hasLength(2));
      expect(result.first, equals(<DateTime>[at(0), at(25)]));
      expect(result.last, equals(<DateTime>[at(90), at(100)]));
    });

    test('should match a brute-force oracle over a generated timeline', () {
      // Build minutes with deterministic gaps, then compare the grouping to a
      // straightforward linear-scan reference implementation.
      final List<int> minutes = <int>[0, 5, 12, 60, 61, 200, 205, 206, 240];
      final List<DateTime> items = minutes.map(at).toList();

      final List<List<DateTime>> result = clusterIntoSessions<DateTime>(
        items,
        timestamp: (DateTime d) => d,
        maxGap: gap,
      );

      // Oracle: walk sorted minutes, new group when delta > 30.
      final List<List<int>> oracle = <List<int>>[];
      List<int> current = <int>[minutes.first];
      oracle.add(current);
      for (int i = 1; i < minutes.length; i++) {
        if (minutes[i] - minutes[i - 1] > 30) {
          current = <int>[minutes[i]];
          oracle.add(current);
        } else {
          current.add(minutes[i]);
        }
      }

      // Map each DateTime back to elapsed minutes from the base; d.minute would
      // wrap at 60 (minute-of-hour) and misrepresent timestamps like at(60).
      final List<List<int>> resultMinutes = result
          .map(
            (List<DateTime> s) => s.map((DateTime d) => d.difference(at(0)).inMinutes).toList(),
          )
          .toList();
      expect(resultMinutes, equals(oracle));
    });
  });

  group('sessionsWithBounds', () {
    const Duration gap = Duration(minutes: 30);

    test('should return no sessions for empty input', () {
      expect(
        sessionsWithBounds<DateTime>(
          <DateTime>[],
          timestamp: (DateTime d) => d,
          maxGap: gap,
        ),
        isEmpty,
      );
    });

    test('should give equal start and end for a single-item session', () {
      final List<({DateTime start, DateTime end, List<DateTime> items})> result =
          sessionsWithBounds<DateTime>(
            <DateTime>[at(7)],
            timestamp: (DateTime d) => d,
            maxGap: gap,
          );

      expect(result, hasLength(1));
      expect(result.first.start, equals(at(7)));
      expect(result.first.end, equals(at(7)));
    });

    test('should report earliest and latest timestamps per session', () {
      final List<DateTime> items = <DateTime>[at(0), at(25), at(90), at(100)];

      final List<({DateTime start, DateTime end, List<DateTime> items})> result =
          sessionsWithBounds<DateTime>(
            items,
            timestamp: (DateTime d) => d,
            maxGap: gap,
          );

      expect(result, hasLength(2));
      expect(result.first.start, equals(at(0)));
      expect(result.first.end, equals(at(25)));
      expect(result.last.start, equals(at(90)));
      expect(result.last.end, equals(at(100)));
      expect(result.last.items, hasLength(2));
    });
  });
}
