import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_nested_extensions.dart';

void main() {
  group('getNested', () {
    test('gets nested value', () {
      final Map<String, dynamic> m = <String, dynamic>{
        'a': <String, dynamic>{
          'b': <String, dynamic>{'c': 42},
        },
      };
      expect(getNested(m, <String>['a', 'b', 'c']), 42);
    });
    test('returns default when path missing', () {
      final Map<String, dynamic> m = <String, dynamic>{'a': 1};
      expect(getNested(m, <String>['b'], 0), 0);
    });
  });
  group('setNested', () {
    test('sets nested and creates path', () {
      final Map<String, dynamic> m = <String, dynamic>{};
      setNested(m, <String>['a', 'b', 'c'], 10);
      expect(getNested(m, <String>['a', 'b', 'c']), 10);
    });
  });
}
