import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_deep_utils.dart';

void main() {
  group('deepCopyMap', () {
    test('shallow map', () {
      final Map<String, dynamic> a = <String, dynamic>{'x': 1, 'y': 2};
      final Map<String, dynamic> b = deepCopyMap(a);
      expect(b, <String, dynamic>{'x': 1, 'y': 2});
      b['x'] = 99;
      expect(a['x'], 1);
    });
    test('nested map', () {
      final Map<String, dynamic> a = <String, dynamic>{
        'a': <String, dynamic>{'b': 3},
      };
      final Map<String, dynamic> b = deepCopyMap(a);
      (b['a'] as Map<String, dynamic>)['b'] = 4;
      expect((a['a'] as Map<String, dynamic>)['b'], 3);
    });
  });
  group('deepCopyList', () {
    test('list with nested map', () {
      final List<dynamic> a = <dynamic>[
        <String, dynamic>{'k': 1},
      ];
      final List<dynamic> b = deepCopyList(a);
      (b[0] as Map<String, dynamic>)['k'] = 2;
      expect((a[0] as Map<String, dynamic>)['k'], 1);
    });
  });
}
