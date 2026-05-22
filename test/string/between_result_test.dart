import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/between_result.dart';

void main() {
  // cspell: disable
  group('BetweenResult', () {
    group('constructor and getters', () {
      test('should expose content and remaining', () {
        const BetweenResult result = BetweenResult('world', 'hello test');
        expect(result.content, 'world');
        expect(result.remaining, 'hello test');
      });

      test('should allow null remaining', () {
        const BetweenResult result = BetweenResult('x', null);
        expect(result.content, 'x');
        expect(result.remaining, isNull);
      });
    });

    group('operator ==', () {
      test('should be equal for identical content and remaining', () {
        expect(const BetweenResult('a', 'b'), const BetweenResult('a', 'b'));
      });

      test('should be equal when both remaining are null', () {
        expect(const BetweenResult('a', null), const BetweenResult('a', null));
      });

      test('should not be equal when content differs', () {
        expect(const BetweenResult('a', 'b') == const BetweenResult('z', 'b'), isFalse);
      });

      test('should not be equal when remaining differs', () {
        expect(const BetweenResult('a', 'b') == const BetweenResult('a', 'z'), isFalse);
      });

      test('should be identical to itself', () {
        const BetweenResult result = BetweenResult('a', 'b');
        expect(result == result, isTrue);
      });

      test('should not equal an unrelated type', () {
        expect(const BetweenResult('a', 'b') == 'a', isFalse);
      });
    });

    group('hashCode', () {
      test('should match for equal instances', () {
        expect(
          const BetweenResult('a', 'b').hashCode,
          const BetweenResult('a', 'b').hashCode,
        );
      });
    });

    group('toString', () {
      test('should render content and remaining', () {
        expect(const BetweenResult('world', 'hello').toString(), 'BetweenResult(world, hello)');
      });

      test('should render null remaining as literal null', () {
        expect(const BetweenResult('world', null).toString(), 'BetweenResult(world, null)');
      });
    });
  });
}
