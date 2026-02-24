import 'dart:convert' as dc;

import 'package:meta/meta.dart';

/// Utility class for JSON encoding of iterables.
abstract final class JsonIterablesUtils {
  /// Returns the JSON-encoded string representation of [iterable].
  ///
  /// The elements of [iterable] (type [T]) must be directly encodable by
  /// `dart:convert.jsonEncode` (e.g., `num`, `String`, `bool`, `null`,
  /// `List`, or `Map` with encodable keys and values).
  @useResult
  static String jsonEncode<T>(Iterable<T> iterable) => dc.jsonEncode(iterable.toList());
}
