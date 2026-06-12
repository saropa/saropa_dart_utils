/// Testing/Debug: pretty-print, dump iterable, assert equals with tolerance, range, repeat, timed. Roadmap #366-375.
library;

/// Recursively renders [obj] as an indented, human-readable string for
/// debugging. Maps and lists are expanded over multiple lines; `null` becomes
/// `'null'` and any other value falls back to its `toString()`. [indent] sets
/// the starting nesting depth (two spaces per level).
///
/// Example:
/// ```dart
/// prettyPrint({'a': 1, 'b': [2, 3]});
/// // {
/// //   a: 1
/// //   b: [
/// //     2,
/// //     3
/// //   ]
/// // }
/// ```
/// Audited: 2026-06-12 11:26 EDT
String prettyPrint(Object? obj, {int indent = 0}) {
  const int spaces = 2;
  final String pad = ' ' * (indent * spaces);
  if (obj == null) return 'null';
  if (obj is Map) {
    if (obj.isEmpty) return '{}';
    final List<String> parts = <String>[];
    for (final MapEntry<dynamic, dynamic> e in obj.entries) {
      parts.add('$pad${e.key}: ${prettyPrint(e.value, indent: indent + 1)}');
    }
    return '{\n${parts.join('\n')}\n$pad}';
  }
  if (obj is List) {
    if (obj.isEmpty) return '[]';
    final List<String> parts = obj.map((Object? e) => prettyPrint(e, indent: indent + 1)).toList();
    return '[\n$pad${parts.join(',\n$pad')}\n$pad]';
  }
  return obj.toString();
}

/// Renders [it] as a string, truncating to the first [maxItems] elements and
/// appending the total count when the iterable is longer.
///
/// Avoids dumping huge collections in logs while still showing a representative
/// head and the real size.
///
/// Example:
/// ```dart
/// dumpIterable([1, 2, 3, 4], maxItems: 2); // '[1, 2]... (4 total)'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String dumpIterable(Iterable<dynamic> it, {int maxItems = 10}) {
  final List<dynamic> list = it.toList();
  if (list.length <= maxItems) return list.toString();
  // ignore: saropa_lints/avoid_large_list_copy -- needs an independent copy to render the truncated head as a list literal in toString
  return '${list.take(maxItems).toList()}... (${list.length} total)';
}

/// Throws an [AssertionError] when [a] and [b] differ by more than [tolerance].
///
/// Use for comparing floating-point values where exact equality is unreliable.
///
/// Example:
/// ```dart
/// assertEqualsWithTolerance(0.1 + 0.2, 0.3, 1e-9); // passes
/// ```
/// Audited: 2026-06-12 11:26 EDT
void assertEqualsWithTolerance(double a, double b, double tolerance) {
  if ((a - b).abs() > tolerance) throw AssertionError('Expected $a ≈ $b (tolerance $tolerance)');
}

/// Returns integers from [start] (inclusive) toward [end] (exclusive) in
/// increments of [step]. A negative [step] counts down; the result is empty
/// when the range cannot advance toward [end].
///
/// Example:
/// ```dart
/// rangeInt(0, 5);            // [0, 1, 2, 3, 4]
/// rangeInt(5, 0, step: -2);  // [5, 3, 1]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> rangeInt(int start, int end, {int step = 1}) {
  final List<int> out = <int>[];
  for (int i = start; step > 0 ? i < end : i > end; i += step) {
    out.add(i);
  }
  return out;
}

/// Returns doubles from [start] (inclusive) toward [end] (exclusive) in
/// increments of [step]. A negative [step] counts down; the result is empty
/// when the range cannot advance toward [end].
///
/// Example:
/// ```dart
/// rangeDouble(0, 1, 0.5); // [0.0, 0.5]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<double> rangeDouble(double start, double end, double step) {
  final List<double> out = <double>[];
  for (double x = start; step > 0 ? x < end : x > end; x += step) {
    out.add(x);
  }
  return out;
}

/// Returns a list containing [value] repeated [n] times.
///
/// Example:
/// ```dart
/// repeatValue('x', 3); // ['x', 'x', 'x']
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<T> repeatValue<T>(T value, int n) => List<T>.filled(n, value);

/// Runs [fn] synchronously and returns the wall-clock [Duration] it took.
///
/// Useful for quick, ad-hoc timing in tests or debugging.
///
/// Example:
/// ```dart
/// final elapsed = timed(() => expensiveWork());
/// ```
/// Audited: 2026-06-12 11:26 EDT
Duration timed(void Function() fn) {
  final DateTime start = DateTime.now();
  fn();
  return DateTime.now().difference(start);
}

/// Calls [predicate] up to [maxAttempts] times, returning `true` as soon as it
/// succeeds, or `false` if every attempt fails.
///
/// Example:
/// ```dart
/// retryUntil(() => randomBool(), maxAttempts: 5);
/// ```
/// Audited: 2026-06-12 11:26 EDT
bool retryUntil(bool Function() predicate, {int maxAttempts = 10}) {
  for (int i = 0; i < maxAttempts; i++) {
    if (predicate()) return true;
  }
  return false;
}
