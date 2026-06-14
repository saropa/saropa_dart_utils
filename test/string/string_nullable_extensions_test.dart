// Tests deliberately exercise the deprecated `isNullOrEmpty` getter to lock in
// its behavior while it remains for source compatibility; suppress the
// same-package deprecation warning for the whole file.
// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_nullable_extensions.dart';
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
