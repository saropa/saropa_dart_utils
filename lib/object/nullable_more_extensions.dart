/// Type/Null: when non-null, map if non-null, else get, try cast, isType, etc. Roadmap #351-365.
extension NullableWhen<T> on T? {
  T? whenNonNull(void Function(T) fn) {
    if (this case T t) fn(t);
    return this;
  }

  R? mapNonNull<R>(R Function(T) fn) {
    final T? self = this;
    return self == null ? null : fn(self);
  }

  T orElse(T Function() compute) => this ?? compute();
}

extension TryCast<T> on T? {
  U? tryCast<U>() {
    final o = this;
    if (o is U) return o;
    return null;
  }
}

bool isType<T>(Object? value) => value is T;

T asTypeOr<T>(Object? value, T fallback) => value is T ? value : fallback;

extension FirstOfTypeExtension on List<Object?> {
  T? firstOfType<T>() {
    for (final Object? e in this) {
      if (e is T) return e;
    }
    return null;
  }
}

extension ToListIfNotNull<T> on T? {
  List<T> toListIfNotNull() {
    final T? self = this;
    if (self == null) return <T>[];
    return <T>[self];
  }
}
