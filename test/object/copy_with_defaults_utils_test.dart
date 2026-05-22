import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/copy_with_defaults_utils.dart';

void main() {
  group('copyWithDefaults', () {
    test('source values override default values', () {
      final Map<String, dynamic> result = copyWithDefaults(
        <String, dynamic>{'a': 2},
        <String, dynamic>{'a': 1, 'b': 1},
      );
      expect(result, <String, dynamic>{'a': 2, 'b': 1});
    });

    test('fills in keys missing from the source from defaults', () {
      final Map<String, dynamic> result = copyWithDefaults(
        <String, dynamic>{'name': 'Alice'},
        <String, dynamic>{'name': 'Anon', 'age': 0},
      );
      expect(result, <String, dynamic>{'name': 'Alice', 'age': 0});
    });

    test('deep-merges nested maps', () {
      final Map<String, dynamic> result = copyWithDefaults(
        <String, dynamic>{
          'config': <String, dynamic>{'theme': 'dark'},
        },
        <String, dynamic>{
          'config': <String, dynamic>{'theme': 'light', 'fontSize': 12},
        },
      );
      expect(result, <String, dynamic>{
        'config': <String, dynamic>{'theme': 'dark', 'fontSize': 12},
      });
    });

    test('an empty source yields the defaults', () {
      final Map<String, dynamic> result = copyWithDefaults(
        <String, dynamic>{},
        <String, dynamic>{'a': 1},
      );
      expect(result, <String, dynamic>{'a': 1});
    });

    test('does not mutate the input maps', () {
      final Map<String, dynamic> source = <String, dynamic>{'a': 2};
      final Map<String, dynamic> defaults = <String, dynamic>{'a': 1, 'b': 1};
      copyWithDefaults(source, defaults);
      expect(source, <String, dynamic>{'a': 2});
      expect(defaults, <String, dynamic>{'a': 1, 'b': 1});
    });
  });
}
