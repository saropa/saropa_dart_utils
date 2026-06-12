import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/stats/rolling_correlation_utils.dart';

void main() {
  group('rollingCorrelation', () {
    test('perfectly correlated windows are 1.0', () {
      // y = 2x within every window, so each correlation is +1.
      final List<double> result = rollingCorrelation(
        <num>[1, 2, 3, 4],
        <num>[2, 4, 6, 8],
        3,
      );
      expect(result, hasLength(2));
      expect(result[0], closeTo(1.0, 1e-9));
      expect(result[1], closeTo(1.0, 1e-9));
    });

    test('anti-correlated windows are -1.0', () {
      final List<double> result = rollingCorrelation(
        <num>[1, 2, 3, 4],
        <num>[8, 6, 4, 2],
        3,
      );
      expect(result[0], closeTo(-1.0, 1e-9));
      expect(result[1], closeTo(-1.0, 1e-9));
    });

    test('a constant window yields NaN (zero variance)', () {
      // The y window [5,5,5] has no variance, so correlation is undefined.
      final List<double> result = rollingCorrelation(
        <num>[1, 2, 3],
        <num>[5, 5, 5],
        3,
      );
      expect(result, hasLength(1));
      expect(result[0], isNaN);
    });

    test('output length is x.length - window + 1', () {
      final List<double> result = rollingCorrelation(
        <num>[1, 2, 3, 4, 5, 6],
        <num>[2, 1, 4, 3, 6, 5],
        2,
      );
      expect(result, hasLength(5));
    });

    test('input shorter than the window returns empty', () {
      expect(rollingCorrelation(<num>[1, 2], <num>[3, 4], 3), isEmpty);
    });

    test('mismatched lengths are rejected', () {
      expect(
        () => rollingCorrelation(<num>[1, 2, 3], <num>[1, 2], 2),
        throwsA(isA<AssertionError>()),
      );
    });

    test('window below 2 is rejected', () {
      expect(
        () => rollingCorrelation(<num>[1, 2, 3], <num>[1, 2, 3], 1),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
