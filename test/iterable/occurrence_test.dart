import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/occurrence.dart';

void main() {
  group('Occurrence', () {
    test('constructor stores value and count', () {
      const Occurrence<String> occ = Occurrence<String>('apple', 3);
      expect(occ.value, 'apple');
      expect(occ.count, 3);
    });

    test('== is true for equal value and count', () {
      expect(
        const Occurrence<int>(5, 2),
        equals(const Occurrence<int>(5, 2)),
      );
    });

    test('== is false when value differs', () {
      expect(const Occurrence<int>(5, 2) == const Occurrence<int>(6, 2), isFalse);
    });

    test('== is false when count differs', () {
      expect(const Occurrence<int>(5, 2) == const Occurrence<int>(5, 3), isFalse);
    });

    test('identical instance equals itself', () {
      const Occurrence<int> occ = Occurrence<int>(1, 1);
      expect(occ == occ, isTrue);
    });

    test('hashCode is equal for equal occurrences', () {
      expect(
        const Occurrence<int>(5, 2).hashCode,
        const Occurrence<int>(5, 2).hashCode,
      );
    });

    test('toString renders value and count', () {
      expect(const Occurrence<String>('x', 4).toString(), 'Occurrence(x, 4)');
    });

    test('works as a Map key (value-based equality)', () {
      final Map<Occurrence<int>, String> map = <Occurrence<int>, String>{
        const Occurrence<int>(1, 1): 'one',
      };
      expect(map[const Occurrence<int>(1, 1)], 'one');
    });
  });
}
