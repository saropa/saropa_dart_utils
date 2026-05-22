import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_more_extensions.dart';

void main() {
  group('takeLast', () {
    test('returns last n elements', () {
      expect(<int>[1, 2, 3, 4, 5].takeLast(2), <int>[4, 5]);
    });
    test('n >= length returns whole list', () {
      expect(<int>[1, 2].takeLast(10), <int>[1, 2]);
    });
    test('n == 0 returns empty', () {
      expect(<int>[1, 2, 3].takeLast(0), <int>[]);
    });
    test('empty list returns empty', () {
      expect(<int>[].takeLast(3), <int>[]);
    });
  });

  group('dropLast', () {
    test('drops last n elements', () {
      expect(<int>[1, 2, 3, 4, 5].dropLast(2), <int>[1, 2, 3]);
    });
    test('n <= 0 returns whole list', () {
      expect(<int>[1, 2, 3].dropLast(0), <int>[1, 2, 3]);
    });
    test('n >= length returns empty', () {
      expect(<int>[1, 2].dropLast(5), <int>[]);
    });
    test('empty list returns empty', () {
      expect(<int>[].dropLast(2), <int>[]);
    });
  });

  group('replaceFirst', () {
    test('replaces only the first occurrence', () {
      expect(<int>[1, 2, 1, 3].replaceFirst(1, 9), <int>[9, 2, 1, 3]);
    });
    test('value not present returns equal list', () {
      expect(<int>[1, 2, 3].replaceFirst(7, 9), <int>[1, 2, 3]);
    });
    test('does not mutate original', () {
      final List<int> original = <int>[1, 2];
      final List<int> result = original.replaceFirst(1, 9);
      expect(result, <int>[9, 2]);
      expect(original, <int>[1, 2]);
    });
  });

  group('replaceAllValues', () {
    test('replaces every occurrence', () {
      expect(<int>[1, 2, 1, 1].replaceAllValues(1, 9), <int>[9, 2, 9, 9]);
    });
    test('value not present returns equal list', () {
      expect(<int>[1, 2, 3].replaceAllValues(7, 9), <int>[1, 2, 3]);
    });
  });

  group('cycle', () {
    test('repeats list elements', () {
      expect(<int>[1, 2, 3].cycle().take(7).toList(), <int>[1, 2, 3, 1, 2, 3, 1]);
    });
    test('single element repeats forever', () {
      expect(<int>[9].cycle().take(3).toList(), <int>[9, 9, 9]);
    });
    test('empty list yields nothing', () {
      expect(<int>[].cycle().take(5).toList(), <int>[]);
    });
  });

  group('padTo', () {
    test('pads short list with fill', () {
      expect(<int>[1, 2].padTo(5, 0), <int>[1, 2, 0, 0, 0]);
    });
    test('list already long enough is copied unchanged', () {
      expect(<int>[1, 2, 3].padTo(2, 0), <int>[1, 2, 3]);
    });
    test('exact length returns copy', () {
      expect(<int>[1, 2].padTo(2, 0), <int>[1, 2]);
    });
    test('empty list pads to full fill', () {
      expect(<int>[].padTo(3, 7), <int>[7, 7, 7]);
    });
  });

  group('unzip2', () {
    test('splits pairs into two lists', () {
      final (List<int>, List<String>) result = unzip2<int, String>(<(int, String)>[
        (1, 'a'),
        (2, 'b'),
      ]);
      expect(result.$1, <int>[1, 2]);
      expect(result.$2, <String>['a', 'b']);
    });
    test('empty pairs yield two empty lists', () {
      final (List<int>, List<String>) result = unzip2<int, String>(<(int, String)>[]);
      expect(result.$1, <int>[]);
      expect(result.$2, <String>[]);
    });
  });

  group('segmentBy', () {
    test('starts new segment when predicate false', () {
      // Split where next is not consecutive (+1).
      final List<List<int>> result =
          <int>[1, 2, 3, 5, 6, 9].segmentBy((int a, int b) => b == a + 1);
      expect(result, <List<int>>[
        <int>[1, 2, 3],
        <int>[5, 6],
        <int>[9],
      ]);
    });
    test('all consecutive yields one segment', () {
      expect(
        <int>[1, 2, 3].segmentBy((int a, int b) => b == a + 1),
        <List<int>>[
          <int>[1, 2, 3],
        ],
      );
    });
    test('never-true predicate yields singleton segments', () {
      expect(
        <int>[1, 2, 3].segmentBy((int a, int b) => false),
        <List<int>>[
          <int>[1],
          <int>[2],
          <int>[3],
        ],
      );
    });
    test('empty list yields no segments', () {
      expect(<int>[].segmentBy((int a, int b) => true), <List<int>>[]);
    });
    test('single element yields one singleton segment', () {
      expect(
        <int>[5].segmentBy((int a, int b) => true),
        <List<int>>[
          <int>[5],
        ],
      );
    });
  });

  group('consecutivePairs', () {
    test('adjacent pairs', () {
      expect(<int>[1, 2, 3, 4].consecutivePairs(), <(int, int)>[(1, 2), (2, 3), (3, 4)]);
    });
    test('length < 2 yields empty', () {
      expect(<int>[1].consecutivePairs(), <(int, int)>[]);
      expect(<int>[].consecutivePairs(), <(int, int)>[]);
    });
    test('exactly two elements yields one pair', () {
      expect(<int>[1, 2].consecutivePairs(), <(int, int)>[(1, 2)]);
    });
  });

  group('argMinBy', () {
    test('index of minimum key', () {
      // Lengths: 3,1,2 -> min at index 1
      expect(<String>['aaa', 'b', 'cc'].argMinBy((String s) => s.length), 1);
    });
    test('empty yields null', () {
      expect(<int>[].argMinBy((int x) => x), isNull);
    });
    test('tie keeps first index', () {
      expect(<int>[2, 2, 3].argMinBy((int x) => x), 0);
    });
  });

  group('argMaxBy', () {
    test('index of maximum key', () {
      expect(<String>['a', 'bbb', 'cc'].argMaxBy((String s) => s.length), 1);
    });
    test('empty yields null', () {
      expect(<int>[].argMaxBy((int x) => x), isNull);
    });
    test('tie keeps first index', () {
      expect(<int>[3, 3, 1].argMaxBy((int x) => x), 0);
    });
  });

  group('allEqual', () {
    test('all same is true', () {
      expect(<int>[5, 5, 5].allEqual, isTrue);
    });
    test('differing is false', () {
      expect(<int>[5, 5, 6].allEqual, isFalse);
    });
    test('empty is true', () {
      expect(<int>[].allEqual, isTrue);
    });
    test('single element is true', () {
      expect(<int>[1].allEqual, isTrue);
    });
  });

  group('countBy', () {
    test('counts occurrences of each element', () {
      expect(<int>[1, 1, 2, 3, 3, 3].countBy(), <int, int>{1: 2, 2: 1, 3: 3});
    });
    test('empty yields empty map', () {
      expect(<int>[].countBy(), <int, int>{});
    });
    test('all distinct each count 1', () {
      expect(<String>['a', 'b'].countBy(), <String, int>{'a': 1, 'b': 1});
    });
  });

  group('scan', () {
    test('running sum includes initial', () {
      expect(<int>[1, 2, 3].scan<int>(0, (int acc, int e) => acc + e), <int>[0, 1, 3, 6]);
    });
    test('empty yields just the initial', () {
      expect(<int>[].scan<int>(10, (int acc, int e) => acc + e), <int>[10]);
    });
    test('running product', () {
      expect(<int>[2, 3, 4].scan<int>(1, (int acc, int e) => acc * e), <int>[1, 2, 6, 24]);
    });
  });
}
