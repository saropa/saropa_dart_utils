import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/bucketed_aggregate_utils.dart';

void main() {
  group('bucketBy', () {
    test('groups by index parity', () {
      // keyOf returns even/odd of index: indices 0,2 -> 'even', 1,3 -> 'odd'.
      final Map<String, List<num>> result = bucketBy<String>(
        <num>[10, 20, 30, 40],
        (int i, num v) => i.isEven ? 'even' : 'odd',
      );
      expect(result['even'], <num>[10, 30]);
      expect(result['odd'], <num>[20, 40]);
    });

    test('groups by value', () {
      final Map<bool, List<num>> result = bucketBy<bool>(
        <num>[1, 2, 3, 4],
        (int i, num v) => v > 2,
      );
      expect(result[false], <num>[1, 2]);
      expect(result[true], <num>[3, 4]);
    });

    test('empty input returns empty map', () {
      expect(bucketBy<int>(<num>[], (int i, num v) => 0), isEmpty);
    });

    test('single element makes single bucket', () {
      final Map<int, List<num>> result = bucketBy<int>(<num>[5], (int i, num v) => 1);
      expect(result, <int, List<num>>{
        1: <num>[5],
      });
    });
  });

  group('bucketAggregate', () {
    final List<num> bucket = <num>[2, 4, 6, 8];

    test('sum', () => expect(bucketAggregate(bucket, 'sum'), 20.0));
    test('count', () => expect(bucketAggregate(bucket, 'count'), 4.0));
    test('avg', () => expect(bucketAggregate(bucket, 'avg'), 5.0));
    test('min', () => expect(bucketAggregate(bucket, 'min'), 2.0));
    test('max', () => expect(bucketAggregate(bucket, 'max'), 8.0));

    test('single element', () {
      expect(bucketAggregate(<num>[7], 'avg'), 7.0);
      expect(bucketAggregate(<num>[7], 'min'), 7.0);
      expect(bucketAggregate(<num>[7], 'max'), 7.0);
    });

    test('negative values for min/max', () {
      expect(bucketAggregate(<num>[-5, -1, -10], 'min'), -10.0);
      expect(bucketAggregate(<num>[-5, -1, -10], 'max'), -1.0);
    });

    test('empty bucket returns NaN', () {
      expect(bucketAggregate(<num>[], 'sum'), isNaN);
    });

    test('unknown aggregate returns NaN', () {
      expect(bucketAggregate(bucket, 'p99'), isNaN);
    });
  });
}
