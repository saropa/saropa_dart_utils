import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/canonicalize_json_utils.dart';

void main() {
  group('canonicalizeJson', () {
    test('null returns null', () => expect(canonicalizeJson(null), isNull));

    test('sorts map keys', () {
      final Object? result = canonicalizeJson(<String, Object?>{'b': 1, 'a': 2, 'c': 3});
      expect(result, isA<Map<String, Object?>>());
      expect((result! as Map<String, Object?>).keys.toList(), <String>['a', 'b', 'c']);
    });

    test('non-string map keys stringified and sorted', () {
      final Object? result = canonicalizeJson(<Object, Object?>{2: 'two', 1: 'one', 10: 'ten'});
      expect((result! as Map<String, Object?>).keys.toList(), <String>['1', '10', '2']);
    });

    test('recurses into nested maps', () {
      final Object? result = canonicalizeJson(<String, Object?>{
        'z': <String, Object?>{'y': 1, 'x': 2},
      });
      final Map<String, Object?> inner = (result! as Map<String, Object?>)['z']! as Map<String, Object?>;
      expect(inner.keys.toList(), <String>['x', 'y']);
    });

    test('preserves list order, recurses into elements', () {
      final Object? result = canonicalizeJson(<Object?>[
        <String, Object?>{'b': 1, 'a': 2},
        3,
      ]);
      expect(result, isA<List<Object?>>());
      final List<Object?> list = result! as List<Object?>;
      expect((list[0]! as Map<String, Object?>).keys.toList(), <String>['a', 'b']);
      expect(list[1], 3);
    });

    test('int stays int', () => expect(canonicalizeJson(5), 5));

    test('double stays double', () => expect(canonicalizeJson(2.5), 2.5));

    test('non-int num collapsed to double', () {
      final Object? result = canonicalizeJson(3.0);
      expect(result, 3.0);
      expect(result, isA<double>());
    });

    test('string passes through unchanged', () => expect(canonicalizeJson('hi'), 'hi'));

    test('bool passes through unchanged', () => expect(canonicalizeJson(true), isTrue));

    test('empty map yields empty map', () => expect(canonicalizeJson(<String, Object?>{}), <String, Object?>{}));

    test('empty list yields empty list', () => expect(canonicalizeJson(<Object?>[]), <Object?>[]));
  });
}
