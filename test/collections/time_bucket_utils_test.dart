import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/time_bucket_utils.dart';

void main() {
  group('bucketByTime', () {
    test('should count events per fixed time bucket', () {
      final DateTime base = DateTime.fromMillisecondsSinceEpoch(0);
      final List<DateTime> events = [
        base, // bucket 0
        base.add(const Duration(seconds: 30)), // bucket 0
        base.add(const Duration(minutes: 1)), // bucket 1
        base.add(const Duration(minutes: 1, seconds: 30)), // bucket 1
        base.add(const Duration(minutes: 2)), // bucket 2
      ];
      final Map<DateTime, int> result = bucketByTime(events, const Duration(minutes: 1));
      expect(result[base], 2);
      expect(result[base.add(const Duration(minutes: 1))], 1 + 1);
      expect(result[base.add(const Duration(minutes: 2))], 1);
      expect(result, hasLength(3));
    });

    test('should return empty map for no events', () {
      expect(bucketByTime(<DateTime>[], const Duration(minutes: 1)), <DateTime, int>{});
    });

    test('should align bucket keys to the bucket start', () {
      // An event 30s into a 60s bucket should key on the bucket start (t=0).
      final DateTime base = DateTime.fromMillisecondsSinceEpoch(0);
      final List<DateTime> events = [base.add(const Duration(seconds: 30))];
      final Map<DateTime, int> result = bucketByTime(events, const Duration(minutes: 1));
      expect(result.keys.single, base);
    });

    test('should put all events in one bucket when bucket is large', () {
      final DateTime base = DateTime.fromMillisecondsSinceEpoch(0);
      final List<DateTime> events = [
        base,
        base.add(const Duration(hours: 1)),
        base.add(const Duration(hours: 2)),
      ];
      final Map<DateTime, int> result = bucketByTime(events, const Duration(days: 1));
      expect(result, hasLength(1));
      expect(result.values.single, 3);
    });

    test('should count a single event', () {
      final DateTime base = DateTime.fromMillisecondsSinceEpoch(0);
      final Map<DateTime, int> result = bucketByTime([base], const Duration(minutes: 5));
      expect(result, {base: 1});
    });

    test('should floor-bucket negative (pre-1970) epoch timestamps', () {
      // A point at -1 ms with a 1000 ms bucket belongs to [-1000, 0), not [0,
      // 1000). Truncating division (~/) would wrongly land it in bucket 0.
      final DateTime preEpoch = DateTime.fromMillisecondsSinceEpoch(-1);
      final Map<DateTime, int> result = bucketByTime([preEpoch], const Duration(seconds: 1));
      expect(result.keys.single, DateTime.fromMillisecondsSinceEpoch(-1000));
    });

    test('should return empty for a non-positive bucket width', () {
      final DateTime base = DateTime.fromMillisecondsSinceEpoch(0);
      expect(bucketByTime([base], Duration.zero), isEmpty);
    });
  });
}
