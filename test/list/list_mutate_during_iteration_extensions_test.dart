import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/saropa_dart_utils.dart';

void main() {
  group('ListMutateDuringIterationExtensions', () {
    group('forEachSnapshot', () {
      test('removing during iteration does not throw and removes matches', () {
        final List<int> q = <int>[1, 2, 3, 4];
        q.forEachSnapshot((int n) {
          if (n.isEven) q.remove(n);
        });
        expect(q, equals(<int>[1, 3]));
      });

      test('a plain for-in with the same mutation would throw (contrast)', () {
        final List<int> q = <int>[1, 2, 3, 4];
        expect(
          () {
            for (final int n in q) {
              if (n.isEven) q.remove(n);
            }
          },
          throwsA(isA<ConcurrentModificationError>()),
        );
      });

      test('elements added by the body are not visited this pass', () {
        final List<int> list = <int>[1, 2];
        int visits = 0;
        list.forEachSnapshot((int _) {
          visits++;
          // Would loop forever on a live iterator; the snapshot bounds it to 2.
          if (visits <= 2) list.add(99);
        });
        expect(visits, equals(2));
        expect(list, equals(<int>[1, 2, 99, 99]));
      });

      test('a removed element is still visited if present at snapshot time', () {
        final List<String> seen = <String>[];
        final List<String> list = <String>['a', 'b', 'c'];
        list.forEachSnapshot((String e) {
          seen.add(e);
          list.remove(e);
        });
        // All three were in the snapshot, so all three are visited even though
        // each is gone from the original by the time the next runs.
        expect(seen, equals(<String>['a', 'b', 'c']));
        expect(list, isEmpty);
      });

      test('empty list is a no-op', () {
        final List<int> empty = <int>[];
        int calls = 0;
        empty.forEachSnapshot((int _) => calls++);
        expect(calls, equals(0));
      });

      test('single element', () {
        final List<int> one = <int>[7];
        final List<int> seen = <int>[];
        one.forEachSnapshot(seen.add);
        expect(seen, equals(<int>[7]));
      });

      test('no mutation behaves like a plain forEach', () {
        final List<int> nums = <int>[10, 20, 30];
        int sum = 0;
        nums.forEachSnapshot((int n) => sum += n);
        expect(sum, equals(60));
        expect(nums, equals(<int>[10, 20, 30]));
      });

      test('nullable element type preserves a matched null', () {
        final List<int?> list = <int?>[1, null, 3];
        final List<int?> seen = <int?>[];
        list.forEachSnapshot(seen.add);
        expect(seen, equals(<int?>[1, null, 3]));
      });
    });
  });
}
