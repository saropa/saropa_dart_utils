import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/expression_evaluator_utils.dart';

void main() {
  group('evaluateExpression', () {
    group('arithmetic', () {
      test('should honor operator precedence', () {
        expect(evaluateExpression('2 + 3 * 4'), equals(14));
      });

      test('should honor parentheses', () {
        expect(evaluateExpression('(2 + 3) * 4'), equals(20));
      });

      test('should do real division and modulo', () {
        expect(evaluateExpression('10 / 4'), equals(2.5));
        expect(evaluateExpression('10 % 3'), equals(1));
      });

      test('should handle unary minus and decimals', () {
        expect(evaluateExpression('-5 + 2.5'), equals(-2.5));
      });
    });

    group('comparison and boolean', () {
      test('should compare numbers', () {
        expect(evaluateExpression('2 > 1'), isTrue);
        expect(evaluateExpression('2 <= 1'), isFalse);
      });

      test('should evaluate equality across types', () {
        expect(evaluateExpression('1 == 1'), isTrue);
        expect(evaluateExpression("'a' == 'a'"), isTrue);
        expect(evaluateExpression('1 != 2'), isTrue);
      });

      test('should evaluate boolean logic and negation', () {
        expect(evaluateExpression('true && false'), isFalse);
        expect(evaluateExpression('true || false'), isTrue);
        expect(evaluateExpression('!true'), isFalse);
      });
    });

    group('variables', () {
      test('should resolve variables of mixed types', () {
        final Object? result = evaluateExpression(
          'age >= 18 && country == "US"',
          variables: <String, Object?>{'age': 21, 'country': 'US'},
        );
        expect(result, isTrue);
      });

      test('should combine variables in arithmetic', () {
        expect(
          evaluateExpression('(a + b) * 2', variables: <String, Object?>{'a': 3, 'b': 4}),
          equals(14),
        );
      });

      test('should throw on an unknown variable', () {
        expect(() => evaluateExpression('x + 1'), throwsFormatException);
      });
    });

    group('errors', () {
      test('should throw on a type mismatch', () {
        expect(() => evaluateExpression('1 + true'), throwsFormatException);
        expect(() => evaluateExpression('2 && 3'), throwsFormatException);
      });

      test('should throw on a trailing token', () {
        expect(() => evaluateExpression('2 2'), throwsFormatException);
      });

      test('should throw on an incomplete expression', () {
        expect(() => evaluateExpression('2 +'), throwsFormatException);
      });

      test('should throw on an unbalanced parenthesis', () {
        expect(() => evaluateExpression('(2 + 3'), throwsFormatException);
      });

      test('should throw on an unknown character', () {
        expect(() => evaluateExpression('2 # 3'), throwsFormatException);
      });
    });
  });

  group('evaluateBool', () {
    test('should return a boolean result', () {
      expect(evaluateBool('age > 18', variables: <String, Object?>{'age': 20}), isTrue);
    });

    test('should throw when the result is not boolean', () {
      expect(() => evaluateBool('2 + 2'), throwsFormatException);
    });
  });
}
