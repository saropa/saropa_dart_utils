/// Parse a standard 5-field cron expression and compute its next run time.
/// Roadmap #158.
///
/// Fields, in order: minute (0-59), hour (0-23), day-of-month (1-31),
/// month (1-12), day-of-week (0-6, Sunday=0; 7 also accepted as Sunday).
/// Each field supports `*`, single values, lists (`1,15`), ranges (`1-5`),
/// and steps (`*/15`, `1-30/5`, `10/5`). Names (JAN, MON) are NOT supported —
/// numbers only — because that keeps the parser small and unambiguous.
library;

/// The longest horizon [CronSchedule.nextRunAfter] will scan before giving up.
/// Four years comfortably covers a leap-day-only schedule (`0 0 29 2 *`) while
/// bounding the worst case for an impossible expression (`0 0 31 2 *`).
const int _maxScanMinutes = 366 * 4 * 24 * 60;

/// A parsed 5-field cron expression. Construct with [CronSchedule.tryParse].
class CronSchedule {
  const CronSchedule._({
    required this.minutes,
    required this.hours,
    required this.daysOfMonth,
    required this.months,
    required this.daysOfWeek,
    required this.isDayOfMonthRestricted,
    required this.isDayOfWeekRestricted,
  });

  /// Allowed minute values (0-59).
  final Set<int> minutes;

  /// Allowed hour values (0-23).
  final Set<int> hours;

  /// Allowed day-of-month values (1-31).
  final Set<int> daysOfMonth;

  /// Allowed month values (1-12).
  final Set<int> months;

  /// Allowed day-of-week values (0-6, Sunday=0).
  final Set<int> daysOfWeek;

  /// Whether the day-of-month field was something other than `*`.
  ///
  /// Needed for the Vixie-cron OR rule: when BOTH day fields are restricted, a
  /// date matches if EITHER matches; when only one is restricted, only that one
  /// applies. Without these flags a `*` (which expands to the full range) would
  /// be indistinguishable from an explicit full range.
  final bool isDayOfMonthRestricted;

  /// Whether the day-of-week field was something other than `*`.
  final bool isDayOfWeekRestricted;

  /// Parses [expression] (5 whitespace-separated fields), or returns `null` if
  /// it is malformed or any field is out of range.
  ///
  /// Example:
  /// ```dart
  /// CronSchedule.tryParse('*/15 9-17 * * 1-5'); // every 15 min, 9-17h, Mon-Fri
  /// CronSchedule.tryParse('bad'); // null
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  static CronSchedule? tryParse(String expression) {
    final List<String> fields = expression.trim().split(RegExp(r'\s+'));
    if (fields.length != 5) {
      return null;
    }

    final Set<int>? minutes = _parseField(fields[0], 0, 59);
    final Set<int>? hours = _parseField(fields[1], 0, 23);
    final Set<int>? daysOfMonth = _parseField(fields[2], 1, 31);
    final Set<int>? months = _parseField(fields[3], 1, 12);
    final Set<int>? daysOfWeek = _parseField(fields[4], 0, 7);
    if (minutes == null ||
        hours == null ||
        daysOfMonth == null ||
        months == null ||
        daysOfWeek == null) {
      return null;
    }

    // Normalize Sunday-as-7 to Sunday-as-0 so matching against
    // (DateTime.weekday % 7) is uniform.
    final Set<int> normalizedDow = daysOfWeek.map((int d) => d == 7 ? 0 : d).toSet();

    return CronSchedule._(
      minutes: minutes,
      hours: hours,
      daysOfMonth: daysOfMonth,
      months: months,
      daysOfWeek: normalizedDow,
      isDayOfMonthRestricted: fields[2] != '*',
      isDayOfWeekRestricted: fields[4] != '*',
    );
  }

  /// Returns the first matching time strictly after [from] (at minute
  /// resolution), or `null` if none occurs within four years.
  ///
  /// Operates in [from]'s own time zone using wall-clock arithmetic. Around a
  /// DST transition the local minute sequence skips or repeats, so a schedule
  /// landing inside the gap can be shifted by the offset change — pass a UTC
  /// [from] if you need DST-independent results.
  /// Audited: 2026-06-12 11:26 EDT
  DateTime? nextRunAfter(DateTime from) {
    // Truncate to the minute and step forward one, so the result is strictly
    // after `from` regardless of its seconds/milliseconds.
    DateTime candidate = _truncateToMinute(from).add(const Duration(minutes: 1));
    for (int i = 0; i < _maxScanMinutes; i++) {
      if (_matches(candidate)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(minutes: 1));
    }
    return null;
  }

  bool _matches(DateTime t) {
    if (!months.contains(t.month) || !hours.contains(t.hour) || !minutes.contains(t.minute)) {
      return false;
    }
    return _dayMatches(t);
  }

  bool _dayMatches(DateTime t) {
    final bool domHit = daysOfMonth.contains(t.day);
    // DateTime.weekday is Mon=1..Sun=7; % 7 maps to cron's Sun=0..Sat=6.
    final bool dowHit = daysOfWeek.contains(t.weekday % 7);

    // Vixie-cron OR semantics when both day fields are constrained.
    if (isDayOfMonthRestricted && isDayOfWeekRestricted) {
      return domHit || dowHit;
    }
    if (isDayOfMonthRestricted) {
      return domHit;
    }
    if (isDayOfWeekRestricted) {
      return dowHit;
    }
    return true;
  }
}

DateTime _truncateToMinute(DateTime t) => t.isUtc
    ? DateTime.utc(t.year, t.month, t.day, t.hour, t.minute)
    : DateTime(t.year, t.month, t.day, t.hour, t.minute);

/// Expands one cron field into the set of allowed values in [min]..[max], or
/// `null` if any token is malformed or out of range.
/// Audited: 2026-06-12 11:26 EDT
Set<int>? _parseField(String field, int min, int max) {
  final Set<int> values = <int>{};
  for (final String part in field.split(',')) {
    if (!_parsePart(part, min, max, values)) {
      return null;
    }
  }
  return values.isEmpty ? null : values;
}

/// Parses a single comma-part (`*`, `n`, `a-b`, `*/n`, `a-b/n`, `a/n`) into
/// [out], returning `false` on any malformed or out-of-range token.
/// Audited: 2026-06-12 11:26 EDT
bool _parsePart(String part, int min, int max, Set<int> out) {
  if (part.isEmpty) {
    return false;
  }

  // Split off an optional step: "<range>/<step>".
  final List<String> stepSplit = part.split('/');
  if (stepSplit.length > 2) {
    return false;
  }
  final String rangePart = stepSplit[0];
  int step = 1;
  if (stepSplit.length == 2) {
    final int? parsedStep = int.tryParse(stepSplit[1]);
    if (parsedStep == null || parsedStep < 1) {
      return false;
    }
    step = parsedStep;
  }

  // Resolve the range part into [rangeStart, rangeEnd]. Cron allows three
  // forms here, each producing a different span that the step then walks.
  int rangeStart;
  int rangeEnd;
  if (rangePart == '*') {
    // Wildcard: the whole legal span for this field (e.g. 0-59 for minutes).
    rangeStart = min;
    rangeEnd = max;
  } else if (rangePart.contains('-')) {
    // Explicit range "a-b": exactly two numeric bounds, low <= high.
    final List<String> bounds = rangePart.split('-');
    if (bounds.length != 2) {
      return false;
    }
    final int? lo = int.tryParse(bounds[0]);
    final int? hi = int.tryParse(bounds[1]);
    // Reject non-numeric bounds and inverted ranges (b < a is meaningless).
    if (lo == null || hi == null || lo > hi) {
      return false;
    }
    rangeStart = lo;
    rangeEnd = hi;
  } else {
    // Single value. A bare "a" is just {a}; but "a/n" (a step with a single
    // start) means "from a to the field max, every n", so widen the end when
    // a step is present.
    final int? single = int.tryParse(rangePart);
    if (single == null) {
      return false;
    }
    rangeStart = single;
    rangeEnd = step > 1 ? max : single;
  }

  // Bounds guard: reject any value outside the field's legal range (e.g. a
  // minute of 60, or day-of-month 32) before emitting.
  if (rangeStart < min || rangeEnd > max) {
    return false;
  }
  // Emit every value in the resolved span, advancing by the step.
  for (int v = rangeStart; v <= rangeEnd; v += step) {
    out.add(v);
  }
  return true;
}
