import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/iterable/iterable_map_not_null_extensions.dart';

void main() {
  group('mapNotNull', () {
    test('keeps only non-null mapped results', () {
      expect(<String>['1', 'x', '3'].mapNotNull(int.tryParse), <int>[1, 3]);
    });

    test('returns an empty iterable when all map to null', () {
      expect(<String>['a', 'b'].mapNotNull(int.tryParse), isEmpty);
    });

    test('returns an empty iterable for an empty source', () {
      expect(<String>[].mapNotNull(int.tryParse), isEmpty);
    });

    test('result type is the non-nullable U', () {
      final Iterable<int> result = <String>['1'].mapNotNull(int.tryParse);
      expect(result.first, 1);
    });

    test('is lazy: selector not invoked until iterated', () {
      int calls = 0;
      final Iterable<int> lazy = <int>[1, 2, 3].mapNotNull((int n) {
        calls++;
        return n;
      });
      expect(calls, 0);
      lazy.toList();
      expect(calls, 3);
    });
  });

  group('whereNotNull', () {
    test('drops null entries', () {
      expect(<int?>[1, null, 3].whereNotNull(), <int>[1, 3]);
    });

    test('returns empty when all null', () {
      expect(<int?>[null, null].whereNotNull(), isEmpty);
    });

    test('recovers the non-nullable element type', () {
      final Iterable<String> result = <String?>['a', null, 'b'].whereNotNull();
      expect(result.toList(), <String>['a', 'b']);
    });
  });
}
