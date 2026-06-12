import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Extension on [Uint8List] to convert it to a `List<int>`.
extension Uint8ListExtension on Uint8List {
  /// Converts this [Uint8List] to a growable `List<int>` with the same elements.
  ///
  /// Iterates over each byte and copies it into a brand-new growable
  /// `List<int>`. The result is fully decoupled from the source buffer: it is
  /// growable (a [Uint8List] is fixed-length, so callers that need to append
  /// MUST start from this copy) and independent (mutating the source after
  /// conversion does not affect the returned list, and vice-versa).
  ///
  /// Edge cases:
  /// - An empty [Uint8List] returns an empty list (never null).
  /// - Every byte is already in `0..255`, so no value can be lost here; the
  ///   narrowing concern lives only on the reverse [IntListExtension.toUint8List].
  /// - A very large buffer is copied in a single linear pass — the body must
  ///   stay `map(...).toList()` so this never degrades to quadratic behavior.
  ///
  /// The result is marked [useResult] because the conversion exists solely to
  /// hand back a new list; discarding it is always a mistake (the source is
  /// unchanged).
  ///
  /// Example:
  /// ```dart
  /// final Uint8List bytes = Uint8List.fromList(<int>[0, 1, 255]);
  /// final List<int> ints = bytes.toIntList(); // [0, 1, 255], growable, independent
  /// ints.add(7); // succeeds — the result is growable
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  List<int> toIntList() => map((int e) => e).toList();
}

/// Extension on `List<int>` to convert it to a [Uint8List].
extension IntListExtension on List<int> {
  /// Converts this `List<int>` to a fresh, independent [Uint8List].
  ///
  /// Delegates to [Uint8List.fromList], which copies the elements into a new
  /// fixed-length byte buffer. The result is therefore independent of this list
  /// (later mutations to either side do not cross over) and fixed-length
  /// (`add`/`removeLast` throw [UnsupportedError], the structural guarantee of a
  /// typed byte buffer).
  ///
  /// Narrowing semantics — locked by tests so a future "validate input" change
  /// is a conscious decision rather than a silent break: each element is stored
  /// modulo 256, i.e. its low 8 bits (`value & 0xFF`). Out-of-range and negative
  /// inputs wrap rather than throw — `256 -> 0`, `257 -> 1`, `-1 -> 255`,
  /// `-256 -> 0`. Even `int` extremes are accepted: the platform-max and
  /// platform-min integers reduce to their low byte without error. This holds
  /// for any `List<int>`, including typed-data lists such as [Uint8List],
  /// [Int8List], or [Int16List] passed as `List<int>`.
  ///
  /// Edge cases:
  /// - An empty list returns an empty [Uint8List] (never null).
  ///
  /// The result is marked [useResult] because the conversion produces a new
  /// buffer and leaves the source untouched; ignoring it is always a mistake.
  ///
  /// Example:
  /// ```dart
  /// final Uint8List bytes = <int>[0, 257, -1].toUint8List(); // [0, 1, 255]
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Uint8List toUint8List() => Uint8List.fromList(this);
}
