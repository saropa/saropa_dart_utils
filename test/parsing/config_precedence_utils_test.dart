import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/config_precedence_utils.dart';

void main() {
  group('mergeConfig', () {
    test('overlay non-null wins over default', () {
      expect(
        mergeConfig(<String, Object?>{'a': 1}, <String, Object?>{'a': 2}),
        <String, Object?>{'a': 2},
      );
    });

    test('overlay adds new keys', () {
      expect(
        mergeConfig(<String, Object?>{'a': 1}, <String, Object?>{'b': 2}),
        <String, Object?>{'a': 1, 'b': 2},
      );
    });

    test('overlay null value keeps default', () {
      expect(
        mergeConfig(<String, Object?>{'a': 1}, <String, Object?>{'a': null}),
        <String, Object?>{'a': 1},
      );
    });

    test('overlay null does not introduce key absent in defaults', () {
      expect(
        mergeConfig(<String, Object?>{'a': 1}, <String, Object?>{'b': null}),
        <String, Object?>{'a': 1},
      );
    });

    test('empty overlay returns copy of defaults', () {
      expect(
        mergeConfig(<String, Object?>{'a': 1}, <String, Object?>{}),
        <String, Object?>{'a': 1},
      );
    });

    test('empty defaults returns overlay non-null entries', () {
      expect(
        mergeConfig(<String, Object?>{}, <String, Object?>{'a': 1, 'b': null}),
        <String, Object?>{'a': 1},
      );
    });

    test('does not mutate input defaults map', () {
      final Map<String, Object?> defaults = <String, Object?>{'a': 1};
      mergeConfig(defaults, <String, Object?>{'a': 2, 'b': 3});
      expect(defaults, <String, Object?>{'a': 1});
    });

    test('both empty yields empty', () {
      expect(mergeConfig(<String, Object?>{}, <String, Object?>{}), <String, Object?>{});
    });
  });
}
