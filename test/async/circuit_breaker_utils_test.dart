import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/async/circuit_breaker_utils.dart';

void main() {
  group('circuitBreakerDefaultResetTimeout', () {
    test('is 30 seconds', () {
      expect(circuitBreakerDefaultResetTimeout, const Duration(seconds: 30));
    });
  });

  group('CircuitBreakerUtils', () {
    test('starts closed and allows attempts', () {
      final CircuitBreakerUtils cb = CircuitBreakerUtils();
      expect(cb.isClosed, isTrue);
      expect(cb.isOpen, isFalse);
      expect(cb.canAttempt, isTrue);
    });

    test('exposes the configured threshold and timeout', () {
      final CircuitBreakerUtils cb = CircuitBreakerUtils(
        failureThreshold: 2,
        resetTimeout: const Duration(seconds: 1),
      );
      expect(cb.failureThreshold, 2);
      expect(cb.resetTimeout, const Duration(seconds: 1));
    });

    test('opens after failureThreshold consecutive failures', () {
      final CircuitBreakerUtils cb = CircuitBreakerUtils(failureThreshold: 3);
      cb.recordFailure();
      cb.recordFailure();
      expect(cb.isOpen, isFalse); // not yet at threshold
      cb.recordFailure();
      expect(cb.isOpen, isTrue);
      expect(cb.isClosed, isFalse);
    });

    test('blocks attempts while open before the reset timeout elapses', () {
      final CircuitBreakerUtils cb = CircuitBreakerUtils(
        failureThreshold: 1,
        resetTimeout: const Duration(hours: 1),
      );
      cb.recordFailure();
      expect(cb.isOpen, isTrue);
      // Reset timeout not elapsed, so no attempt allowed.
      expect(cb.canAttempt, isFalse);
    });

    test('allows a probe attempt once the reset timeout has elapsed', () {
      final CircuitBreakerUtils cb = CircuitBreakerUtils(
        failureThreshold: 1,
        resetTimeout: Duration.zero,
      );
      cb.recordFailure();
      expect(cb.isOpen, isTrue);
      // Zero timeout means the half-open probe is immediately allowed.
      expect(cb.canAttempt, isTrue);
    });

    test('recordSuccess resets failures and closes the circuit', () {
      final CircuitBreakerUtils cb = CircuitBreakerUtils(failureThreshold: 1);
      cb.recordFailure();
      expect(cb.isOpen, isTrue);
      cb.recordSuccess();
      expect(cb.isClosed, isTrue);
      expect(cb.isOpen, isFalse);
      expect(cb.canAttempt, isTrue);
    });

    test('toString reports state fields', () {
      final CircuitBreakerUtils cb = CircuitBreakerUtils(
        failureThreshold: 4,
        resetTimeout: const Duration(seconds: 2),
      );
      expect(
        cb.toString(),
        'CircuitBreakerUtils(failureThreshold: 4, resetTimeout: 0:00:02.000000, failures: 0, closed: true)',
      );
    });
  });
}
