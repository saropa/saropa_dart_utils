/// `IntExtensions` is an extension on the `int` class in Dart. It provides
/// additional methods for performing operations on integers.
///
/// The methods in this extension include, but are not limited to, methods for
/// counting the number of digits in an integer.
///
/// Example usage:
/// ```dart
/// int count = 12345.countDigits();  // returns 5
/// ```
///
/// Note: All methods in this extension are null-safe, meaning they will
///  not throw an exception if the integer on which they are called is null.
///
extension IntExtensions on int {
  /// This function counts the number of digits in an integer.
  /// It takes an integer as input and returns the number of digits in the
  ///  integer.
  ///
  /// The function handles both positive and negative integers, as well as zero.
  ///
  /// It uses the method of repeatedly dividing the number by 10 until it
  ///  becomes 0,
  ///
  /// which is generally more efficient than converting the number to a string
  ///  and getting its length.
  ///
  int countDigits() {
    // // Count the number of digits in the absolute value of value
    // return value.abs().toString().length;

    // If the number is 0, return 1
    if (this == 0) {
      return 1;
    }

    // Take the absolute value of the number
    var number = abs();

    // Initialize a counter for the number of digits
    var count = 0;

    // Repeat until the number becomes 0
    while (number != 0) {
      // Divide the number by 10
      number ~/= 10;

      // Increment the counter
      count++;
    }

    // Return the count
    return count;
  }
}
