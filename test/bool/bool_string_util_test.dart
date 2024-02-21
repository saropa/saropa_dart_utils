import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/bool/bool_string_utils.dart';

void main() {
  group('BoolStringExtensions', () {
    test('toBoolNullable', () {
      expect('true'.toBoolNullable(), true);
      expect('True'.toBoolNullable(), true);
      expect('false'.toBoolNullable(), false);
      expect('False'.toBoolNullable(), false);
      expect('not a boolean'.toBoolNullable(), null);
    });

    test('toBool', () {
      expect('true'.toBool(), true);
      expect('True'.toBool(), true);
      expect('false'.toBool(), false);
      expect('False'.toBool(), false);
      expect('not a boolean'.toBool(), false);
    });
  });

  group('BoolStringNullableExtensions', () {
    test('toBool', () {
      expect(null.toBool(), false);
    });
  });
}
