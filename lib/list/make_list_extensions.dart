/// This is an extension on the nullable generic type T?
extension MakeListExtensions<T> on T? {
  /// This method converts an object to a list if it's not null.
  ///
  /// Returns null if the value is null, otherwise returns a single-element list.
  List<T>? toListIfNotNull() {
    final T? self = this;
    return self == null ? null : <T>[self];
  }
}
