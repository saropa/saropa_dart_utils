import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_deep_merge_extensions.dart';
import 'package:saropa_dart_utils/map/map_default_extensions.dart';

void main() {
  group('deepMerge', () {
    test('nested merge', () {
      final Map<String, dynamic> a = <String, dynamic>{
        'a': 1,
        'nested': <String, dynamic>{'x': 10},
      };
      final Map<String, dynamic> b = <String, dynamic>{
        'nested': <String, dynamic>{'y': 20},
      };
      expect(a.deepMerge(b), <String, dynamic>{
        'a': 1,
        'nested': <String, dynamic>{'x': 10, 'y': 20},
      });
    });

    test('result does not alias the inputs (regression)', () {
      final Map<String, dynamic> a = <String, dynamic>{
        'only': <String, dynamic>{'x': 1},
        'list': <int>[1, 2],
      };
      final Map<String, dynamic> merged = a.deepMerge(<String, dynamic>{'b': 2});
      // Mutating a nested value carried through from `a` must not touch `a`.
      (merged['only'] as Map<String, dynamic>)['x'] = 99;
      (merged['list'] as List<dynamic>).add(3);
      expect((a['only'] as Map<String, dynamic>)['x'], 1);
      expect(a['list'] as List<dynamic>, hasLength(2));
    });
  });
  group('withDefault', () {
    test('returns default for missing key', () {
      final Map<String, int> m = <String, int>{'a': 1};
      final MapDefaultExtensions<String, int> dm = m.withDefault(0);
      expect(dm['a'], 1);
      expect(dm['b'], 0);
    });
    test('set writes through', () {
      final Map<String, int> m = <String, int>{};
      final MapDefaultExtensions<String, int> dm = m.withDefault(0);
      dm['x'] = 5;
      expect(m['x'], 5);
    });
  });
}
