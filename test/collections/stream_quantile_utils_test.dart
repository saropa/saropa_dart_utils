import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/stream_quantile_utils.dart';

void main() {
  group('StreamQuantileUtils', () {
    group('p getter', () {
      test('should expose the target quantile', () {
        expect(StreamQuantileUtils(0.5).p, 0.5);
        expect(StreamQuantileUtils(0.9).p, 0.9);
      });
    });

    group('quantile', () {
      test('should return NaN before any value', () {
        expect(StreamQuantileUtils(0.5).quantile.isNaN, isTrue);
      });

      test('should return the median for p = 0.5', () {
        final StreamQuantileUtils q = StreamQuantileUtils(0.5);
        for (final num v in [1, 2, 3, 4, 5]) {
          q.add(v);
        }
        // sorted [1,2,3,4,5]; index = round(0.5*4)=2 -> 3.
        expect(q.quantile, 3.0);
      });

      test('should return the minimum for p = 0', () {
        final StreamQuantileUtils q = StreamQuantileUtils(0)
          ..add(5)
          ..add(1)
          ..add(3);
        expect(q.quantile, 1.0);
      });

      test('should return the maximum for p = 1', () {
        final StreamQuantileUtils q = StreamQuantileUtils(1)
          ..add(5)
          ..add(1)
          ..add(3);
        expect(q.quantile, 5.0);
      });

      test('should return the only value for a single sample', () {
        final StreamQuantileUtils q = StreamQuantileUtils(0.5)..add(42);
        expect(q.quantile, 42.0);
      });

      test('should be order-independent (sorts internally)', () {
        final StreamQuantileUtils ascending = StreamQuantileUtils(0.5)
          ..add(1)
          ..add(2)
          ..add(3);
        final StreamQuantileUtils descending = StreamQuantileUtils(0.5)
          ..add(3)
          ..add(2)
          ..add(1);
        expect(ascending.quantile, descending.quantile);
      });

      test('should estimate a high percentile', () {
        final StreamQuantileUtils q = StreamQuantileUtils(0.9);
        for (int i = 1; i <= 10; i++) {
          q.add(i);
        }
        // sorted 1..10; index = round(0.9*9)=8 -> value 9.
        expect(q.quantile, 9.0);
      });
    });

    group('toString', () {
      test('should include p and count', () {
        final StreamQuantileUtils q = StreamQuantileUtils(0.5)..add(1);
        expect(q.toString(), 'StreamQuantileUtils(p: 0.5, count: 1)');
      });
    });
  });
}
