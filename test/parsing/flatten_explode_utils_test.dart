import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/flatten_explode_utils.dart';

void main() {
  group('flattenMap', () {
    test('should keep scalar leaves as-is', () {
      expect(
        flattenMap(<String, Object?>{'id': 1, 'name': 'Ann'}),
        equals(<String, Object?>{'id': 1, 'name': 'Ann'}),
      );
    });

    test('should flatten a nested map into dotted keys', () {
      expect(
        flattenMap(<String, Object?>{
          'user': <String, Object?>{'name': 'Ann'},
        }),
        equals(<String, Object?>{'user.name': 'Ann'}),
      );
    });

    test('should index nested list elements', () {
      expect(
        flattenMap(<String, Object?>{
          'tags': <Object?>['a', 'b'],
        }),
        equals(<String, Object?>{'tags.0': 'a', 'tags.1': 'b'}),
      );
    });

    test('should flatten deep nesting', () {
      expect(
        flattenMap(<String, Object?>{
          'a': <String, Object?>{
            'b': <String, Object?>{'c': 9},
          },
        }),
        equals(<String, Object?>{'a.b.c': 9}),
      );
    });

    test('should honor a custom separator', () {
      expect(
        flattenMap(
          <String, Object?>{
            'a': <String, Object?>{'b': 1},
          },
          separator: '/',
        ),
        equals(<String, Object?>{'a/b': 1}),
      );
    });

    test('should flatten maps nested inside lists', () {
      expect(
        flattenMap(<String, Object?>{
          'rows': <Object?>[
            <String, Object?>{'x': 1},
          ],
        }),
        equals(<String, Object?>{'rows.0.x': 1}),
      );
    });
  });

  group('explode', () {
    test('should produce one row per array element', () {
      expect(
        explode(<String, Object?>{
          'id': 1,
          'tags': <Object?>['a', 'b'],
        }, 'tags'),
        equals(<Map<String, Object?>>[
          <String, Object?>{'id': 1, 'tags': 'a'},
          <String, Object?>{'id': 1, 'tags': 'b'},
        ]),
      );
    });

    test('should return empty for an empty array', () {
      expect(
        explode(<String, Object?>{'id': 1, 'tags': <Object?>[]}, 'tags'),
        isEmpty,
      );
    });

    test('should return the single row when the key is missing', () {
      final Map<String, Object?> row = <String, Object?>{'id': 1};

      expect(explode(row, 'tags'), equals(<Map<String, Object?>>[row]));
    });

    test('should return the single row when the value is not a list', () {
      final Map<String, Object?> row = <String, Object?>{'id': 1, 'tags': 'a'};

      expect(explode(row, 'tags'), equals(<Map<String, Object?>>[row]));
    });

    test('should copy other fields onto each exploded row', () {
      final List<Map<String, Object?>> rows = explode(<String, Object?>{
        'id': 7,
        'name': 'Ann',
        'scores': <Object?>[1, 2],
      }, 'scores');

      expect(rows.length, equals(2));
      expect(rows.first['name'], equals('Ann'));
      expect(rows.last['scores'], equals(2));
    });
  });
}
