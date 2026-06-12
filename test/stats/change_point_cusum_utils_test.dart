import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/change_point_cusum_utils.dart';

void main() {
  group('cusumChangePoints', () {
    test('flat constant series reports no change points', () {
      // Every value equals the mean, so neither sum ever accumulates.
      expect(
        cusumChangePoints(<num>[5, 5, 5, 5, 5], threshold: 1),
        isEmpty,
      );
    });

    test('a clear step change is detected around the transition', () {
      // First half sits well below the mean, second half well above; the
      // two-sided scan flags both the low run and the high run after the step.
      final List<int> points = cusumChangePoints(
        <num>[0, 0, 0, 0, 10, 10, 10, 10],
        threshold: 5,
      );
      expect(points, isNotEmpty);
      // At least one detection lands at or after the step boundary (index 4),
      // confirming the upward shift is caught.
      expect(points.any((int i) => i >= 4), isTrue);
    });

    test('a higher threshold yields fewer detections', () {
      final List<num> series = <num>[0, 0, 0, 10, 10, 10, 0, 0, 0, 10, 10, 10];
      final int low = cusumChangePoints(series, threshold: 3).length;
      final int high = cusumChangePoints(series, threshold: 20).length;
      expect(high, lessThanOrEqualTo(low));
    });

    test('drift slack suppresses small noise', () {
      // Tiny alternating deviations stay within the drift allowance.
      final List<int> points = cusumChangePoints(
        <num>[0, 1, 0, 1, 0, 1],
        threshold: 5,
        drift: 2,
      );
      expect(points, isEmpty);
    });

    test('empty series returns empty', () {
      expect(cusumChangePoints(<num>[], threshold: 1), isEmpty);
    });

    test('single element returns empty', () {
      expect(cusumChangePoints(<num>[42], threshold: 1), isEmpty);
    });
  });
}
