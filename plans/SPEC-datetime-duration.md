# SPEC: Duration.displayTime / formatDuration / reverse — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** `lib/datetime/duration_clock_format_extensions.dart` (a new `extension on Duration`; the existing top-level `formatDuration` stays in `duration_format_utils.dart`)
**Portability:** Pure Dart. No Flutter, no `intl`/`quiver`. The app version depends on two helpers: `String.pluralize` (already in the library — `lib/string/string_text_extensions.dart`) and `Iterable<String>.joinNotNullOrEmpty` (a Saropa-Contacts-local helper, NOT in the library — see Source notes for the inlined equivalent).

## Overlap with existing library code (read first)

The library **already has** a top-level `formatDuration(Duration d, {...})` in `lib/datetime/duration_format_utils.dart`. It is **not** the same function as the app's `Duration.formatDuration()` extension — the signatures, units, and outputs diverge:

| Aspect | Library `formatDuration(d, ...)` (existing) | App `d.formatDuration(...)` (proposed) |
|---|---|---|
| Form | Top-level function, `d` as first arg | Extension method on `Duration` |
| Largest unit | **days** (`inDays`) | **hours** (`inHours`, never rolls into days) |
| Smallest unit | milliseconds | **microseconds** (`μs` / `microsecond`) |
| Zero result | `'0s'` / `'0 seconds'` | `'Instantaneous'` |
| Separator | space (`'2h 30m'`) | `', '` (`'02 hrs, 30 mins'`) |
| Leading zeros | none | optional via `showLeadingZeros` |
| Short labels | `h`/`m`/`s`/`ms` | `hr`/`min`/`sec`/`ms`/`μs` (or long `hour`/`minute`/...) |

So this is **partial-overlap**: the human-readable `formatDuration` concept exists but the two outputs are deliberately different. Recommendation: rename the proposed extension method to avoid a confusing same-name collision (e.g. `humanizeUnits()` or `toUnitList()`), OR keep it as `formatDuration` knowing one is top-level and one is an extension. The genuinely **net-new** members are:

- **`displayTime({bool showHours})`** — `HH:MM:SS.mmm` / `MM:SS.mmm` zero-padded **clock** format. The library has no clock-style duration formatter. This is the primary net-new value.
- **`reverse()`** — sign negation (`d * -1`). No `Duration` negate/reverse exists in the library today (grep of `lib/datetime` returns none).

## Purpose — what it does + why it is general-purpose (not proprietary)

A `Duration` extension with three formatters, all pure arithmetic on `Duration` fields — no contact, no app, no locale state:

- **`displayTime`** — renders a stopwatch/media-style clock string. `Duration(h:1,m:30,s:45,ms:123).displayTime()` -> `'01:30:45.123'`; with `showHours: false` -> `'30:45.123'`. Generic for timers, audio/video scrubbers, elapsed-time labels.
- **`formatDuration`** — renders a comma-joined human list of non-zero units down to microseconds, short or long words, with optional leading zeros; `Duration.zero` -> `'Instantaneous'`. Generic profiling/benchmark/elapsed display.
- **`reverse`** — returns the sign-negated duration. Generic.

None of these touch app domain logic, Font Awesome, l10n, or Crashlytics. The only app coupling is the two string helpers and the `debug()`-based catch, both removed below.

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging stripped)

```dart
extension DurationUtils on Duration {
  /// Formats duration as a time display string.
  ///
  /// - When [showHours] is true: returns 'HH:MM:SS.mmm'
  /// - When [showHours] is false: returns 'MM:SS.mmm'
  String displayTime({bool showHours = true}) {
    final String hoursStr = showHours ? '${inHours.toString().padLeft(2, '0')}:' : '';
    final String minutesStr = '${(inMinutes % 60).toString().padLeft(2, '0')}:';
    final String secondsStr = (inSeconds % 60).toString().padLeft(2, '0');
    final String millisecondsStr = '.${(inMilliseconds % 1000).toString().padLeft(3, '0')}';

    return '$hoursStr$minutesStr$secondsStr$millisecondsStr';
  }

  /// Formats a [Duration] to a human-readable string.
  ///
  /// The [showLeadingZeros] parameter controls whether leading zeros are shown.
  /// If [showLeadingZeros] is `false`, single-digit numbers are not zero-padded.
  ///
  /// The [shortForm] parameter controls whether the short word forms are shown.
  ///
  /// Zero-valued units are omitted. `Duration.zero` returns 'Instantaneous'.
  String? formatDuration({bool showLeadingZeros = false, final bool shortForm = true}) {
    if (this == Duration.zero) {
      return 'Instantaneous';
    }

    // Pad with a leading zero only when < 10 AND showLeadingZeros is true.
    String twoDigits(int n) => n >= 10 || !showLeadingZeros ? '$n' : '0$n';

    final int minRemainder = inMinutes.remainder(60);
    final int secRemainder = inSeconds.remainder(60);
    final int millisecondRemainder = inMilliseconds.remainder(1000);
    final int microRemainder = inMicroseconds.remainder(1000);

    final List<String> formatted = <String>[
      if (inHours != 0)
        '${twoDigits(inHours)} ${(shortForm ? 'hr' : 'hour').pluralize(inHours, simple: true)}',
      if (minRemainder != 0)
        '${twoDigits(minRemainder)} ${(shortForm ? 'min' : 'minute').pluralize(minRemainder, simple: true)}',
      if (secRemainder != 0)
        '${twoDigits(secRemainder)} ${(shortForm ? 'sec' : 'second').pluralize(secRemainder, simple: true)}',
      if (millisecondRemainder != 0)
        '$millisecondRemainder ${shortForm ? 'ms' : 'millisecond'.pluralize(millisecondRemainder, simple: true)}',
      if (microRemainder != 0)
        // 'microsecond' short form is the Greek mu: 'μs'.
        '$microRemainder ${shortForm ? 'μs' : 'microsecond'.pluralize(microRemainder, simple: true)}',
    ];

    // joinNotNullOrEmpty: join non-null, non-empty entries with ', '.
    return formatted.where((String s) => s.isNotEmpty).join(', ');
  }

  /// Returns the sign-negated duration (positive <-> negative).
  Duration reverse() => this * -1;
}
```

**Source notes / app-coupling removed:**

- **Excluded — none of the members are proprietary.** All three are general-purpose; nothing contact-domain, icon, search-query, or l10n-specific exists in this file.
- **`debug()` / `debugException` try-catch removed.** The app wrapped each method in `try/catch` returning `''` / `null` / `this` and called `debugException(error, stack)`. The arithmetic cannot throw (no division, no parsing, integer remainders are total), so the catch was dead defensiveness; dropped per "strip debug logging." NOTE: with the catch gone, `formatDuration`'s return type could tighten from `String?` to `String` (it never actually returns null on the happy path) — decide on adoption.
- **`joinNotNullOrEmpty` inlined** as `.where((s) => s.isNotEmpty).join(', ')` above — that Saropa-Contacts string helper is not in the library and is not worth importing for one call. (The `formatted` list already contains only non-null strings, so the filter just drops any empties.)
- **`pluralize(int, {simple: true})`** is already in the library (`lib/string/string_text_extensions.dart`) — keep using it.
- **`μ` (Greek small letter mu)** is the microsecond short-form prefix. Represented as a Dart escape here per the no-raw-non-ASCII rule; write it as `'μs'` in the adopted source.

## Test cases — existing tests verbatim (from `test/lib/utils/primitive/date_time/date_time_primitive_test.dart`)

```dart
group('DurationUtils', () {
  test('displayTime formats correctly with hours', () {
    const Duration duration = Duration(hours: 1, minutes: 30, seconds: 45, milliseconds: 123);
    expect(duration.displayTime(), '01:30:45.123');
  });

  test('displayTime formats correctly without hours', () {
    const Duration duration = Duration(minutes: 5, seconds: 30, milliseconds: 50);
    expect(duration.displayTime(showHours: false), '05:30.050');
  });

  test('formatDuration returns Instantaneous for zero', () {
    expect(Duration.zero.formatDuration(), 'Instantaneous');
  });

  test('formatDuration formats hours correctly', () {
    const Duration duration = Duration(hours: 2, minutes: 30);
    final String? result = duration.formatDuration();
    expect(result, contains('2 hrs'));
    expect(result, contains('30 mins'));
  });

  test('formatDuration formats milliseconds correctly', () {
    const Duration duration = Duration(milliseconds: 137);
    final String? result = duration.formatDuration();
    expect(result, contains('137 ms'));
  });

  test('formatDuration formats microseconds correctly', () {
    const Duration duration = Duration(microseconds: 456);
    final String? result = duration.formatDuration();
    expect(result, contains('456'));
  });

  test('reverse negates duration', () {
    const Duration positive = Duration(hours: 1);
    final Duration negative = positive.reverse();
    expect(negative.inHours, -1);
  });
});
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**`displayTime`:**
- Zero: `Duration.zero.displayTime()` -> `'00:00:00.000'`; `showHours: false` -> `'00:00.000'`.
- Hours overflow past a day: `Duration(hours: 25, minutes: 1)` -> `'25:01:00.000'` (hours is NOT mod-24 — confirm and lock this in a test; it differs from the library's day-aware formatter).
- Triple-digit hours: `Duration(hours: 100)` -> `'100:00:00.000'` (padLeft(2) does not truncate, just no extra pad).
- **Negative durations** (the sharp edge): `Duration(seconds: -5).displayTime()` — `(inSeconds % -... )` and `padLeft` on a string already containing `'-'` produce surprising output (e.g. `'-5'.padLeft(2)` stays `'-5'`, but `inMinutes % 60` on a negative goes negative too). Add tests pinning the exact current behavior, OR decide to `abs()` / prefix `'-'` deliberately. This is the biggest untested risk.
- Millisecond boundary: `Duration(milliseconds: 999)` -> `'...00:00.999'`; `Duration(milliseconds: 1000)` rolls into `'...00:01.000'`.
- Sub-millisecond input: `Duration(microseconds: 500)` -> `'.000'` (microseconds are dropped by `displayTime`; assert they don't appear).
- Exactly 60s / 60min carry: `Duration(seconds: 60)` -> `'00:01:00.000'`; `Duration(minutes: 60)` -> `'01:00:00.000'`.

**`formatDuration`:**
- Each unit in isolation: hours-only, minutes-only, seconds-only, ms-only, μs-only.
- Full stack: `Duration(hours:1, minutes:2, seconds:3, milliseconds:4, microseconds:5)` — assert exact joined `', '` string and field order.
- `shortForm: false` long words: assert `'hour'`/`'hours'`, `'minute'`/`'minutes'`, `'second'`, `'millisecond'`, `'microsecond'` pluralization at 1 vs N.
- `showLeadingZeros: true` vs `false`: `Duration(minutes: 5)` -> `'5 mins'` vs `'05 mins'`.
- Singular boundaries: `Duration(hours: 1)` -> `'1 hr'` (short) / `'1 hour'` (long); confirm `pluralize` gives singular at exactly 1.
- Unit skipping: `Duration(hours: 1, seconds: 3)` (zero minutes) -> omits minutes; assert `'1 hr, 3 secs'` with no `'0 min'`.
- Negative duration: `Duration(seconds: -90).formatDuration()` — `remainder` keeps the sign, so expect `'-1 min, -30 secs'` (or define and assert intended behavior; currently it leaks negatives into every unit).
- Extremes: `Duration(days: 10000)` formats as a large hours count (no day rollup — assert hours, e.g. `240000 hrs`); near-`maxFinite` microseconds for overflow safety.
- `Duration.zero` always `'Instantaneous'` regardless of `shortForm`/`showLeadingZeros` flags.

**`reverse`:**
- `Duration.zero.reverse()` == `Duration.zero` (no `-0` surprise).
- Already-negative -> positive: `Duration(hours: -1).reverse().inHours == 1`.
- Double reverse is identity: `d.reverse().reverse() == d`.
- Extreme: very large duration negates without overflow within `int` range.

**Cross-cutting:** No locale/DST/leap-year concerns (operates on `Duration`, not wall-clock dates) — explicitly note these are N/A so reviewers don't expect them. No null/empty/unicode-input cases (the receiver is a non-null `Duration`); the only unicode output is the `μ` short form — add a test asserting `Duration(microseconds: 2).formatDuration()` contains `'μs'` to guard against accidental ASCII flattening of that glyph.
