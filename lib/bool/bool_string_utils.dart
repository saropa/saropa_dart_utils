extension BoolStringExtensions on String {
  /// Converts a case-insensitive string of 'true' or 'false' to a boolean.
  /// Returns null if the string is empty or not 'true' or 'false'.
  bool? toBoolNullable() {
    if (toLowerCase() == 'true') {
      return true;
    } else if (toLowerCase() == 'false') {
      return false;
    }
    return null;
  }

  /// Converts a case-insensitive string of 'true' to a boolean.
  /// Returns false if the string is not 'true'.
  bool toBool() {
    return toLowerCase() == 'true';
  }
}

extension BoolStringNullableExtensions on String? {
  /// Converts a case-insensitive string of 'true' to a boolean.
  /// Returns false if the string is null, empty, or not 'true'.
  bool toBool() {
    return this?.toLowerCase() == 'true';
  }
}
