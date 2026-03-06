import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/map/map_diff_utils.dart';

void main() {
  group('mapDiff', () {
    test('added and removed', () {
      final Map<String, int> before = <String, int>{'a': 1};
      final Map<String, int> after = <String, int>{'b': 2};
      final (Map<String, int> added, Map<String, int> removed, Map<String, int> changed) = mapDiff(
        before,
        after,
      );
      expect(added, <String, int>{'b': 2});
      expect(removed, <String, int>{'a': 1});
      expect(changed, <String, int>{});
    });
    test('changed', () {
      final Map<String, int> before = <String, int>{'a': 1};
      final Map<String, int> after = <String, int>{'a': 2};
      final (Map<String, int> added, Map<String, int> removed, Map<String, int> changed) = mapDiff(
        before,
        after,
      );
      expect(added, <String, int>{});
      expect(removed, <String, int>{});
      expect(changed, <String, int>{'a': 2});
    });
  });
}
