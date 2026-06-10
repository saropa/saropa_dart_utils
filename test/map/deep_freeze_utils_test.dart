import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/deep_freeze_utils.dart';

void main() {
  group('deepFreeze', () {
    test('top-level map becomes unmodifiable', () {
      final Object? frozen = deepFreeze(<String, int>{'a': 1});
      expect(() => (frozen! as Map<Object?, Object?>)['b'] = 2, throwsUnsupportedError);
    });

    test('nested list is frozen too', () {
      final Object? frozen = deepFreeze(<String, dynamic>{
        'a': <int>[1, 2],
      });
      final Object? inner = (frozen! as Map<Object?, Object?>)['a'];
      expect(() => (inner! as List<Object?>).add(3), throwsUnsupportedError);
    });

    test('deeply nested map is frozen', () {
      final Object? frozen = deepFreeze(<String, dynamic>{
        'a': <String, dynamic>{
          'b': <String, int>{'c': 3},
        },
      });
      final Map<Object?, Object?> a =
          (frozen! as Map<Object?, Object?>)['a']! as Map<Object?, Object?>;
      final Map<Object?, Object?> b = a['b']! as Map<Object?, Object?>;
      expect(() => b['d'] = 4, throwsUnsupportedError);
    });

    test('set is frozen', () {
      final Object? frozen = deepFreeze(<int>{1, 2});
      expect(() => (frozen! as Set<Object?>).add(3), throwsUnsupportedError);
    });

    test('values are preserved', () {
      final Map<Object?, Object?> frozen =
          deepFreeze(<String, dynamic>{
                'a': <int>[1, 2],
                'n': 5,
              })!
              as Map<Object?, Object?>;
      expect(frozen['a'], <int>[1, 2]);
      expect(frozen['n'], 5);
    });

    test('scalars and null pass through unchanged', () {
      expect(deepFreeze(5), 5);
      expect(deepFreeze('x'), 'x');
      expect(deepFreeze(null), isNull);
    });

    test('is a copy: later edits to the original do not show through', () {
      final List<int> original = <int>[1, 2];
      final Object? frozen = deepFreeze(<String, dynamic>{'a': original});
      original.add(99);
      expect((frozen! as Map<Object?, Object?>)['a'], <int>[1, 2]);
    });
  });
}
