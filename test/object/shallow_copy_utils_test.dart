import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/shallow_copy_utils.dart';

void main() {
  group('shallowCopyList', () {
    test('produces an equal but distinct list', () {
      final List<int> source = <int>[1, 2, 3];
      final List<int> copy = shallowCopyList<int>(source);
      expect(copy, <int>[1, 2, 3]);
      expect(identical(copy, source), isFalse);
    });

    test('mutating the copy does not affect the source', () {
      final List<int> source = <int>[1, 2];
      final List<int> copy = shallowCopyList<int>(source)..[0] = 9;
      expect(source[0], 1);
      expect(copy[0], 9);
    });

    test('shares element references (shallow)', () {
      final List<int> inner = <int>[1];
      final List<List<int>> source = <List<int>>[inner];
      final List<List<int>> copy = shallowCopyList<List<int>>(source);
      expect(identical(copy[0], inner), isTrue);
    });

    test('copies an empty list', () {
      expect(shallowCopyList<int>(<int>[]), isEmpty);
    });
  });

  group('shallowCopyMap', () {
    test('produces an equal but distinct map', () {
      final Map<String, int> source = <String, int>{'a': 1, 'b': 2};
      final Map<String, int> copy = shallowCopyMap<String, int>(source);
      expect(copy, <String, int>{'a': 1, 'b': 2});
      expect(identical(copy, source), isFalse);
    });

    test('mutating the copy does not affect the source', () {
      final Map<String, int> source = <String, int>{'a': 1};
      final Map<String, int> copy = shallowCopyMap<String, int>(source)..['a'] = 9;
      expect(source['a'], 1);
      expect(copy['a'], 9);
    });

    test('shares value references (shallow)', () {
      final List<int> inner = <int>[1];
      final Map<String, List<int>> source = <String, List<int>>{'k': inner};
      final Map<String, List<int>> copy = shallowCopyMap<String, List<int>>(source);
      expect(identical(copy['k'], inner), isTrue);
    });

    test('copies an empty map', () {
      expect(shallowCopyMap<String, int>(<String, int>{}), isEmpty);
    });
  });
}
