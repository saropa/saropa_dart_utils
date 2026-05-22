import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_sort_extensions.dart';

class _Person {
  const _Person(this.age, this.name);
  final int age;
  final String name;
}

void main() {
  group('sortByThenBy', () {
    test('sorts by primary key only when thenBy omitted', () {
      expect(
        <String>['ccc', 'a', 'bb'].sortByThenBy((String s) => s.length),
        <String>['a', 'bb', 'ccc'],
      );
    });

    test('uses thenBy to break ties on the primary key', () {
      // Sort by age, then by name ascending for equal ages.
      final List<_Person> people = <_Person>[
        const _Person(30, 'Zoe'),
        const _Person(30, 'Amy'),
        const _Person(20, 'Bob'),
      ];
      final List<_Person> sorted = people.sortByThenBy(
        (_Person p) => p.age,
        (_Person a, _Person b) => a.name.compareTo(b.name),
      );
      expect(sorted.map((_Person p) => p.name).toList(), <String>['Bob', 'Amy', 'Zoe']);
    });

    test('returns a new list, leaving primary order stable when keys equal and no thenBy', () {
      // Equal keys keep original order (List.sort is stable for small lists).
      final List<String> result = <String>['b', 'a', 'c'].sortByThenBy((String s) => 1);
      expect(result, <String>['b', 'a', 'c']);
    });

    test('empty iterable yields empty list', () {
      expect(<int>[].sortByThenBy((int x) => x), <int>[]);
    });

    test('single element yields that element', () {
      expect(<int>[5].sortByThenBy((int x) => x), <int>[5]);
    });

    test('does not mutate the source', () {
      final List<int> source = <int>[3, 1, 2];
      final List<int> sorted = source.sortByThenBy((int x) => x);
      expect(sorted, <int>[1, 2, 3]);
      expect(source, <int>[3, 1, 2]);
    });
  });
}
