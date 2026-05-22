import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/json_diff_patch_utils.dart';

void main() {
  group('jsonDiffShallow', () {
    test('added key reported in added', () {
      final (Map<String, Object?> added, Map<String, Object?> removed, Map<String, Object?> changed) r =
          jsonDiffShallow(<String, Object?>{'a': 1}, <String, Object?>{'a': 1, 'b': 2});
      expect(r.$1, <String, Object?>{'b': 2});
      expect(r.$2, <String, Object?>{});
      expect(r.$3, <String, Object?>{});
    });

    test('removed key reported with old value', () {
      final (Map<String, Object?>, Map<String, Object?>, Map<String, Object?>) r =
          jsonDiffShallow(<String, Object?>{'a': 1, 'b': 2}, <String, Object?>{'a': 1});
      expect(r.$1, <String, Object?>{});
      expect(r.$2, <String, Object?>{'b': 2});
      expect(r.$3, <String, Object?>{});
    });

    test('changed key reported with new value', () {
      final (Map<String, Object?>, Map<String, Object?>, Map<String, Object?>) r =
          jsonDiffShallow(<String, Object?>{'a': 1}, <String, Object?>{'a': 9});
      expect(r.$1, <String, Object?>{});
      expect(r.$2, <String, Object?>{});
      expect(r.$3, <String, Object?>{'a': 9});
    });

    test('identical maps produce no diff', () {
      final (Map<String, Object?>, Map<String, Object?>, Map<String, Object?>) r =
          jsonDiffShallow(<String, Object?>{'a': 1, 'b': 2}, <String, Object?>{'a': 1, 'b': 2});
      expect(r.$1, isEmpty);
      expect(r.$2, isEmpty);
      expect(r.$3, isEmpty);
    });

    test('combined add, remove, change', () {
      final (Map<String, Object?>, Map<String, Object?>, Map<String, Object?>) r = jsonDiffShallow(
        <String, Object?>{'keep': 1, 'gone': 2, 'mod': 3},
        <String, Object?>{'keep': 1, 'mod': 30, 'new': 4},
      );
      expect(r.$1, <String, Object?>{'new': 4});
      expect(r.$2, <String, Object?>{'gone': 2});
      expect(r.$3, <String, Object?>{'mod': 30});
    });

    test('both empty produces no diff', () {
      final (Map<String, Object?>, Map<String, Object?>, Map<String, Object?>) r =
          jsonDiffShallow(<String, Object?>{}, <String, Object?>{});
      expect(r.$1, isEmpty);
      expect(r.$2, isEmpty);
      expect(r.$3, isEmpty);
    });

    test('empty to populated reports all as added', () {
      final (Map<String, Object?>, Map<String, Object?>, Map<String, Object?>) r =
          jsonDiffShallow(<String, Object?>{}, <String, Object?>{'a': 1, 'b': 2});
      expect(r.$1, <String, Object?>{'a': 1, 'b': 2});
      expect(r.$2, isEmpty);
      expect(r.$3, isEmpty);
    });
  });
}
