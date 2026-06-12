/// RFC 5545 recurrence-rule (RRULE) parser — a practical subset, roadmap #591.
///
/// Parses the calendar RRULE string used by iCalendar / Google Calendar exports
/// (`FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;COUNT=10`) into an immutable
/// [RecurrenceRule] value object. Pair with `expandRecurrence` (roadmap #592) to
/// turn a rule into concrete occurrences.
///
/// Supported parts: `FREQ` (DAILY/WEEKLY/MONTHLY/YEARLY), `INTERVAL`, `COUNT`,
/// `UNTIL`, `BYDAY` (weekday codes, no ordinal prefixes), `BYMONTHDAY`,
/// `BYMONTH`, `WKST`. Any other part (e.g. `BYSETPOS`, `BYHOUR`) throws a
/// [FormatException] rather than being silently ignored — a dropped constraint
/// would make the expansion wrong without warning, so the subset boundary is
/// explicit at parse time.
library;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// How often a recurrence repeats. The four calendar frequencies; sub-day
/// frequencies (HOURLY/MINUTELY/SECONDLY) are outside this subset.
enum RecurFrequency {
  /// Every [RecurrenceRule.interval] days.
  /// Audited: 2026-06-12 11:26 EDT
  daily('DAILY'),

  /// Every [RecurrenceRule.interval] weeks.
  /// Audited: 2026-06-12 11:26 EDT
  weekly('WEEKLY'),

  /// Every [RecurrenceRule.interval] months.
  /// Audited: 2026-06-12 11:26 EDT
  monthly('MONTHLY'),

  /// Every [RecurrenceRule.interval] years.
  /// Audited: 2026-06-12 11:26 EDT
  yearly('YEARLY');

  const RecurFrequency(this.token);

  /// The RRULE keyword (`DAILY`, `WEEKLY`, …).
  final String token;
}

/// A day of the week, carrying both its RRULE code and its `DateTime.weekday`
/// number so the iterator can match without a second lookup table.
enum RecurWeekday {
  /// Monday (`MO`).
  /// Audited: 2026-06-12 11:26 EDT
  monday(1, 'MO'),

  /// Tuesday (`TU`).
  /// Audited: 2026-06-12 11:26 EDT
  tuesday(2, 'TU'),

  /// Wednesday (`WE`).
  /// Audited: 2026-06-12 11:26 EDT
  wednesday(3, 'WE'),

  /// Thursday (`TH`).
  /// Audited: 2026-06-12 11:26 EDT
  thursday(4, 'TH'),

  /// Friday (`FR`).
  /// Audited: 2026-06-12 11:26 EDT
  friday(5, 'FR'),

  /// Saturday (`SA`).
  /// Audited: 2026-06-12 11:26 EDT
  saturday(6, 'SA'),

  /// Sunday (`SU`).
  /// Audited: 2026-06-12 11:26 EDT
  sunday(7, 'SU');

  const RecurWeekday(this.isoWeekday, this.code);

  /// Matches `DateTime.weekday` (Monday = 1 … Sunday = 7).
  final int isoWeekday;

  /// The RRULE two-letter code (`MO`, `TU`, …).
  final String code;
}

/// An immutable, parsed RRULE. Construct directly or via [parseRrule]. Defaults
/// mirror RFC 5545: `interval` 1, `weekStart` Monday, all `by*` lists empty.
@immutable
class RecurrenceRule {
  /// Creates a rule. Only [frequency] is required.
  /// Audited: 2026-06-12 11:26 EDT
  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    this.byWeekDays = const <RecurWeekday>[],
    this.byMonthDays = const <int>[],
    this.byMonths = const <int>[],
    this.weekStart = RecurWeekday.monday,
  });

  /// The base repeat unit (daily/weekly/monthly/yearly).
  final RecurFrequency frequency;

  /// Repeat every N units (≥ 1).
  final int interval;

  /// Stop after this many occurrences, or null for unbounded / [until]-bounded.
  final int? count;

  /// Stop on/after this instant (inclusive), or null. Mutually informative with
  /// [count]; a rule may set neither (truly unbounded), either, or both.
  final DateTime? until;

  /// Restrict to these weekdays (chiefly for WEEKLY); empty means no filter.
  final List<RecurWeekday> byWeekDays;

  /// Restrict to these days of the month (1..31, or negative from month end).
  final List<int> byMonthDays;

  /// Restrict to these months (1..12), chiefly for YEARLY.
  final List<int> byMonths;

  /// First day of the week (affects weekly interval math); defaults to Monday.
  final RecurWeekday weekStart;

  @override
  bool operator ==(Object other) =>
      other is RecurrenceRule &&
      other.frequency == frequency &&
      other.interval == interval &&
      other.count == count &&
      other.until == until &&
      other.weekStart == weekStart &&
      const ListEquality<RecurWeekday>().equals(other.byWeekDays, byWeekDays) &&
      const ListEquality<int>().equals(other.byMonthDays, byMonthDays) &&
      const ListEquality<int>().equals(other.byMonths, byMonths);

  @override
  int get hashCode => Object.hash(
    frequency,
    interval,
    count,
    until,
    weekStart,
    Object.hashAll(byWeekDays),
    Object.hashAll(byMonthDays),
    Object.hashAll(byMonths),
  );

  @override
  String toString() =>
      'RecurrenceRule(${frequency.token}, interval: $interval, '
      'count: ${count ?? 'none'}, until: ${until ?? 'none'}, '
      'byWeekDays: $byWeekDays, byMonthDays: $byMonthDays, '
      'byMonths: $byMonths, weekStart: ${weekStart.code})';
}

/// Mutable staging area for [parseRrule]; fields are filled part-by-part, then
/// frozen into a [RecurrenceRule]. `frequency` stays null until seen so its
/// absence (an invalid RRULE) is detectable.
class _RuleParts {
  RecurFrequency? frequency;
  int interval = 1;
  int? count;
  DateTime? until;
  List<RecurWeekday> byWeekDays = const <RecurWeekday>[];
  List<int> byMonthDays = const <int>[];
  List<int> byMonths = const <int>[];
  RecurWeekday weekStart = RecurWeekday.monday;

  /// Dispatches one parsed `NAME=VALUE` part to the matching field. Defined on
  /// the holder (mutating `this`, not a parameter) so each parser stays small.
  /// An unknown name throws so an unsupported constraint can't be dropped.
  /// Audited: 2026-06-12 11:26 EDT
  void apply(String name, String value) {
    // One case per RFC 5545 RRULE part name. Each delegates to a typed parser
    // that validates and throws on malformed input, so a bad value can't reach
    // a field. The default throws to reject any part outside the supported set.
    switch (name) {
      // FREQ is the only required part; _parseFreq maps the token to the enum.
      case 'FREQ':
        frequency = _parseFreq(value);
      // INTERVAL/COUNT must be positive integers (0 or negative is meaningless).
      case 'INTERVAL':
        interval = _parsePositiveInt(value, 'INTERVAL');
      case 'COUNT':
        count = _parsePositiveInt(value, 'COUNT');
      // UNTIL is an inclusive end date/time bound on the series.
      case 'UNTIL':
        until = _parseUntil(value);
      // BY* parts are comma lists that narrow which occurrences are emitted.
      case 'BYDAY':
        byWeekDays = _parseWeekdays(value);
      case 'BYMONTHDAY':
        byMonthDays = _parseMonthDays(value);
      case 'BYMONTH':
        byMonths = _parseMonths(value);
      // WKST sets which weekday starts the week (affects WEEKLY/INTERVAL math).
      case 'WKST':
        weekStart = _parseWeekday(value);
      default:
        throw FormatException('Unsupported RRULE part (outside the parsed subset)', name);
    }
  }
}

const Map<String, RecurFrequency> _freqByToken = <String, RecurFrequency>{
  'DAILY': RecurFrequency.daily,
  'WEEKLY': RecurFrequency.weekly,
  'MONTHLY': RecurFrequency.monthly,
  'YEARLY': RecurFrequency.yearly,
};

final Map<String, RecurWeekday> _weekdayByCode = <String, RecurWeekday>{
  for (final RecurWeekday d in RecurWeekday.values) d.code: d,
};

/// Parses an RRULE string (with or without a leading `RRULE:`) into a
/// [RecurrenceRule]. Part order is irrelevant; a duplicate part takes its last
/// value. Throws [FormatException] when `FREQ` is missing, a part is malformed,
/// or a part outside the supported subset appears.
///
/// Example:
/// ```dart
/// parseRrule('FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;COUNT=10');
/// ```
/// Audited: 2026-06-12 11:26 EDT
RecurrenceRule parseRrule(String input) {
  final _RuleParts parts = _RuleParts();
  // Drop an optional `RRULE:` content-line prefix so both forms parse.
  final String body = input.startsWith('RRULE:') ? input.substring('RRULE:'.length) : input;
  for (final String token in body.split(';')) {
    if (token.trim().isEmpty) {
      continue;
    }
    final int eq = token.indexOf('=');
    if (eq < 0) {
      throw FormatException('RRULE part is not NAME=VALUE', token);
    }
    parts.apply(token.substring(0, eq).trim().toUpperCase(), token.substring(eq + 1).trim());
  }
  final RecurFrequency? freq = parts.frequency;
  if (freq == null) {
    throw FormatException('RRULE is missing required FREQ', input);
  }
  return RecurrenceRule(
    frequency: freq,
    interval: parts.interval,
    count: parts.count,
    until: parts.until,
    byWeekDays: parts.byWeekDays,
    byMonthDays: parts.byMonthDays,
    byMonths: parts.byMonths,
    weekStart: parts.weekStart,
  );
}

RecurFrequency _parseFreq(String value) {
  final RecurFrequency? freq = _freqByToken[value.toUpperCase()];
  if (freq == null) {
    throw FormatException('FREQ must be DAILY/WEEKLY/MONTHLY/YEARLY', value);
  }
  return freq;
}

int _parsePositiveInt(String value, String part) {
  final int? n = int.tryParse(value);
  if (n == null || n < 1) {
    throw FormatException('$part must be a positive integer', value);
  }
  return n;
}

List<RecurWeekday> _parseWeekdays(String value) =>
    value.split(',').map(_parseWeekday).toList(growable: false);

RecurWeekday _parseWeekday(String value) {
  final RecurWeekday? day = _weekdayByCode[value.trim().toUpperCase()];
  if (day == null) {
    throw FormatException('Weekday must be one of MO TU WE TH FR SA SU', value);
  }
  return day;
}

List<int> _parseMonths(String value) {
  final List<int> months = _parseIntList(value, 'BYMONTH');
  // Guard the 1..12 range so a typo (e.g. BYMONTH=13) fails loudly here rather
  // than producing an impossible date downstream.
  for (final int m in months) {
    if (m < 1 || m > 12) {
      throw FormatException('BYMONTH values must be 1..12', value);
    }
  }
  return months;
}

List<int> _parseMonthDays(String value) {
  final List<int> days = _parseIntList(value, 'BYMONTHDAY');
  // 1..31 counts from the start, -1..-31 from the end; 0 is meaningless in RFC
  // 5545 and is the most likely off-by-one typo, so reject it explicitly.
  for (final int d in days) {
    if (d == 0 || d < -31 || d > 31) {
      throw FormatException('BYMONTHDAY values must be 1..31 or -1..-31', value);
    }
  }
  return days;
}

List<int> _parseIntList(String value, String part) =>
    value.split(',').map((String s) => _parseInt(s, part)).toList(growable: false);

int _parseInt(String s, String part) {
  final int? n = int.tryParse(s.trim());
  if (n == null) {
    throw FormatException('$part contains a non-integer value', s);
  }
  return n;
}

/// Matches an RRULE `UNTIL` value: a basic-format date (`yyyyMMdd`) or
/// date-time (`yyyyMMddTHHmmss`), with an optional trailing `Z`. Capturing the
/// fields by group lets [_parseUntil] build the [DateTime] directly — no
/// substring slicing and no `DateTime.parse` (both of which the analyzer flags
/// as unbounded/unvalidated on dynamic input).
/// Audited: 2026-06-12 11:26 EDT
final RegExp _untilPattern = RegExp(r'^(\d{4})(\d{2})(\d{2})(?:T(\d{2})(\d{2})(\d{2}))?Z?$');

/// Parses an RRULE `UNTIL` value into a [DateTime]. A trailing `Z` yields a UTC
/// instant; otherwise the result is local (a floating UNTIL). A missing time
/// defaults to midnight.
/// Audited: 2026-06-12 11:26 EDT
DateTime _parseUntil(String value) {
  final RegExpMatch? m = _untilPattern.firstMatch(value);
  if (m == null) {
    throw FormatException('UNTIL must be yyyyMMdd or yyyyMMddTHHmmss[Z]', value);
  }
  // Year, month, day, hour, minute, second. Groups 4..6 (the time) are null for
  // a date-only UNTIL, so an absent group reads back as 0 (midnight).
  final List<int> f = <int>[
    for (int g = 1; g <= 6; g++) int.tryParse(m.group(g) ?? '') ?? 0,
  ];
  // A trailing `Z` is a real UTC instant; otherwise the value floats (local).
  return value.endsWith('Z')
      ? DateTime.utc(f[0], f[1], f[2], f[3], f[4], f[5])
      : DateTime(f[0], f[1], f[2], f[3], f[4], f[5]);
}
