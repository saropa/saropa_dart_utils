import 'package:meta/meta.dart';

/// Flatten to depth N or fully deep.
extension IterableFlattenDeepExtensions<E> on Iterable<dynamic> {
  /// Flattens recursively to [depth] levels. depth 1 = one level; null = fully deep.
  ///
  /// Returns a lazy [Iterable] of elements with nested iterables flattened
  /// up to [depth] levels, or fully when [depth] is null.
  @useResult
  Iterable<dynamic> flattenDeep([int? depth]) {
    final int? limit = depth;
    return expand((dynamic element) {
      if (limit != null && limit <= 0) {
        return [element];
      }
      if (element is Iterable<dynamic>) {
        final int? nextDepth = limit == null ? null : limit - 1;
        return element.flattenDeep(nextDepth);
      }
      return [element];
    });
  }
}
