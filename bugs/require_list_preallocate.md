# require_list_preallocate

## 3 violations | Severity: info

### Rule Description
Flags code that creates an empty list and then adds elements in a loop. Without preallocation, the list may need to reallocate and copy its internal array multiple times as it grows, causing O(n) reallocation overhead.

### Assessment
- **False Positive**: Partially. The rule is correct in principle, but the impact depends on collection size. For small, bounded loops the overhead is negligible.
- **Should Exclude**: No. Preallocation is a good habit and the fixes are straightforward.

### Affected Files

**`lib/datetime/date_time_extensions.dart:82-88`** — Building a list of consecutive days:
```dart
final List<DateTime> dayList = <DateTime>[];
DateTime currentDate = this;
for (int i = 0; i < days; i++) {
  dayList.add(currentDate);
  currentDate = currentDate.nextDay(startOfDay: startOfDay);
}
return dayList;
```

`days` is caller-provided and could be large. Preallocation is beneficial here.

**`lib/list/list_of_list_extensions.dart:86-90`** — Cloning a 2D list:
```dart
final List<List<T>> newList = <List<T>>[];
for (List<T> innerList in this) {
  newList.add(List<T>.from(innerList));
}
return newList;
```

The outer list size is known (`this.length`). Preallocation is straightforward.

**`lib/string/string_extensions.dart:440`** — Merging split segments:
```dart
final List<String> mergedResult = <String>[];
// ...loop adding to mergedResult...
```

The maximum size is `intermediateSplit.length`. Preallocation is possible.

### Recommended Action
FIX — Preallocate where the size is known or bounded:

```dart
// date_time_extensions.dart — size is exactly `days`
final List<DateTime> dayList = List<DateTime>.generate(days, (_) {
  final date = currentDate;
  currentDate = currentDate.nextDay(startOfDay: startOfDay);
  return date;
});

// list_of_list_extensions.dart — size is exactly `this.length`
final List<List<T>> newList = List<List<T>>.generate(
  length,
  (int i) => List<T>.from(this[i]),
);

// string_extensions.dart — initialize with capacity estimate
// Since mergedResult will have at most intermediateSplit.length elements:
final List<String> mergedResult = <String>[];
// Consider using List.generate or accepting the growable list for this case
```
