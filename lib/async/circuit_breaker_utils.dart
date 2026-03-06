/// Circuit breaker (open/half-open/closed) — roadmap #657.
library;

/// Default duration the circuit stays open before allowing a retry (half-open).
const Duration circuitBreakerDefaultResetTimeout = Duration(seconds: 30);

/// Simple circuit breaker: after [failureThreshold] failures, open for [resetTimeout].
class CircuitBreaker {
  CircuitBreaker({
    int failureThreshold = 5,
    Duration resetTimeout = circuitBreakerDefaultResetTimeout,
  }) : _failureThreshold = failureThreshold,
       _resetTimeout = resetTimeout;
  final int _failureThreshold;

  /// Number of failures before the circuit opens.
  int get failureThreshold => _failureThreshold;
  final Duration _resetTimeout;

  /// Duration the circuit stays open before allowing a retry (half-open).
  Duration get resetTimeout => _resetTimeout;
  int _failures = 0;
  DateTime? _openedAt;
  bool _isClosed = true;

  /// True when the circuit is closed (requests are allowed).
  bool get isClosed => _isClosed && _openedAt == null;

  /// True when the circuit is open (requests are blocked).
  bool get isOpen => !_isClosed;

  /// Resets failure count and closes the circuit.
  void recordSuccess() {
    _failures = 0;
    _openedAt = null;
    _isClosed = true;
  }

  /// Records a failure; opens the circuit when the failure threshold is reached.
  void recordFailure() {
    _failures++;
    if (_failures >= _failureThreshold) {
      _isClosed = false;
      _openedAt = DateTime.now();
    }
  }

  /// True if a call is allowed (closed or reset timeout elapsed).
  bool get canAttempt {
    if (_isClosed) return true;
    final openedAt = _openedAt;
    if (openedAt == null) return true;
    return DateTime.now().difference(openedAt) >= _resetTimeout;
  }

  @override
  String toString() =>
      'CircuitBreaker(failureThreshold: $_failureThreshold, resetTimeout: $_resetTimeout, failures: $_failures, closed: $_isClosed)';
}
