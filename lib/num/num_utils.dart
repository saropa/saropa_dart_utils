import 'package:flutter/material.dart';

/// Utility class for number-related operations.
class NumberUtils {
  /// Returns the maximum of two nullable numbers.
  ///
  /// If both `a` and `b` are null, returns null.
  /// If only one of `a` or `b` is null, returns the non-null number.
  /// If both are non-null, returns the larger of the two.
  ///
  /// Example:
  /// ```dart
  /// NumberUtils.maxOf(10, 5); // Returns 10
  /// NumberUtils.maxOf(null, 5); // Returns 5
  /// NumberUtils.maxOf(10, null); // Returns 10
  /// NumberUtils.maxOf(null, null); // Returns null
  /// ```
  static num? maxOf(num? a, num? b) {
    // If both numbers are null, return null
    if (a == null && b == null) {
      return null;
    }

    // If the first number is null, return the second number
    if (a == null) {
      return b;
    }

    // If the second number is null, return the first number
    if (b == null) {
      return a;
    }

    // Return the larger of the two numbers
    return a > b ? a : b;
  }

  /// Generates a list of integers in ascending order, starting from [start] and ending at [end] (inclusive).
  ///
  /// Returns `null` if [start] is greater than [end], indicating an invalid range.
  /// In case of an invalid range, a warning debug message is printed.
  ///
  /// Example:
  /// ```dart
  /// NumberUtils.generateIntList(1, 5); // Returns [1, 2, 3, 4, 5]
  /// NumberUtils.generateIntList(3, 3); // Returns [3]
  /// NumberUtils.generateIntList(5, 1); // Returns null, prints a warning
  /// ```
  static List<int>? generateIntList(int start, int end) {
    if (start > end) {
      debugPrint(
        'Invalid [start]: `$start` for '
        '[end]: `$end`',
      );
      return null;
    }

    return List<int>.generate(end - start + 1, (int i) => start + i);
  }
}
