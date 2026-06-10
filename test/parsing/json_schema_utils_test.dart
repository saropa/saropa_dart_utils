import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/json_schema_utils.dart';

void main() {
  final Map<String, FieldSchema> schema = <String, FieldSchema>{
    'name': const FieldSchema(JsonType.string),
    'age': const FieldSchema(JsonType.integer, isRequired: false),
    'role': const FieldSchema(JsonType.string, allowed: <Object?>['admin', 'user']),
  };

  group('validateJsonSchema', () {
    test('a conforming object has no errors', () {
      final errors = validateJsonSchema(
        <String, Object?>{'name': 'Ada', 'age': 36, 'role': 'admin'},
        schema,
      );
      expect(errors.isEmpty, isTrue);
    });

    test('optional field may be omitted', () {
      final errors = validateJsonSchema(
        <String, Object?>{'name': 'Ada', 'role': 'user'},
        schema,
      );
      expect(errors.isEmpty, isTrue);
    });

    test('missing required field is a missing error', () {
      final errors = validateJsonSchema(<String, Object?>{'role': 'user'}, schema);
      expect(errors.errors.single.code, 'missing');
      expect(errors.errors.single.path, 'name');
    });

    test('wrong type is a type error', () {
      final errors = validateJsonSchema(
        <String, Object?>{'name': 'Ada', 'age': 'old', 'role': 'user'},
        schema,
      );
      expect(errors.errors.single.code, 'type');
      expect(errors.errors.single.path, 'age');
    });

    test('value outside the allowed set is an enum error', () {
      final errors = validateJsonSchema(
        <String, Object?>{'name': 'Ada', 'role': 'guest'},
        schema,
      );
      expect(errors.errors.single.code, 'enum');
      expect(errors.errors.single.path, 'role');
    });

    test('collects multiple errors in one pass', () {
      final errors = validateJsonSchema(<String, Object?>{'age': 'x', 'role': 'guest'}, schema);
      expect(errors.errors, hasLength(3)); // missing name, type age, enum role
    });

    test('non-map input yields a single object-level type error', () {
      final errors = validateJsonSchema(<Object?>[1, 2], schema);
      expect(errors.errors.single.code, 'type');
    });

    test('JsonType.number accepts int and double; integer rejects double', () {
      expect(
        validateJsonSchema(<String, Object?>{'x': 1.5}, <String, FieldSchema>{
          'x': const FieldSchema(JsonType.number),
        }).isEmpty,
        isTrue,
      );
      expect(
        validateJsonSchema(<String, Object?>{'x': 1.5}, <String, FieldSchema>{
          'x': const FieldSchema(JsonType.integer),
        }).isEmpty,
        isFalse,
      );
    });
  });
}
