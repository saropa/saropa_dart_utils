import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_flatten_extensions.dart';

void main() {
  group('flattenKeys', () {
    test('nested to dot keys', () {
      final Map<String, dynamic> m = <String, dynamic>{
        'a': <String, dynamic>{
          'b': <String, dynamic>{'c': 1},
        },
        'x': 2,
      };
      expect(m.flattenKeys(), <String, dynamic>{'a.b.c': 1, 'x': 2});
    });
    test('empty', () {
      expect(<String, dynamic>{}.flattenKeys(), <String, dynamic>{});
    });
  });
  group('unflattenKeys', () {
    test('dot keys to nested', () {
      final Map<String, dynamic> m = <String, dynamic>{'a.b.c': 1, 'x': 2};
      expect(m.unflattenKeys(), <String, dynamic>{
        'a': <String, dynamic>{
          'b': <String, dynamic>{'c': 1},
        },
        'x': 2,
      });
    });
  });
}
