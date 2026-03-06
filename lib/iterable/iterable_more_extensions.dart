import 'package:meta/meta.dart';

/// Collections More: take/drop last, replace first/all, cycle, pad, unzip, segment, consecutive pairs, etc. Roadmap #266-290.
/// Take/drop from the end of an iterable.
extension IterableTakeDropLast<T> on Iterable<T> {
  /// Last [n] elements; all if n >= length.
  @useResult
  List<T> takeLast(int n) {
    final List<T> list = toList();
    if (n >= list.length) return list;
    return list.sublist(list.length - n);
  }

  /// All but the last [n] elements.
  @useResult
  List<T> dropLast(int n) {
    final List<T> list = toList();
    if (n <= 0) return list;
    if (n >= list.length) return <T>[];
    return list.sublist(0, list.length - n);
  }
}

/// Replace first or all occurrences in a list.
extension IterableReplace<T> on List<T> {
  /// New list with first occurrence of [value] replaced by [replacement].
  @useResult
  List<T> replaceFirst(T value, T replacement) {
    final List<T> out = List<T>.of(this);
    final int i = indexOf(value);
    if (i >= 0) out[i] = replacement;
    return out;
  }

  /// New list with every [value] replaced by [replacement].
  @useResult
  List<T> replaceAllValues(T value, T replacement) =>
      map((T e) => e == value ? replacement : e).toList();
}

/// Infinite cycle over list elements.
extension IterableCycle<T> on List<T> {
  /// Lazy infinite iterable repeating this list.
  Iterable<T> cycle() sync* {
    if (isEmpty) return;
    int i = 0;
    while (true) {
      yield this[i % length];
      i++;
    }
  }
}

/// Pad list to a minimum length.
extension IterablePad<T> on List<T> {
  /// New list padded with [fill] to at least [length] elements.
  @useResult
  List<T> padTo(int length, T fill) {
    if (this.length >= length) return List<T>.of(this);
    return List<T>.of(this)..addAll(List<T>.filled(length - this.length, fill));
  }
}

/// Splits [pairs] into two lists: first elements and second elements.
(List<A>, List<B>) unzip2<A, B>(List<(A, B)> pairs) {
  final List<A> a = <A>[];
  final List<B> b = <B>[];
  for (final (A x, B y) in pairs) {
    a.add(x);
    b.add(y);
  }
  return (a, b);
}

/// Segment iterable into lists where consecutive pairs satisfy [predicate].
extension IterableSegment<T> on Iterable<T> {
  /// When [predicate](prev, next) is false, starts a new segment.
  List<List<T>> segmentBy(bool Function(T, T) predicate) {
    final List<T> list = toList();
    if (list.isEmpty) return <List<T>>[];
    final List<List<T>> out = <List<T>>[];
    List<T> current = <T>[list[0]];
    for (int i = 1; i < list.length; i++) {
      if (predicate(list[i - 1], list[i])) {
        current.add(list[i]);
      } else {
        out.add(current);
        current = <T>[list[i]];
      }
    }
    out.add(current);
    return out;
  }
}

/// Consecutive pairs from a list.
extension IterableConsecutive<T> on List<T> {
  /// Adjacent pairs of elements; empty if length < 2.
  List<(T, T)> consecutivePairs() {
    if (length < 2) return <(T, T)>[];
    return List<(T, T)>.generate(length - 1, (int i) => (this[i], this[i + 1]));
  }
}

/// Index of min/max by a comparable key.
extension IterableArgMinMax<T> on Iterable<T> {
  /// Index of the element with minimum [keyOf]; null if empty.
  int? argMinBy<C extends Comparable<C>>(C Function(T) keyOf) {
    int? idx;
    C? minKey;
    int i = 0;
    for (final T e in this) {
      final C k = keyOf(e);
      if (minKey == null || k.compareTo(minKey) < 0) {
        minKey = k;
        idx = i;
      }
      i++;
    }
    return idx;
  }

  /// Index of the element with maximum [keyOf]; null if empty.
  int? argMaxBy<C extends Comparable<C>>(C Function(T) keyOf) {
    int? idx;
    C? maxKey;
    int i = 0;
    for (final T e in this) {
      final C k = keyOf(e);
      if (maxKey == null || k.compareTo(maxKey) > 0) {
        maxKey = k;
        idx = i;
      }
      i++;
    }
    return idx;
  }
}

/// Check if all elements are equal.
extension IterableAllEqual<T> on Iterable<T> {
  /// True if empty or all elements are equal.
  bool get allEqual {
    final Iterator<T> it = iterator;
    if (!it.moveNext()) return true;
    final T first = it.current;
    while (it.moveNext()) {
      if (it.current != first) return false;
    }
    return true;
  }
}

/// Count occurrences of each element.
extension IterableCountBy<T> on Iterable<T> {
  /// Map of element to occurrence count.
  Map<T, int> countBy() {
    final Map<T, int> out = <T, int>{};
    for (final T e in this) out[e] = (out[e] ?? 0) + 1;
    return out;
  }
}

/// Prefix scan (running reduce).
extension IterableScan<T> on Iterable<T> {
  /// List of [initial] and each step of [combine](acc, element).
  List<R> scan<R>(R initial, R Function(R, T) combine) {
    final List<R> out = <R>[initial];
    R acc = initial;
    for (final T e in this) {
      acc = combine(acc, e);
      out.add(acc);
    }
    return out;
  }
}
