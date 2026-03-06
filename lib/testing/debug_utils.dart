/// Testing/Debug: pretty-print, dump iterable, assert equals with tolerance, range, repeat, timed. Roadmap #366-375.
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

String dumpIterable(Iterable<dynamic> it, {int maxItems = 10}) {
  final List<dynamic> list = it.toList();
  if (list.length <= maxItems) return list.toString();
  return '${list.take(maxItems).toList()}... (${list.length} total)';
}

void assertEqualsWithTolerance(double a, double b, double tolerance) {
  if ((a - b).abs() > tolerance) throw AssertionError('Expected $a ≈ $b (tolerance $tolerance)');
}

List<int> rangeInt(int start, int end, {int step = 1}) {
  final List<int> out = <int>[];
  for (int i = start; step > 0 ? i < end : i > end; i += step) out.add(i);
  return out;
}

List<double> rangeDouble(double start, double end, double step) {
  final List<double> out = <double>[];
  for (double x = start; step > 0 ? x < end : x > end; x += step) out.add(x);
  return out;
}

List<T> repeatValue<T>(T value, int n) => List<T>.filled(n, value);

Duration timed(void Function() fn) {
  final DateTime start = DateTime.now();
  fn();
  return DateTime.now().difference(start);
}

bool retryUntil(bool Function() predicate, {int maxAttempts = 10}) {
  for (int i = 0; i < maxAttempts; i++) {
    if (predicate()) return true;
  }
  return false;
}
