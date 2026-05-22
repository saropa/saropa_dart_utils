import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/exponential_backoff_utils.dart';

void main() {
  group('exponentialBackoffDefaultBase', () {
    test('is 100ms', () {
      expect(exponentialBackoffDefaultBase, const Duration(milliseconds: 100));
    });
  });

  group('exponentialBackoff', () {
    test('doubles the base delay per attempt (0-based)', () {
      const Duration base = Duration(milliseconds: 100);
      expect(exponentialBackoff(0, base: base), const Duration(milliseconds: 100));
      expect(exponentialBackoff(1, base: base), const Duration(milliseconds: 200));
      expect(exponentialBackoff(2, base: base), const Duration(milliseconds: 400));
      expect(exponentialBackoff(3, base: base), const Duration(milliseconds: 800));
    });

    test('uses the default base when none is given', () {
      expect(exponentialBackoff(0), const Duration(milliseconds: 100));
      expect(exponentialBackoff(2), const Duration(milliseconds: 400));
    });

    test('caps the result at maxDelay', () {
      final Duration d = exponentialBackoff(
        10,
        base: const Duration(milliseconds: 100),
        maxDelay: const Duration(seconds: 1),
      );
      expect(d, const Duration(seconds: 1));
    });

    test('returns the computed value when below maxDelay', () {
      final Duration d = exponentialBackoff(
        1,
        base: const Duration(milliseconds: 100),
        maxDelay: const Duration(seconds: 1),
      );
      expect(d, const Duration(milliseconds: 200));
    });

    test('does not overflow at a very large attempt count', () {
      // Shift is clamped internally; the result must remain a finite Duration.
      final Duration d = exponentialBackoff(1000, base: const Duration(milliseconds: 100));
      expect(d.inMilliseconds, greaterThan(0));
    });
  });
}
