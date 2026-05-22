import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/typed_positive_utils.dart';

void main() {
  group('TypedPositiveUtils', () {
    test('non-empty value stored', () {
      expect(TypedPositiveUtils('hello').value, 'hello');
    });
    test('value with surrounding spaces preserved as-is', () {
      expect(TypedPositiveUtils(' x ').value, ' x ');
    });
    test('empty string throws ArgumentError', () {
      expect(() => TypedPositiveUtils(''), throwsArgumentError);
    });
    test('whitespace-only throws ArgumentError', () {
      expect(() => TypedPositiveUtils('   '), throwsArgumentError);
    });
  });

  group('PositiveNumber', () {
    test('positive int stored as double', () {
      final PositiveNumber n = PositiveNumber(5);
      expect(n.value, 5.0);
      expect(n.value, isA<double>());
    });
    test('positive double stored', () {
      expect(PositiveNumber(2.5).value, 2.5);
    });
    test('zero throws ArgumentError', () {
      expect(() => PositiveNumber(0), throwsArgumentError);
    });
    test('negative throws ArgumentError', () {
      expect(() => PositiveNumber(-1), throwsArgumentError);
    });
    test('toString includes value', () {
      expect(PositiveNumber(3).toString(), 'PositiveNumber(value: 3.0)');
    });
  });
}
