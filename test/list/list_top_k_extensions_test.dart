// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/list/list_top_k_extensions.dart';

void main() {
  group('ListTopKExtensions.topK', () {
    test('returns the k smallest in ascending order (default compare)', () {
      expect(<int>[5, 1, 4, 2, 3].topK(3), <int>[1, 2, 3]);
    });

    test('returns the full list UNSORTED when k equals length', () {
      // Documented contract: "returns full list if k >= length". The early
      // return skips the sort, so original order is preserved when k == length.
      expect(<int>[3, 1, 2].topK(3), <int>[3, 1, 2]);
    });

    test('returns the full list unsorted when k exceeds length', () {
      expect(<int>[3, 1, 2].topK(10), <int>[3, 1, 2]);
    });

    test('k of 1 returns the single smallest element', () {
      expect(<int>[5, 1, 4].topK(1), <int>[1]);
    });

    test('custom comparator selects the k largest', () {
      // Reverse comparator -> largest values first.
      expect(<int>[5, 1, 4, 2, 3].topK(2, (int a, int b) => b.compareTo(a)), <int>[5, 4]);
    });

    test('works with strings via Comparable', () {
      expect(<String>['banana', 'apple', 'cherry'].topK(2), <String>['apple', 'banana']);
    });

    test('throws ArgumentError for k of 0', () {
      expect(() => <int>[1, 2, 3].topK(0), throwsArgumentError);
    });

    test('throws ArgumentError for negative k', () {
      expect(() => <int>[1, 2, 3].topK(-1), throwsArgumentError);
    });

    test('throws ArgumentError when T is not Comparable and no comparator given', () {
      expect(() => <Object>[Object(), Object()].topK(1), throwsArgumentError);
    });

    test('does not mutate the original list', () {
      final List<int> source = <int>[5, 1, 4, 2, 3];
      final List<int> result = source.topK(2);
      expect(result, <int>[1, 2]);
      expect(source, <int>[5, 1, 4, 2, 3]);
    });
  });
}
