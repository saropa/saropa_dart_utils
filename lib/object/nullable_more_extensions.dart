/// Null-aware helpers for any nullable receiver `T?`: run a side effect,
/// transform, or supply a fallback only when (or unless) the value is null.
///
/// Roadmap #351-365.
extension NullableWhen<T> on T? {
  /// Runs [fn] with the value when it is non-null, then returns the original
  /// receiver unchanged (null or not) so calls can be chained.
  ///
  /// A null-safe "tap"/"also": use it for side effects (logging, mutation)
  /// without breaking a call chain. [fn] is never called for a null receiver.
  ///
  /// Example:
  /// ```dart
  /// user?.toListOrEmpty().whenNonNull(print); // prints only when non-null
  /// ```
  T? whenNonNull(void Function(T) fn) {
    // Pattern matches only when `this` is non-null; `T` is the non-nullable
    // underlying type, so `fn` never receives null.
    if (this case T t) fn(t);
    return this;
  }

  /// Transforms a non-null value with [fn], or returns null when the receiver
  /// is null.
  ///
  /// The null-propagating cousin of a plain `map`: avoids calling [fn] on null
  /// while still letting the result type [R] differ from [T].
  ///
  /// Example:
  /// ```dart
  /// const int? n = 3;
  /// n.mapNonNull((v) => v * 2); // 6
  /// null.mapNonNull((v) => v);  // null
  /// ```
  R? mapNonNull<R>(R Function(T) fn) {
    final T? self = this;
    return self == null ? null : fn(self);
  }

  /// Returns the value when non-null, otherwise the result of [compute].
  ///
  /// [compute] is evaluated lazily — only when the receiver is null — so an
  /// expensive fallback is skipped when not needed. Equivalent to `this ??`
  /// but accepting a thunk instead of a precomputed value.
  ///
  /// Example:
  /// ```dart
  /// const String? name = null;
  /// name.orElse(() => 'Anonymous'); // 'Anonymous'
  /// ```
  T orElse(T Function() compute) => this ?? compute();
}

/// Non-throwing runtime cast for a nullable receiver.
extension TryCast<T> on T? {
  /// Casts the receiver to [U] when its runtime type matches, otherwise returns
  /// null.
  ///
  /// Unlike the `as` operator this never throws; a null receiver (or any value
  /// that is not a [U]) yields null.
  ///
  /// Example:
  /// ```dart
  /// Object? value = 'hi';
  /// value.tryCast<String>(); // 'hi'
  /// value.tryCast<int>();    // null
  /// ```
  U? tryCast<U>() {
    final o = this;
    if (o is U) return o;
    return null;
  }
}

/// Returns whether [value] is an instance of [T] at runtime.
///
/// A function form of the `is` operator, usable where a type predicate must be
/// passed as a callback (for example `iterable.where(isType<MyType>)`).
///
/// Example:
/// ```dart
/// isType<String>('x'); // true
/// isType<int>('x');    // false
/// ```
bool isType<T>(Object? value) => value is T;

/// Returns [value] as a [T] when it is one, otherwise [fallback].
///
/// A non-throwing alternative to `as` that supplies a default instead of
/// raising when the type does not match.
///
/// Example:
/// ```dart
/// asTypeOr<int>('not a number', -1); // -1
/// asTypeOr<int>(42, -1);             // 42
/// ```
T asTypeOr<T>(Object? value, T fallback) => value is T ? value : fallback;

/// Searches a heterogeneous list for the first element of a given type.
extension FirstOfTypeExtension on List<Object?> {
  /// Returns the first element that is a [T], or null when no element matches.
  ///
  /// Useful for pulling a typed value out of a mixed-type list without manual
  /// iteration and casting.
  ///
  /// Example:
  /// ```dart
  /// final mixed = <Object?>[1, 'two', 3.0];
  /// mixed.firstOfType<String>(); // 'two'
  /// mixed.firstOfType<bool>();   // null
  /// ```
  T? firstOfType<T>() {
    for (final Object? e in this) {
      if (e is T) return e;
    }
    return null;
  }
}

/// Wraps a nullable value into a list, treating null as empty.
extension ToListOrEmpty<T> on T? {
  /// Wraps a non-null value in a single-element list, or returns an empty list
  /// when null.
  ///
  /// Distinct from `MakeListExtensions.toListIfNotNull`, which returns `null`
  /// (not an empty list) for a null receiver. Renamed from `toListIfNotNull` to
  /// avoid an ambiguous-extension clash with that established API and because
  /// "if not null" wrongly implied a nullable result.
  ///
  /// Example:
  /// ```dart
  /// 5.toListOrEmpty();      // [5]
  /// null.toListOrEmpty();   // []
  /// ```
  List<T> toListOrEmpty() {
    final T? self = this;
    if (self == null) return <T>[];
    return <T>[self];
  }
}
