/// This is an extension on the nullable generic type T?
extension MakeListExtensions<T> on T? {
  /// This method converts an object to a list if it's not null.
  ///
  /// Returns null if the value is null, otherwise returns a single-element list.
  List<T>? toListIfNotNull() => this == null ? null : <T>[this as T];
}
