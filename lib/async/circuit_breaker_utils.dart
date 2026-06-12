/// Circuit breaker (closed / open-with-timeout) — roadmap #657.
///
/// NOTE: this is a two-state breaker, not a gated three-state one. After
/// [CircuitBreakerUtils.resetTimeout] elapses, `canAttempt` returns true for
/// EVERY caller (there is no single-probe half-open gating), and the circuit
/// only closes when a caller reports `recordSuccess`. Treat the post-timeout
/// window as "retries allowed", not "exactly one probe in flight".
library;

/// Default duration the circuit stays open before retries are allowed again.
/// Audited: 2026-06-12 11:26 EDT
const Duration circuitBreakerDefaultResetTimeout = Duration(seconds: 30);

/// Simple circuit breaker: after [failureThreshold] failures, open for [resetTimeout].
class CircuitBreakerUtils {
  /// Creates a breaker that opens after [failureThreshold] consecutive
  /// failures and stays open for [resetTimeout] before allowing a retry.
  /// Audited: 2026-06-12 11:26 EDT
  CircuitBreakerUtils({
    int failureThreshold = 5,
    Duration resetTimeout = circuitBreakerDefaultResetTimeout,
  }) : _failureThreshold = failureThreshold,
       _resetTimeout = resetTimeout;
  final int _failureThreshold;

  /// Number of failures before the circuit opens.
  /// Audited: 2026-06-12 11:26 EDT
  int get failureThreshold => _failureThreshold;
  final Duration _resetTimeout;

  /// Duration the circuit stays open before retries are allowed again.
  /// Audited: 2026-06-12 11:26 EDT
  Duration get resetTimeout => _resetTimeout;
  int _failures = 0;
  DateTime? _openedAt;
  bool _isClosed = true;

  /// True when the circuit is closed (requests are allowed).
  // ignore: saropa_lints/prefer_correct_handler_name -- 'isClosed' is a boolean state getter, not an event handler; the public API name must stay stable
  bool get isClosed => _isClosed && _openedAt == null;

  /// True when the circuit is open (requests are blocked).
  /// Audited: 2026-06-12 11:26 EDT
  bool get isOpen => !_isClosed;

  /// Resets failure count and closes the circuit.
  /// Audited: 2026-06-12 11:26 EDT
  void recordSuccess() {
    _failures = 0;
    _openedAt = null;
    _isClosed = true;
  }

  /// Records a failure; opens the circuit when the failure threshold is reached.
  /// Audited: 2026-06-12 11:26 EDT
  void recordFailure() {
    _failures++;
    if (_failures >= _failureThreshold) {
      _isClosed = false;
      _openedAt = DateTime.now();
    }
  }

  /// True if a call is allowed (closed or reset timeout elapsed).
  /// Audited: 2026-06-12 11:26 EDT
  bool get canAttempt {
    if (_isClosed) return true;
    final openedAt = _openedAt;
    if (openedAt == null) return true;
    return DateTime.now().difference(openedAt) >= _resetTimeout;
  }

  @override
  String toString() =>
      'CircuitBreakerUtils(failureThreshold: $_failureThreshold, resetTimeout: $_resetTimeout, failures: $_failures, closed: $_isClosed)';
}
