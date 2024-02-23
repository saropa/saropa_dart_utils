import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_nullable_utils.dart';
// import 'package:test/test.dart';

void main() {
  group('StringExtensions', () {
    test('isNullOrEmpty', () {
      expect(null.isNullOrEmpty, isTrue);
      expect(''.isNullOrEmpty, isTrue);
      expect('Saropa'.isNullOrEmpty, isFalse);
    });
  });
}
