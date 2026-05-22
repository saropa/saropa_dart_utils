import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/cross_field_validation_utils.dart';

void main() {
  group('validateStartBeforeEnd', () {
    test('start less than end is valid (null)', () {
      expect(validateStartBeforeEnd(1, 5), isNull);
    });
    test('start equal to end is valid (null)', () {
      expect(validateStartBeforeEnd(5, 5), isNull);
    });
    test('start greater than end returns default message', () {
      expect(validateStartBeforeEnd(5, 1), 'start must be <= end');
    });
    test('custom field names in message', () {
      expect(
        validateStartBeforeEnd(5, 1, startName: 'from', endName: 'to'),
        'from must be <= to',
      );
    });
    test('works with doubles', () {
      expect(validateStartBeforeEnd(1.5, 1.4), 'start must be <= end');
      expect(validateStartBeforeEnd(1.4, 1.5), isNull);
    });
    test('negative numbers', () {
      expect(validateStartBeforeEnd(-5, -1), isNull);
      expect(validateStartBeforeEnd(-1, -5), 'start must be <= end');
    });
  });

  group('validateOneOfRequired', () {
    test('one non-null value is valid', () {
      expect(validateOneOfRequired(<Object?>[null, 'x', null]), isNull);
    });
    test('non-empty string is valid', () {
      expect(validateOneOfRequired(<Object?>['hello']), isNull);
    });
    test('non-string non-null value is valid', () {
      expect(validateOneOfRequired(<Object?>[42]), isNull);
    });
    test('all null returns default message', () {
      expect(
        validateOneOfRequired(<Object?>[null, null]),
        'At least one of fields is required',
      );
    });
    test('empty string treated as missing', () {
      expect(
        validateOneOfRequired(<Object?>['']),
        'At least one of fields is required',
      );
    });
    test('whitespace-only string treated as missing', () {
      expect(
        validateOneOfRequired(<Object?>['   ']),
        'At least one of fields is required',
      );
    });
    test('empty list returns message', () {
      expect(
        validateOneOfRequired(<Object?>[]),
        'At least one of fields is required',
      );
    });
    test('custom field names in message', () {
      expect(
        validateOneOfRequired(<Object?>[null], fieldNames: 'email or phone'),
        'At least one of email or phone is required',
      );
    });
    test('zero counts as present (non-null non-string)', () {
      expect(validateOneOfRequired(<Object?>[0]), isNull);
    });
    test('false counts as present', () {
      expect(validateOneOfRequired(<Object?>[false]), isNull);
    });
  });
}
