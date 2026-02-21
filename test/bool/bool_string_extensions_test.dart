import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/bool/bool_string_extensions.dart';

void main() {
  group('BoolStringExtensions', () {
    test('toBoolNullable', () {
      expect('true'.toBoolNullable(), isTrue);
      expect('True'.toBoolNullable(), isTrue);
      expect('false'.toBoolNullable(), isFalse);
      expect('False'.toBoolNullable(), isFalse);
      expect('not a boolean'.toBoolNullable(), isNull);
    });

    test('toBool', () {
      expect('true'.toBool(), isTrue);
      expect('True'.toBool(), isTrue);
      expect('false'.toBool(), isFalse);
      expect('False'.toBool(), isFalse);
      expect('not a boolean'.toBool(), isFalse);
    });
  });

  group('BoolStringNullableExtensions', () {
    test('toBool', () {
      expect(null.toBool(), isFalse);
    });
  });
}
