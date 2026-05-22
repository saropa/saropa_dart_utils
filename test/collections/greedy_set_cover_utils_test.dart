import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/greedy_set_cover_utils.dart';

void main() {
  group('greedySetCover', () {
    test('should pick the largest covering set first', () {
      final List<Set<Object>> sets = [
        <Object>{1, 2, 3},
        <Object>{2, 4},
        <Object>{3, 4},
        <Object>{4, 5},
      ];
      // Set 0 covers {1,2,3} (3 new), then set 3 covers {4,5}.
      expect(greedySetCover(sets, <Object>{1, 2, 3, 4, 5}), [0, 3]);
    });

    test('should return empty list for empty universe', () {
      expect(
        greedySetCover([
          <Object>{1, 2},
        ], <Object>{}),
        <int>[],
      );
    });

    test('should select a single covering set', () {
      final List<Set<Object>> sets = [
        <Object>{1, 2, 3},
      ];
      expect(greedySetCover(sets, <Object>{1, 2, 3}), [0]);
    });

    test('should stop when universe cannot be fully covered', () {
      final List<Set<Object>> sets = [
        <Object>{1},
      ];
      // Element 2 is uncoverable; only set 0 is chosen, then it breaks.
      expect(greedySetCover(sets, <Object>{1, 2}), [0]);
    });

    test('should return empty list when no set intersects universe', () {
      final List<Set<Object>> sets = [
        <Object>{9, 10},
      ];
      expect(greedySetCover(sets, <Object>{1, 2}), <int>[]);
    });

    test('should cover with multiple greedy picks', () {
      final List<Set<Object>> sets = [
        <Object>{1, 2},
        <Object>{3, 4},
        <Object>{5},
      ];
      expect(greedySetCover(sets, <Object>{1, 2, 3, 4, 5}), [0, 1, 2]);
    });

    test('should work with string elements', () {
      final List<Set<Object>> sets = [
        <Object>{'a', 'b'},
        <Object>{'c'},
      ];
      expect(greedySetCover(sets, <Object>{'a', 'b', 'c'}), [0, 1]);
    });
  });
}
