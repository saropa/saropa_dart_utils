import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/quickselect_utils.dart';

int _asc(int a, int b) => a.compareTo(b);

void main() {
  group('nthSmallest', () {
    test('returns the k-th smallest (0-based)', () {
      final List<int> data = <int>[7, 2, 5, 1, 9, 3];
      expect(nthSmallest(data, 0, _asc), 1);
      expect(nthSmallest(data, 2, _asc), 3);
      expect(nthSmallest(data, 5, _asc), 9);
    });

    test('agrees with a full sort for every rank', () {
      final List<int> data = <int>[5, 1, 4, 1, 3, 9, 2, 6];
      final List<int> sorted = data.toList()..sort();
      for (int k = 0; k < data.length; k++) {
        expect(nthSmallest(data, k, _asc), sorted[k], reason: 'rank $k');
      }
    });

    test('returns null for out-of-range k', () {
      expect(nthSmallest(<int>[1, 2], -1, _asc), isNull);
      expect(nthSmallest(<int>[1, 2], 2, _asc), isNull);
      expect(nthSmallest(<int>[], 0, _asc), isNull);
    });

    test('does not mutate the input', () {
      final List<int> data = <int>[3, 1, 2];
      nthSmallest(data, 1, _asc);
      expect(data, <int>[3, 1, 2]);
    });

    test('handles already-sorted and reverse-sorted input (median-of-three)', () {
      final List<int> asc = List<int>.generate(50, (int i) => i);
      final List<int> desc = List<int>.generate(50, (int i) => 49 - i);
      expect(nthSmallest(asc, 25, _asc), 25);
      expect(nthSmallest(desc, 25, _asc), 25);
    });
  });

  group('nthLargest', () {
    test('k=0 is the maximum', () {
      expect(nthLargest(<int>[7, 2, 5, 1, 9, 3], 0, _asc), 9);
    });

    test('returns the k-th largest', () {
      expect(nthLargest(<int>[7, 2, 5, 1, 9, 3], 1, _asc), 7);
    });

    test('returns null for out-of-range k', () {
      expect(nthLargest(<int>[1], 5, _asc), isNull);
    });
  });
}
