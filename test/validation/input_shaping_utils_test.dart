import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/validation/input_shaping_utils.dart';

void main() {
  group('clampNumber', () {
    test('above max clamps to max as double', () {
      final num r = clampNumber(value: 15, min: 0, max: 10);
      expect(r, 10.0);
      expect(r, isA<double>());
    });
    test('below min clamps to min', () {
      expect(clampNumber(value: -5, min: 0, max: 10), 0.0);
    });
    test('within range unchanged', () {
      expect(clampNumber(value: 5, min: 0, max: 10), 5.0);
    });
    test('isInt rounds result to int', () {
      final num r = clampNumber(value: 5.7, min: 0, max: 10, isInt: true);
      expect(r, 6);
      expect(r, isA<int>());
    });
    test('isInt rounds clamped boundary', () {
      final num r = clampNumber(value: 12.4, min: 0, max: 10, isInt: true);
      expect(r, 10);
    });
    test('default returns double even for whole input', () {
      final num r = clampNumber(value: 5, min: 0, max: 10);
      expect(r, isA<double>());
    });
  });

  group('shapeString', () {
    test('trims surrounding whitespace', () {
      expect(shapeString('  hi  '), 'hi');
    });
    test('no maxLength leaves trimmed string', () {
      expect(shapeString('hello world'), 'hello world');
    });
    test('shorter than maxLength unchanged', () {
      expect(shapeString('hello', maxLength: 10), 'hello');
    });
    test('longer than maxLength truncated with ellipsis', () {
      expect(shapeString('hello world', maxLength: 8), 'hello...');
    });
    test('result length equals maxLength when truncated', () {
      expect(shapeString('abcdefghij', maxLength: 6), hasLength(6));
    });
    test('custom ellipsis', () {
      expect(shapeString('hello world', maxLength: 7, ellipsis: '…'), 'hello …');
    });
    test('maxLength shorter than ellipsis clamps trim start to zero', () {
      // maxLength 2 - ellipsis 3 -> clamp(0) -> whole string replaced by ellipsis.
      expect(shapeString('hello', maxLength: 2), '...');
    });
    test('exactly maxLength not truncated', () {
      expect(shapeString('abcde', maxLength: 5), 'abcde');
    });
  });
}
