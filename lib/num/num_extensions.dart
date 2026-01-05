extension NumberExtensions on num {
  /// Returns `true` if the number is not zero and not negative.
  ///
  /// This is a convenient way to check if a number is strictly positive.
  ///
  /// Example:
  /// ```dart
  /// 5.isNotZeroOrNegative; // Returns true
  /// 0.isNotZeroOrNegative; // Returns false
  /// (-3).isNotZeroOrNegative; // Returns false
  /// ```
  bool get isNotZeroOrNegative => this != 0 && !isNegative;

  /// Returns `true` if the number is zero or negative.
  ///
  /// This is a convenient way to check if a number is not strictly positive.
  ///
  /// Example:
  /// ```dart
  /// 5.isZeroOrNegative; // Returns false
  /// 0.isZeroOrNegative; // Returns true
  /// (-3).isZeroOrNegative; // Returns true
  /// ```
  bool get isZeroOrNegative => this == 0 || isNegative;

  /// Returns the number of digits in the string representation of the number.
  ///
  /// For negative numbers, it includes the negative sign in the length.
  /// For decimal numbers, it includes the decimal point in the length.
  ///
  /// Example:
  /// ```dart
  /// 123.length(); // Returns 3
  /// (-123).length(); // Returns 4 (includes '-')
  /// 123.45.length(); // Returns 6 (includes '.')
  /// ```
  ///
  /// NOTE: negative zero is removed when formatting. I.e. -0 becomes 0
  int length() => toString().length;
}

/// Extension methods for nullable `num?`.
extension NumberNullableExtensions on num? {
  /// Returns `true` if the nullable number is not null, not zero, and not negative.
  ///
  /// This is a null-safe version of `isNotZeroOrNegative` for nullable numbers.
  ///
  /// Example:
  /// ```dart
  /// num? n1 = 5; n1.isNotNullZeroOrNegative; // Returns true
  /// num? n2 = null; n2.isNotNullZeroOrNegative; // Returns false
  /// num? n3 = 0; n3.isNotNullZeroOrNegative; // Returns false
  /// num? n4 = -3; n4.isNotNullZeroOrNegative; // Returns false
  /// ```
  bool get isNotNullZeroOrNegative {
    final value = this;
    return value != null && value.isNotZeroOrNegative;
  }

  /// Returns `true` if the nullable number is null, zero, or negative.
  ///
  /// This is a null-safe version of `isZeroOrNegative` for nullable numbers.
  ///
  /// Example:
  /// ```dart
  /// num? n1 = 5; n1.isNullZeroOrNegative; // Returns false
  /// num? n2 = null; n2.isNullZeroOrNegative; // Returns true
  /// num? n3 = 0; n3.isNullZeroOrNegative; // Returns true
  /// num? n4 = -3; n4.isNullZeroOrNegative; // Returns true
  /// ```
  bool get isNullZeroOrNegative {
    final value = this;
    return value == null || value.isZeroOrNegative;
  }

  /// Returns `true` if the nullable number is null or zero.
  ///
  /// Example:
  /// ```dart
  /// num? n1 = 5; n1.isNullOrZero; // Returns false
  /// num? n2 = null; n2.isNullOrZero; // Returns true
  /// num? n3 = 0; n3.isNullOrZero; // Returns true
  /// num? n4 = -3; n4.isNullOrZero; // Returns false
  /// ```
  bool get isNullOrZero => this == null || this == 0;

  /// Returns `true` if the nullable number is not null and not zero.
  ///
  /// Example:
  /// ```dart
  /// num? n1 = 5; n1.isNotNullOrZero; // Returns true
  /// num? n2 = null; n2.isNotNullOrZero; // Returns false
  /// num? n3 = 0; n3.isNotNullOrZero; // Returns false
  /// num? n4 = -3; n4.isNotNullOrZero; // Returns true
  /// ```
  bool get isNotNullOrZero => this != null && this != 0;

  /// Returns `true` if the nullable number is not null and greater than zero.
  ///
  /// Example:
  /// ```dart
  /// num? n1 = 5; n1.isGreaterThanZero; // Returns true
  /// num? n2 = null; n2.isGreaterThanZero; // Returns false
  /// num? n3 = 0; n3.isGreaterThanZero; // Returns false
  /// num? n4 = -3; n4.isGreaterThanZero; // Returns false
  /// ```
  bool get isGreaterThanZero {
    final num? self = this;
    return self != null && self > 0;
  }

  /// Returns `true` if the nullable number is not null and greater than one.
  ///
  /// Example:
  /// ```dart
  /// num? n1 = 5; n1.isGreaterThanOne; // Returns true
  /// num? n2 = null; n2.isGreaterThanOne; // Returns false
  /// num? n3 = 1; n3.isGreaterThanOne; // Returns false
  /// num? n4 = 0; n4.isGreaterThanOne; // Returns false
  /// num? n5 = -3; n5.isGreaterThanOne; // Returns false
  /// ```
  bool get isGreaterThanOne {
    final num? self = this;
    return self != null && self > 1;
  }

  /// Converts this nullable num to a double, or returns null if null.
  double? toDoubleOrNull() => this?.toDouble();

  /// Converts this nullable num to an int, or returns null if null.
  int? toIntOrNull() => this?.toInt();
}
