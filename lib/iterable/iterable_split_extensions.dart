import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

/// Split at index or at first element matching predicate.
extension IterableSplitExtensions<T extends Object> on Iterable<T> {
  /// Splits into two lists at [index]. First list has elements [0..index), second [index..length].
  @useResult
  (List<T>, List<T>) splitAt(int index) {
    final List<T> list = toList();
    if (index <= 0) return (<T>[], list);
    if (index >= list.length) return (list, <T>[]);
    return (list.sublist(0, index), list.sublist(index));
  }

  /// Splits at the first element where [predicate] is true. That element goes in the second list.
  @useResult
  (List<T>, List<T>) splitAtFirstWhere(ElementPredicate<T> predicate) {
    final List<T> list = toList();
    for (int i = 0; i < list.length; i++) {
      if (predicate(list[i])) {
        return (list.sublist(0, i), list.sublist(i));
      }
    }
    return (list, <T>[]);
  }
}
