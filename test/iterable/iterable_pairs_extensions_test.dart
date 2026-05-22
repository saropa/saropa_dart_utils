import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_pairs_extensions.dart';

void main() {
  group('allPairs', () {
    test('all i<j combinations of three elements', () {
      expect(<int>[1, 2, 3].allPairs(), <(int, int)>[(1, 2), (1, 3), (2, 3)]);
    });

    test('two elements yield one pair', () {
      expect(<int>[1, 2].allPairs(), <(int, int)>[(1, 2)]);
    });

    test('single element yields no pairs', () {
      expect(<int>[1].allPairs(), <(int, int)>[]);
    });

    test('empty iterable yields no pairs', () {
      expect(<int>[].allPairs(), <(int, int)>[]);
    });

    test('count is n*(n-1)/2', () {
      // 4 elements -> 6 pairs
      expect(<int>[1, 2, 3, 4].allPairs(), hasLength(6));
    });

    test('preserves order within and across pairs', () {
      expect(<String>['a', 'b', 'c'].allPairs(), <(String, String)>[
        ('a', 'b'),
        ('a', 'c'),
        ('b', 'c'),
      ]);
    });
  });
}
