# TEST COVERAGE — migrated-util test cases harvested from Saropa Contacts

**Type:** Test-coverage offering (not a bug)
**Status:** Open — for maintainer review

---

## Why this exists

Saropa Contacts removed its local copies of these utilities once they shipped in
saropa_dart_utils (the ENH-001..008 wave + the 1.4.x calendar/name utils). The
tests below were testing **external** (now-library) code, so they were deleted
from the consumer. They are reproduced here verbatim so the maintainer can check
them against the library's own suite and fill any gap — the goal is BULLETPROOF
methods with massive coverage. Some may already be covered; adopt only the deltas.

Each block names the library symbol it targets.

---

## `String.removeLastChars(int count)` — `lib/string/string_manipulation_extensions.dart`

```dart
group('removeLastChars', () {
  test('removes last 3 chars from "HelloWorld"', () {
    expect('HelloWorld'.removeLastChars(3), 'HelloWo');
  });
  test('removes last 5 chars from "Hello"', () {
    expect('Hello'.removeLastChars(5), '');
  });
  test('removes more chars than string length returns empty', () {
    expect('Hi'.removeLastChars(10), '');
  });
  test('removes 0 chars returns original', () {
    expect('Hello'.removeLastChars(0), 'Hello');
  });
  test('removes negative chars returns original', () {
    expect('Hello'.removeLastChars(-5), 'Hello');
  });
  test('empty string returns empty', () {
    expect(''.removeLastChars(3), '');
  });
  test('single char removed from single char string', () {
    expect('A'.removeLastChars(1), '');
  });
  test('unicode string handling', () {
    // cspell: ignore Héllo
    expect('Héllo'.removeLastChars(2), 'Hél');
  });
});
```

Note the UTF-16 vs grapheme edge: `'Héllo'.removeLastChars(2) == 'Hél'` holds when
`é` is a single code unit (U+00E9). If `é` were the combining sequence `e` + U+0301,
a code-unit count would strip the accent only. Worth an explicit decomposed-input test.

---

## `DateTimeCalendarExtensions` (on `DateTime`) — `lib/datetime/date_time_calendar_extensions.dart`

```dart
group('DateWeekdayExtensions', () {
  test('mostRecentSunday finds correct Sunday', () {
    // Wednesday, June 12, 2024
    final DateTime wednesday = DateTime(2024, 6, 12);
    final DateTime sunday = wednesday.mostRecentSunday;
    expect(sunday.weekday, DateTime.sunday);
    expect(sunday, DateTime(2024, 6, 9));
  });
  test('dayOfYear calculates correctly', () {
    expect(DateTime(2024, 1, 1).dayOfYear, 1);
    expect(DateTime(2024, 12, 31).dayOfYear, 366); // Leap year
    expect(DateTime(2023, 12, 31).dayOfYear, 365);
  });
  test('weekOfYear calculates correctly', () {
    expect(DateTime(2024, 1, 1).weekOfYear, 1);
    expect(DateTime(2024, 1, 7).weekOfYear, 1);
  });
  test('weekNumber handles edge cases', () {
    // Week 1 of next year scenario
    final DateTime lateDecember = DateTime(2024, 12, 30);
    final int week = lateDecember.weekNumber();
    expect(week, greaterThan(0));
    expect(week, lessThanOrEqualTo(53));
  });
});
```

---

## `MonthUtils` — `lib/datetime/date_constants.dart`

```dart
group('MonthUtils', () {
  test('getMonthLongName returns correct names', () {
    expect(MonthUtils.getMonthLongName(1), 'January');
    expect(MonthUtils.getMonthLongName(12), 'December');
    expect(MonthUtils.getMonthLongName(0), isNull);
    expect(MonthUtils.getMonthLongName(13), isNull);
  });
  test('getMonthShortName returns correct names', () {
    expect(MonthUtils.getMonthShortName(1), 'Jan');
    expect(MonthUtils.getMonthShortName(12), 'Dec');
    expect(MonthUtils.getMonthShortName(null), isNull);
  });
  test('monthNumbers contains all 12 months', () {
    expect(MonthUtils.monthNumbers, hasLength(12));
    expect(MonthUtils.monthNumbers.firstOrNull, 1);
    expect(MonthUtils.monthNumbers.lastOrNull, 12);
  });
});
```

---

## `WeekdayUtils` — `lib/datetime/date_constants.dart`

```dart
group('WeekdayUtils', () {
  test('getDayLongName returns correct names', () {
    expect(WeekdayUtils.getDayLongName(DateTime.monday), 'Monday');
    expect(WeekdayUtils.getDayLongName(DateTime.sunday), 'Sunday');
    expect(WeekdayUtils.getDayLongName(null), isNull);
  });
  test('getDayShortName returns correct names', () {
    expect(WeekdayUtils.getDayShortName(DateTime.monday), 'Mon');
    expect(WeekdayUtils.getDayShortName(DateTime.sunday), 'Sun');
    expect(WeekdayUtils.getDayShortName(null), isNull);
  });
  test('dayLongNames contains all 7 days', () {
    expect(WeekdayUtils.dayLongNames, hasLength(7));
  });
  test('dayShortNames contains all 7 days', () {
    expect(WeekdayUtils.dayShortNames, hasLength(7));
  });
});
```

---

## `List<String>.joinDisplayList(...)` — `lib/list/list_string_extensions.dart`

Comprehensive coverage: 0/1/2/3/4/5 elements, the non-null and nullable element
types, and heavy whitespace/empty/null interleaving (verifies trim + drop-blank +
de-dup + Oxford comma + null-not-empty return).

```dart
group('joinDisplayList', () {
  test('List should be empty', () {
    expect(<String>[' ', '', ' '].joinDisplayList(), isNull);
    expect(<String>[' ', '     ', ' '].joinDisplayList(), isNull);
  });
  test('1 element', () {
    expect(<String>['A'].joinDisplayList(), 'A');
    expect(<String>[' ', '', 'A'].joinDisplayList(), 'A');
  });
  test('2 elements', () {
    expect(<String>['A', 'B'].joinDisplayList(), 'A and B');
    expect(<String>['A', ' ', '   ', 'B'].joinDisplayList(), 'A and B');
  });
  test('3 elements', () {
    expect(<String>['A', 'B', 'C'].joinDisplayList(), 'A, B, and C');
    expect(<String>['A', ' ', '', '   ', '', 'B', 'C'].joinDisplayList(), 'A, B, and C');
  });
  test('4 elements', () {
    expect(<String>['A', 'B', 'C', 'D'].joinDisplayList(), 'A, B, C, and D');
    expect(
      <String>[' ', 'A', '', ' ', 'B', '   ', '', 'C', 'D', ''].joinDisplayList(),
      'A, B, C, and D',
    );
  });
  test('5 elements', () {
    expect(<String>['A', 'B', 'C', 'D', 'E'].joinDisplayList(), 'A, B, C, D, and E');
  });

  // Nullable element type — null treated like blank (trimmed out).
  test('nullable: empty / interleaved nulls', () {
    expect(<String?>[null, null, null].joinDisplayList(), isNull);
    expect(<String?>[null, '', 'A'].joinDisplayList(), 'A');
    expect(<String?>['A', null, '', 'B'].joinDisplayList(), 'A and B');
    expect(<String?>['A', null, '', null, '', 'B', 'C'].joinDisplayList(), 'A, B, and C');
  });
});
```

---

## `StreamDebounceExtensions` (on `Stream<T>`) — `lib/async/stream_debounce_utils.dart`

The `debounceAfterFirst` "late consumer" case is the regression that motivated the
deferred-listen single-subscription controller — worth porting verbatim if not
already present.

```dart
group('debounce', () {
  test('only emits after duration of silence (latest wins)', () async {
    final controller = StreamController<int>.broadcast();
    final received = <int>[];
    controller.stream.debounce(const Duration(milliseconds: 50)).listen(received.add);
    controller..add(1)..add(2)..add(3);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(received, isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(received, <int>[3]);
    await controller.close();
  });
  test('emits each value when spaced apart', () async {
    final controller = StreamController<int>.broadcast();
    final received = <int>[];
    controller.stream.debounce(const Duration(milliseconds: 30)).listen(received.add);
    controller.add(1);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    controller.add(2);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(received, <int>[1, 2]);
    await controller.close();
  });
});

group('debounceAfterFirst', () {
  test('emits first immediately, debounces the rest', () async {
    final controller = StreamController<int>.broadcast();
    final received = <int>[];
    controller.stream.debounceAfterFirst(const Duration(milliseconds: 50)).listen(received.add);
    controller..add(1)..add(2)..add(3);
    await Future<void>.delayed(Duration.zero);
    expect(received, <int>[1]);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(received, <int>[1, 3]);
    await controller.close();
  });

  // REGRESSION: a late subscriber must still receive the first event. An eager
  // broadcast-controller version dropped the first upstream emission when the
  // consumer subscribed late (StreamBuilder gated behind a visibility builder),
  // leaving a Drift watch stream idle forever (perpetual spinner). The fix defers
  // the upstream listen() to onListen.
  test('late consumer still receives the first event', () async {
    final upstream = Stream<int>.fromFuture(Future<int>.microtask(() => 42));
    final wrapped = upstream.debounceAfterFirst(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 20)); // consumer arrives late
    final received = <int>[];
    final sub = wrapped.listen(received.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(received, <int>[42]);
    await sub.cancel();
  });

  test('cancels upstream subscription when consumer cancels', () async {
    final controller = StreamController<int>();
    final wrapped = controller.stream.debounceAfterFirst(const Duration(milliseconds: 50));
    final sub = wrapped.listen((_) {});
    controller.add(1);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(controller.hasListener, isFalse); // wrapper released upstream
    await controller.close();
  });
});

group('debounceDistinct', () {
  test('debounces then applies distinct (default + custom equals)', () async {
    final controller = StreamController<int>.broadcast();
    final received = <int>[];
    controller.stream.debounceDistinct(const Duration(milliseconds: 30)).listen(received.add);
    controller..add(1)..add(2)..add(3);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    controller.add(3); // equal — filtered
    await Future<void>.delayed(const Duration(milliseconds: 50));
    controller.add(5);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(received, <int>[3, 5]);
    await controller.close();
  });
});
```

---

## Environment

- saropa_dart_utils: 1.4.1
- Source: Saropa Contacts `test/lib/utils/primitive/date_time/date_time_primitive_test.dart`
  and `test/utils/primitive/string/string_utils_test.dart` (removed there 2026-06-11).
