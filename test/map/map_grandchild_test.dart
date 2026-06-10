import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_extensions.dart';

void main() {
  final Map<String, dynamic> nested = <String, dynamic>{
    'a': <String, dynamic>{
      'b': 'grand',
      'bb': <String, dynamic>{'c': 'great'},
    },
  };

  group('getGrandchildString', () {
    test('returns the nested string two levels down', () {
      expect(nested.getGrandchildString('a', 'b'), 'grand');
    });

    test('null when a key is missing', () {
      expect(nested.getGrandchildString('a', 'missing'), isNull);
      expect(nested.getGrandchildString('x', 'b'), isNull);
    });

    test('null when the value is not a string', () {
      expect(nested.getGrandchildString('a', 'bb'), isNull);
    });
  });

  group('getGreatGrandchild', () {
    test('returns the value three levels down', () {
      expect(
        nested.getGreatGrandchild(childKey: 'a', grandChildKey: 'bb', greatGrandChildKey: 'c'),
        'great',
      );
    });

    test('null when a key is missing', () {
      expect(
        nested.getGreatGrandchild(childKey: 'a', grandChildKey: 'bb', greatGrandChildKey: 'x'),
        isNull,
      );
    });
  });

  group('getGreatGrandchildString', () {
    test('returns the nested string three levels down', () {
      expect(
        nested.getGreatGrandchildString(
          childKey: 'a',
          grandChildKey: 'bb',
          greatGrandChildKey: 'c',
        ),
        'great',
      );
    });

    test('null when the path is absent', () {
      expect(
        nested.getGreatGrandchildString(
          childKey: 'a',
          grandChildKey: 'b',
          greatGrandChildKey: 'c',
        ),
        isNull,
      );
    });
  });
}
