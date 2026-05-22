import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/safe_temp_name_utils.dart';

void main() {
  group('safeTempName', () {
    test('default length is 12', () => expect(safeTempName(), hasLength(12)));

    test('respects requested length', () => expect(safeTempName(length: 5), hasLength(5)));

    test('zero length yields empty string', () => expect(safeTempName(length: 0), ''));

    test('contains only alphanumeric characters', () {
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(safeTempName(length: 32)), isTrue);
    });

    test('two calls are very likely distinct', () {
      // 62^16 keyspace makes a collision astronomically unlikely.
      expect(safeTempName(length: 16) == safeTempName(length: 16), isFalse);
    });

    test('long length produces requested count', () {
      expect(safeTempName(length: 100), hasLength(100));
    });
  });
}
