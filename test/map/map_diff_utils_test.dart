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

    test('a genuinely null value is reported as added/changed/removed', () {
      // A nullable V whose value is null must not be confused with absence.
      final (Map<String, int?>, Map<String, int?>, Map<String, int?>) addDiff =
          mapDiff<String, int?>(
            <String, int?>{},
            <String, int?>{'a': null},
          );
      expect(addDiff.$1, <String, int?>{'a': null}); // added contains the null entry

      final (Map<String, int?>, Map<String, int?>, Map<String, int?>) chgDiff =
          mapDiff<String, int?>(
            <String, int?>{'a': 1},
            <String, int?>{'a': null},
          );
      expect(chgDiff.$3, <String, int?>{'a': null}); // changed 1 -> null

      final (Map<String, int?>, Map<String, int?>, Map<String, int?>) remDiff =
          mapDiff<String, int?>(
            <String, int?>{'a': null},
            <String, int?>{},
          );
      expect(remDiff.$2, <String, int?>{'a': null}); // removed the null entry
    });
  });
}
