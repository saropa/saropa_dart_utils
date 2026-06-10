import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/lcs_sequence_utils.dart';

void main() {
  group('longestCommonSubsequence', () {
    test('finds a non-contiguous common subsequence', () {
      expect(
        longestCommonSubsequence(<String>['a', 'b', 'c', 'd'], <String>['b', 'd']),
        <String>['b', 'd'],
      );
    });

    test('handles a longer shared run with gaps', () {
      expect(
        longestCommonSubsequence(<int>[1, 2, 3, 4, 1], <int>[3, 4, 1]),
        <int>[3, 4, 1],
      );
    });

    test('returns empty when nothing is shared', () {
      expect(longestCommonSubsequence(<int>[1, 2, 3], <int>[4, 5]), isEmpty);
    });

    test('returns empty for an empty input', () {
      expect(longestCommonSubsequence(<int>[], <int>[1]), isEmpty);
      expect(longestCommonSubsequence(<int>[1], <int>[]), isEmpty);
    });

    test('identical lists return the whole list', () {
      expect(longestCommonSubsequence(<int>[1, 2, 3], <int>[1, 2, 3]), <int>[1, 2, 3]);
    });
  });

  group('longestCommonSubsequenceLength', () {
    test('matches the length of the reconstructed subsequence', () {
      final List<String> a = <String>['x', 'a', 'b', 'y', 'c'];
      final List<String> b = <String>['a', 'z', 'b', 'c'];
      expect(
        longestCommonSubsequenceLength(a, b),
        longestCommonSubsequence(a, b).length,
      );
    });

    test('is zero for disjoint inputs', () {
      expect(longestCommonSubsequenceLength(<int>[1], <int>[2]), 0);
    });

    test('is zero when either list is empty', () {
      expect(longestCommonSubsequenceLength(<int>[], <int>[1, 2]), 0);
      expect(longestCommonSubsequenceLength(<int>[1, 2], <int>[]), 0);
    });

    test('counts a fully shared run', () {
      expect(longestCommonSubsequenceLength(<int>[1, 2, 3], <int>[1, 2, 3]), 3);
    });
  });
}
