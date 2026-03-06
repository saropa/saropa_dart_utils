import 'package:meta/meta.dart';

/// List ops: swap, reverse copy, insert/replace at index, safe get, default if empty. Roadmap #235-241, 396-399.
extension ListLowerExtensions<T> on List<T> {
  /// New list with elements at [i] and [j] swapped; in range only.
  @useResult
  List<T> swapAt(int i, int j) {
    final List<T> out = List<T>.of(this);
    if (i >= 0 && i < length && j >= 0 && j < length) {
      final T tmp = out[i];
      out[i] = out[j];
      out[j] = tmp;
    }
    return out;
  }

  /// New list with elements in reverse order.
  @useResult
  List<T> reversedCopy() => List<T>.of(this).reversed.toList();

  /// New list with [value] inserted at [index] (clamped to 0..length).
  @useResult
  List<T> insertAt(int index, T value) {
    final List<T> out = List<T>.of(this);
    out.insert(index.clamp(0, length), value);
    return out;
  }

  /// New list with element at [index] replaced by [value]; no-op if index out of range.
  @useResult
  List<T> replaceAt(int index, T value) {
    final List<T> out = List<T>.of(this);
    if (index >= 0 && index < length) out[index] = value;
    return out;
  }

  /// Element at [index], or null if out of range.
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;

  /// This list, or [defaultValue] if empty.
  @useResult
  List<T> orDefault(List<T> defaultValue) => isEmpty ? defaultValue : this;

  /// First element, or result of [compute] if empty.
  T firstOrCompute(T Function() compute) => isEmpty ? compute() : first;
}

/// Single element or null.
extension ListSingleExtension<T> on List<T> {
  /// The only element if length == 1, otherwise null.
  T? get singleOrNull => length == 1 ? single : null;
}

/// Convert iterable to set.
extension IterableToSetExtension<T> on Iterable<T> {
  /// Set of distinct elements.
  Set<T> toSetFrom() => toSet();
}

/// Convert iterable to list.
extension IterableToListExtension<T> on Iterable<T> {
  /// New list containing all elements.
  List<T> toListFrom() => toList();
}
