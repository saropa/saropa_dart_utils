import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/data_redaction_utils.dart';

void main() {
  group('redactFields', () {
    test('masks a present field', () {
      final Map<String, Object?> result = redactFields(
        data: <String, Object?>{'name': 'Alice', 'ssn': '123-45-6789'},
        fieldPaths: <String>['ssn'],
        mask: (Object? _) => '***',
      );
      expect(result, <String, Object?>{'name': 'Alice', 'ssn': '***'});
    });

    test('masks multiple fields', () {
      final Map<String, Object?> result = redactFields(
        data: <String, Object?>{'a': 1, 'b': 2, 'c': 3},
        fieldPaths: <String>['a', 'c'],
        mask: (Object? _) => 'X',
      );
      expect(result, <String, Object?>{'a': 'X', 'b': 2, 'c': 'X'});
    });

    test('absent field path ignored', () {
      final Map<String, Object?> result = redactFields(
        data: <String, Object?>{'a': 1},
        fieldPaths: <String>['missing'],
        mask: (Object? _) => 'X',
      );
      expect(result, <String, Object?>{'a': 1});
    });

    test('empty field paths returns unchanged copy', () {
      final Map<String, Object?> result = redactFields(
        data: <String, Object?>{'a': 1},
        fieldPaths: <String>[],
        mask: (Object? _) => 'X',
      );
      expect(result, <String, Object?>{'a': 1});
    });

    test('mask receives the original value', () {
      final Map<String, Object?> result = redactFields(
        data: <String, Object?>{'pw': 'secret'},
        fieldPaths: <String>['pw'],
        mask: (Object? v) => '${(v! as String).length} chars',
      );
      expect(result, <String, Object?>{'pw': '6 chars'});
    });

    test('does not mutate input data', () {
      final Map<String, Object?> data = <String, Object?>{'a': 1};
      redactFields(data: data, fieldPaths: <String>['a'], mask: (Object? _) => 'X');
      expect(data, <String, Object?>{'a': 1});
    });

    test('masks field whose value is null', () {
      final Map<String, Object?> result = redactFields(
        data: <String, Object?>{'a': null},
        fieldPaths: <String>['a'],
        mask: (Object? v) => v == null ? 'was-null' : 'other',
      );
      expect(result, <String, Object?>{'a': 'was-null'});
    });
  });
}
