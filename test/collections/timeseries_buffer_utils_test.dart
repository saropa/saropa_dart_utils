import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/timeseries_buffer_utils.dart';

void main() {
  group('TimeSeriesBuffer', () {
    test('should keep all points while under capacity', () {
      final TimeSeriesBuffer b = TimeSeriesBuffer(rawCapacity: 3, bucketSizeMs: 1000)
        ..add(0, 10)
        ..add(100, 20);

      expect(b.raw.length, equals(2));
      expect(b.aggregates, isEmpty);
    });

    test('should evict the oldest point into a bucket when over capacity', () {
      final TimeSeriesBuffer b = TimeSeriesBuffer(rawCapacity: 2, bucketSizeMs: 1000)
        ..add(0, 10)
        ..add(500, 20)
        ..add(1500, 30); // pushes (0, 10) out into the [0, 1000) bucket

      expect(b.raw.map((RawPoint p) => p.t), equals(<int>[500, 1500]));
      expect(b.aggregates.length, equals(1));
      expect(b.aggregates.first.startMs, equals(0));
      expect(b.aggregates.first.count, equals(1));
      expect(b.aggregates.first.mean, equals(10));
    });

    test('should fold several evictions into the same bucket', () {
      final TimeSeriesBuffer b = TimeSeriesBuffer(rawCapacity: 1, bucketSizeMs: 1000)
        ..add(100, 4)
        ..add(200, 6) // evicts (100, 4)
        ..add(300, 8) // evicts (200, 6)
        ..add(1500, 99); // evicts (300, 8); all three land in [0, 1000)

      final TimeBucket bucket = b.aggregates.first;
      expect(bucket.count, equals(3));
      expect(bucket.sum, equals(18));
      expect(bucket.min, equals(4));
      expect(bucket.max, equals(8));
      expect(bucket.mean, equals(6));
    });

    test('should order aggregates by bucket start time', () {
      final TimeSeriesBuffer b = TimeSeriesBuffer(rawCapacity: 1, bucketSizeMs: 100);
      // Add across three buckets; each add but the last evicts the prior point.
      for (final int t in <int>[50, 150, 250, 1000]) {
        b.add(t, t);
      }

      expect(
        b.aggregates.map((TimeBucket x) => x.startMs),
        equals(<int>[0, 100, 200]),
      );
    });

    test('should expose raw as an unmodifiable snapshot', () {
      final TimeSeriesBuffer b = TimeSeriesBuffer(rawCapacity: 2, bucketSizeMs: 1000)..add(0, 1);

      expect(() => b.raw.add((t: 1, v: 2)), throwsUnsupportedError);
    });

    test('should assert on non-positive configuration', () {
      expect(
        () => TimeSeriesBuffer(rawCapacity: 0, bucketSizeMs: 1000),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => TimeSeriesBuffer(rawCapacity: 1, bucketSizeMs: 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
