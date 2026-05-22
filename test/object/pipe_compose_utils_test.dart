import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/object/pipe_compose_utils.dart';

void main() {
  group('pipe', () {
    test('threads input left-to-right through the functions', () {
      final int Function(int) f = pipe<int, int>(<int Function(dynamic)>[
        (dynamic x) => (x as int) + 1,
        (dynamic x) => (x as int) * 2,
      ]);
      expect(f(3), 8); // (3 + 1) * 2
    });

    test('supports a result type different from the input type', () {
      final String Function(int) f = pipe<int, String>(<String Function(dynamic)>[
        (dynamic x) => 'v${x as int}',
      ]);
      expect(f(5), 'v5');
    });

    test('an empty function list returns the input when types match', () {
      final int Function(int) f = pipe<int, int>(<int Function(dynamic)>[]);
      expect(f(7), 7);
    });

    test('throws StateError when the final value is not assignable to R', () {
      // With no transforms, the int input flows straight through; since it is not
      // a String, pipe's final `v is R` (R == String) guard throws StateError.
      final String Function(int) f = pipe<int, String>(<String Function(dynamic)>[]);
      expect(() => f(1), throwsA(isA<StateError>()));
    });
  });

  group('compose', () {
    test('applies g first then f (f(g(x)))', () {
      final String Function(int) f = compose<int, int, String>(
        (int m) => 'v$m',
        (int t) => t + 1,
      );
      expect(f(2), 'v3');
    });

    test('passes the intermediate value through', () {
      final int Function(int) f = compose<int, int, int>(
        (int m) => m * m,
        (int t) => t + 1,
      );
      expect(f(3), 16); // (3 + 1)^2
    });
  });

  group('once', () {
    test('runs the block only on the first invocation', () {
      int calls = 0;
      final void Function() init = once(() => calls++);
      init();
      init();
      init();
      expect(calls, 1);
    });

    test('is a no-op after the first call', () {
      final List<String> log = <String>[];
      final void Function() init = once(() => log.add('ran'));
      init();
      init();
      expect(log, <String>['ran']);
    });
  });
}
