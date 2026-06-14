/// Rate-limiting schedule shaper: max N per rolling period plus a cooldown —
/// roadmap #612.
///
/// Given a stream of *requested* event times, this computes the actual times at
/// which the events may fire under two constraints applied together:
///
/// - **Cooldown:** at least [cooldown] must elapse between consecutive fires.
/// - **Window quota:** no more than [maxPerPeriod] fires within any rolling
///   window of length [period].
///
/// Events are never dropped — one that would breach a limit is pushed later to
/// the earliest instant that satisfies both rules. This models notification
/// throttling, API call pacing, and "max 3 emails per day, 1 hour apart" style
/// policies that apps otherwise hand-roll with brittle timestamp math.
///
/// Requested times must be supplied in non-decreasing order; the shaper
/// processes them as a queue and assumes monotonic input.
library;

import 'package:collection/collection.dart';

/// Computes rate-limited fire times from requested times.
class RateLimitSchedule {
  /// At most [maxPerPeriod] fires per rolling [period], each at least
  /// [cooldown] after the previous. Requires `maxPerPeriod >= 1` and a
  /// positive [period]; [cooldown] defaults to zero.
  /// Audited: 2026-06-12 11:26 EDT
  RateLimitSchedule({
    required int maxPerPeriod,
    required Duration period,
    Duration cooldown = Duration.zero,
  }) : _maxPerPeriod = _validatedMaxPerPeriod(maxPerPeriod, period, cooldown),
       _period = period,
       _cooldown = cooldown;

  // Validate via a static helper in the initializer so the preconditions hold in
  // release builds (asserts strip) without tripping avoid_exception_in_constructor.
  // A non-positive period would divide the rolling window by zero; a negative
  // cooldown would let fires run backwards.
  static int _validatedMaxPerPeriod(int maxPerPeriod, Duration period, Duration cooldown) {
    // A quota below 1 would admit nothing, leaving the limiter permanently
    // closed; reject it up front rather than silently starving every caller.
    if (maxPerPeriod < 1) {
      throw ArgumentError.value(maxPerPeriod, 'maxPerPeriod', 'must be >= 1');
    }
    if (period <= Duration.zero) {
      throw ArgumentError.value(period, 'period', 'must be positive');
    }
    if (cooldown.isNegative) {
      throw ArgumentError.value(cooldown, 'cooldown', 'must not be negative');
    }
    return maxPerPeriod;
  }

  final int _maxPerPeriod;
  final Duration _period;
  final Duration _cooldown;

  /// Returns the admitted fire times for [requested], in order. Each output is
  /// `>=` its corresponding request and respects the cooldown and window quota.
  ///
  /// Example:
  /// ```dart
  /// final RateLimitSchedule s = RateLimitSchedule(
  ///   maxPerPeriod: 2,
  ///   period: const Duration(hours: 1),
  /// );
  /// // Three requests at the same instant -> third slips to the next window.
  /// s.shape(<DateTime>[t, t, t]); // [t, t, t + 1h]
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  List<DateTime> shape(List<DateTime> requested) {
    final List<DateTime> admitted = <DateTime>[];
    for (final DateTime request in requested) {
      admitted.add(_admit(request, admitted));
    }
    return admitted;
  }

  // Earliest instant >= request that clears both the cooldown gap from the last
  // fire and the rolling-window quota over already-admitted times.
  DateTime _admit(DateTime request, List<DateTime> admitted) {
    DateTime candidate = request;
    if (admitted.isNotEmpty) {
      final DateTime gap = admitted.last.add(_cooldown);
      if (candidate.isBefore(gap)) candidate = gap;
    }
    return _clearWindow(candidate, admitted);
  }

  // Pushes [candidate] forward until fewer than maxPerPeriod admitted times lie
  // in the half-open window (candidate - period, candidate].
  DateTime _clearWindow(DateTime candidate, List<DateTime> admitted) {
    DateTime at = candidate;
    while (true) {
      final List<DateTime> inWindow = _withinWindow(at, admitted);
      // Under quota (and the empty case) means `at` is acceptable as-is.
      final DateTime? oldest = inWindow.firstOrNull;
      if (oldest == null || inWindow.length < _maxPerPeriod) return at;
      // The oldest in-window fire leaves the window one period after it fired;
      // jumping there is the earliest instant that frees a quota slot.
      at = oldest.add(_period);
    }
  }

  // Admitted times within (at - period, at], oldest first (admitted is sorted).
  List<DateTime> _withinWindow(DateTime at, List<DateTime> admitted) {
    final DateTime windowStart = at.subtract(_period);
    return <DateTime>[
      for (final DateTime t in admitted)
        if (t.isAfter(windowStart) && !t.isAfter(at)) t,
    ];
  }
}
