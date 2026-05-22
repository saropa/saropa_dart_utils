import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/feature_encoding_utils.dart';

void main() {
  group('oneHot', () {
    test('marks the matching category', () {
      expect(oneHot('b', <Object?>['a', 'b', 'c']), <int>[0, 1, 0]);
    });

    test('value absent from categories yields all zeros', () {
      expect(oneHot('z', <Object?>['a', 'b', 'c']), <int>[0, 0, 0]);
    });

    test('null value matches a null category', () {
      expect(oneHot(null, <Object?>['a', null, 'c']), <int>[0, 1, 0]);
    });

    test('repeated category sets every match', () {
      expect(oneHot('a', <Object?>['a', 'a', 'b']), <int>[1, 1, 0]);
    });

    test('empty categories returns empty list', () {
      expect(oneHot('a', <Object?>[]), isEmpty);
    });

    test('numeric categories', () {
      expect(oneHot(2, <Object?>[1, 2, 3]), <int>[0, 1, 0]);
    });
  });

  group('bucketize', () {
    final List<num> edges = <num>[0, 10, 20];

    test('value below first edge -> bin 0', () {
      expect(bucketize(-5, edges), 0);
    });

    test('value between edges', () {
      // 5 < 10 so bin index 1 (first edge it is below).
      expect(bucketize(5, edges), 1);
      // 15 < 20 -> bin 2.
      expect(bucketize(15, edges), 2);
    });

    test('value at or above last edge -> edges.length', () {
      expect(bucketize(20, edges), 3);
      expect(bucketize(100, edges), 3);
    });

    test('value equal to an edge falls into the next bucket', () {
      // 10 is not < 10, but is < 20 -> bin 2.
      expect(bucketize(10, edges), 2);
    });

    test('empty edges always returns 0', () {
      expect(bucketize(5, <num>[]), 0);
    });
  });
}
