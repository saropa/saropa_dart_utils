// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/testing/debug_utils.dart';

void main() {
  group('prettyPrint', () {
    test('renders null as the literal string null', () {
      expect(prettyPrint(null), 'null');
    });

    test('renders an empty map as {}', () {
      expect(prettyPrint(<String, dynamic>{}), '{}');
    });

    test('renders an empty list as []', () {
      expect(prettyPrint(<dynamic>[]), '[]');
    });

    test('renders a scalar via toString', () {
      expect(prettyPrint(42), '42');
    });

    test('renders a flat map (top-level entries get the zero-width pad)', () {
      // At indent 0 the pad is empty, so top-level entries have no leading
      // spaces; nesting deeper adds two spaces per level.
      expect(prettyPrint(<String, dynamic>{'a': 1}), '{\na: 1\n}');
    });

    test('renders a flat list across lines', () {
      expect(prettyPrint(<dynamic>[1, 2]), '[\n1,\n2\n]');
    });

    test('renders nested map and list', () {
      expect(
        prettyPrint(<String, dynamic>{
          'a': 1,
          'b': <dynamic>[2, 3],
        }),
        '{\na: 1\nb: [\n  2,\n  3\n  ]\n}',
      );
    });
  });

  group('dumpIterable', () {
    test('renders the whole list when within maxItems', () {
      expect(dumpIterable(<int>[1, 2, 3]), '[1, 2, 3]');
    });

    test('truncates and appends the total when over maxItems', () {
      expect(dumpIterable(<int>[1, 2, 3, 4], maxItems: 2), '[1, 2]... (4 total)');
    });

    test('exactly maxItems is not truncated', () {
      expect(dumpIterable(<int>[1, 2], maxItems: 2), '[1, 2]');
    });

    test('empty iterable renders as []', () {
      expect(dumpIterable(<int>[]), '[]');
    });
  });

  group('assertEqualsWithTolerance', () {
    test('passes when within tolerance', () {
      expect(() => assertEqualsWithTolerance(0.1 + 0.2, 0.3, 1e-9), returnsNormally);
    });

    test('passes when exactly equal', () {
      expect(() => assertEqualsWithTolerance(5, 5, 0), returnsNormally);
    });

    test('throws AssertionError when outside tolerance', () {
      expect(
        () => assertEqualsWithTolerance(1, 2, 0.5),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('rangeInt', () {
    test('ascending range is exclusive of end', () {
      expect(rangeInt(0, 5), <int>[0, 1, 2, 3, 4]);
    });

    test('descending range with negative step', () {
      expect(rangeInt(5, 0, step: -2), <int>[5, 3, 1]);
    });

    test('empty when start equals end', () {
      expect(rangeInt(3, 3), <int>[]);
    });

    test('empty when step direction cannot reach end', () {
      expect(rangeInt(0, 5, step: -1), <int>[]);
    });

    test('custom positive step', () {
      expect(rangeInt(0, 10, step: 3), <int>[0, 3, 6, 9]);
    });
  });

  group('rangeDouble', () {
    test('ascending range exclusive of end', () {
      expect(rangeDouble(0, 1, 0.5), <double>[0.0, 0.5]);
    });

    test('empty when step cannot reach end', () {
      expect(rangeDouble(0, 1, -0.5), <double>[]);
    });

    test('descending range with negative step', () {
      expect(rangeDouble(2, 0, -1), <double>[2.0, 1.0]);
    });
  });

  group('repeatValue', () {
    test('repeats a value n times', () {
      expect(repeatValue('x', 3), <String>['x', 'x', 'x']);
    });

    test('zero count yields empty list', () {
      expect(repeatValue('x', 0), <String>[]);
    });

    test('works for non-string types', () {
      expect(repeatValue(7, 2), <int>[7, 7]);
    });
  });

  group('timed', () {
    test('returns a non-negative duration', () {
      final Duration elapsed = timed(() {});
      expect(elapsed, greaterThanOrEqualTo(Duration.zero));
    });

    test('runs the provided function', () {
      int counter = 0;
      timed(() => counter++);
      expect(counter, 1);
    });
  });

  group('retryUntil', () {
    test('returns true as soon as the predicate succeeds', () {
      int calls = 0;
      final bool result = retryUntil(() {
        calls++;
        return calls == 2;
      });
      expect(result, isTrue);
      expect(calls, 2);
    });

    test('returns false when every attempt fails within maxAttempts', () {
      int calls = 0;
      final bool result = retryUntil(
        () {
          calls++;
          return false;
        },
        maxAttempts: 3,
      );
      expect(result, isFalse);
      expect(calls, 3);
    });

    test('predicate succeeding on first call returns true immediately', () {
      int calls = 0;
      final bool result = retryUntil(() {
        calls++;
        return true;
      });
      expect(result, isTrue);
      expect(calls, 1);
    });
  });
}
