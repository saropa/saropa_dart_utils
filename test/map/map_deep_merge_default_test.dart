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
  });
  group('withDefault', () {
    test('returns default for missing key', () {
      final Map<String, int> m = <String, int>{'a': 1};
      final DefaultMap<String, int> dm = m.withDefault(0);
      expect(dm['a'], 1);
      expect(dm['b'], 0);
    });
    test('set writes through', () {
      final Map<String, int> m = <String, int>{};
      final DefaultMap<String, int> dm = m.withDefault(0);
      dm['x'] = 5;
      expect(m['x'], 5);
    });
  });
}
