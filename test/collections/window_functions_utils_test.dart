import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/window_functions_utils.dart';

void main() {
  group('lag', () {
    test('should return the value offset positions back', () {
      expect(lag([10, 20, 30], 2, 1), 20);
      expect(lag([10, 20, 30], 2, 2), 10);
    });

    test('should return null before the start', () {
      expect(lag([10, 20, 30], 0, 1), isNull);
    });

    test('should return the same element for offset 0', () {
      expect(lag([10, 20, 30], 1, 0), 20);
    });

    test('should return null for a negative resulting index', () {
      expect(lag([10, 20], 1, 5), isNull);
    });

    test('should work for strings', () {
      expect(lag(['a', 'b', 'c'], 2, 1), 'b');
    });
  });

  group('lead', () {
    test('should return the value offset positions ahead', () {
      expect(lead([10, 20, 30], 0, 1), 20);
      expect(lead([10, 20, 30], 0, 2), 30);
    });

    test('should return null past the end', () {
      expect(lead([10, 20, 30], 2, 1), isNull);
    });

    test('should return the same element for offset 0', () {
      expect(lead([10, 20, 30], 1, 0), 20);
    });

    test('should work for strings', () {
      expect(lead(['a', 'b', 'c'], 0, 2), 'c');
    });
  });

  group('rowNumber', () {
    test('should be 1-based', () {
      expect(rowNumber(0), 1);
      expect(rowNumber(4), 5);
    });
  });

  group('rank', () {
    test('should assign 1-based ranks with ties skipping', () {
      // values [3,1,4,1,5]: 5 is rank1, 4 rank2, 3 rank3, both 1s rank4.
      expect(rank([3, 1, 4, 1, 5]), [3, 4, 2, 4, 1]);
    });

    test('should rank a strictly ascending list highest-last', () {
      // 1 has 4 values above -> rank5; 5 has none -> rank1.
      expect(rank([1, 2, 3, 4, 5]), [5, 4, 3, 2, 1]);
    });

    test('should give all equal values the same rank', () {
      expect(rank([7, 7, 7]), [1, 1, 1]);
    });

    test('should return empty list for empty input', () {
      expect(rank(<num>[]), <int>[]);
    });

    test('should rank a single value as 1', () {
      expect(rank([42]), [1]);
    });

    test('should skip ranks after a tie', () {
      // Two 10s tie at rank1; 5 has two values above -> rank3 (rank2 skipped).
      expect(rank([10, 10, 5]), [1, 1, 3]);
    });
  });
}
