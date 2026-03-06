/// Exponential backoff helper (roadmap #677).
library;

/// Max shift for 2^attempt to avoid int overflow (2^31 is still safe for positive int).
const int _maxBackoffAttemptShift = 31;

/// Max milliseconds for a single Duration (positive 32-bit int).
const int _maxDurationMilliseconds = 0x7fffffff;

/// Default base delay for exponential backoff.
const Duration exponentialBackoffDefaultBase = Duration(milliseconds: 100);

/// Returns delay for attempt [attempt] (0-based): base * 2^attempt, capped at [maxDelay].
Duration exponentialBackoff(
  int attempt, {
  Duration base = exponentialBackoffDefaultBase,
  Duration? maxDelay,
}) {
  final int ms = (base.inMilliseconds * (1 << attempt.clamp(0, _maxBackoffAttemptShift))).clamp(
    0,
    _maxDurationMilliseconds,
  );
  final Duration d = Duration(milliseconds: ms);
  if (maxDelay != null && d > maxDelay) return maxDelay;
  return d;
}
