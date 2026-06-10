// Verifies that utilities reachable only via direct file imports are ALSO
// reachable through the single barrel import the README advertises
// ("one import"). This file imports ONLY the barrel — if any newly-exported
// extension introduced a method-name ambiguity on Iterable/List, this file
// would fail to compile, which is exactly the regression we want to catch.
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/saropa_dart_utils.dart';

void main() {
  group('barrel exposes previously file-only utilities', () {
    test('iterable extensions resolve via the barrel', () {
      expect(<int>[1, 2].cartesian(<int>[3]), <(int, int)>[(1, 3), (2, 3)]);
      // diff returns a positional record (added, removed, unchanged).
      expect(<int>[1, 2, 3].diff(<int>[2, 3, 4]).$1, <int>[4]);
      expect(<int>[1, 2, 3].firstWhereOrElse((int x) => x > 5, -1), -1);
      expect(<List<int>>[<int>[1], <int>[2, 3]].flattenDeep(), <int>[1, 2, 3]);
      expect(
        <String>['a', 'bb'].groupByTransform((String s) => s.length, (String s) => s.toUpperCase()),
        <int, List<String>>{1: <String>['A'], 2: <String>['BB']},
      );
      expect(<int>[5, 6].mapIndexed((int i, int v) => i + v), <int>[5, 7]);
      expect(<String>['aaa', 'b'].minBy((String s) => s.length), 'b');
      expect(<String>['a', 'bbb'].maxBy((String s) => s.length), 'bbb');
      expect(<int>[1, 2, 3].consecutivePairs(), <(int, int)>[(1, 2), (2, 3)]);
      expect(<int>[1, 2].allPairs(), <(int, int)>[(1, 2)]);
      expect(<int>[3, 1, 2].sortByThenBy((int x) => x), <int>[1, 2, 3]);
      // Compare record fields separately: List == is identity, so a whole-record
      // expect would fail even with equal contents.
      final (List<int>, List<int>) parts = <int>[1, 2, 3].splitAt(1);
      expect(parts.$1, <int>[1]);
      expect(parts.$2, <int>[2, 3]);
      expect(<int>[1, 2].symmetricDifference(<int>[2, 3]).toSet(), <int>{1, 3});
    });

    test('list extensions resolve via the barrel', () {
      // Seeded shuffle is reproducible for a fixed seed.
      expect(<int>[1, 2, 3, 4, 5].shuffleWithSeed(42), <int>[1, 2, 3, 4, 5].shuffleWithSeed(42));
      expect(
        <int>[5, 1, 4, 2, 3].topK(2, (int a, int b) => a.compareTo(b)).toSet(),
        <int>{1, 2},
      );
    });

    test('async helpers resolve via the barrel', () async {
      expect(await race<int>(<Future<int>>[Future<int>.value(1)]), 1);
      final List<Object?> settled = await allSettled<int>(<Future<int>>[Future<int>.value(7)]);
      expect(settled, hasLength(1));
    });

    test('gesture utilities resolve via the barrel', () {
      // Just needs to resolve and return a SwipeSpeed without throwing.
      expect(GestureUtils.getSwipeSpeed(0), isA<SwipeSpeed>());
    });
  });
}
