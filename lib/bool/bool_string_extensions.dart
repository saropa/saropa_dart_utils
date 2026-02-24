import 'package:meta/meta.dart';

/// Saropa extensions for converting [String] to [bool]
///
extension BoolStringExtensions on String {
  /// Converts a case-insensitive string of 'true' or 'false' to a boolean.
  /// Returns null if the string is empty or not 'true' or 'false'.
  @useResult
  bool? toBoolNullable() {
    final String lower = toLowerCase();
    if (lower == 'true') {
      return true;
    }

    if (lower == 'false') {
      return false;
    }

    return null;
  }

  /// Converts a case-insensitive string of 'true' to a boolean.
  /// Returns false if the string is not 'true'.
  @useResult
  bool toBool() => toLowerCase() == 'true';
}

/// Saropa extensions for converting [bool] to [String]
///
extension BoolStringNullableExtensions on String? {
  /// Converts a case-insensitive string of 'true' to a boolean.
  /// Returns false if the string is null, empty, or not 'true'.
  @useResult
  bool toBool() => this?.toLowerCase() == 'true';
}
