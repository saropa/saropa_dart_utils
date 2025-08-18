/// Extensions that check string properties or compare strings.
extension StringValidationAndComparisonExtensions on String {
  /// Checks if the string can be parsed as a number.
  bool isNumeric() =>
      // Attempt to parse as a double and check if the result is not null.
      double.tryParse(this) != null;

  /// Checks if the string contains only Latin alphabet characters (a-z, A-Z).
  bool isLatin() =>
      // Use a regular expression to match only alphabetic characters from start to end.
      RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Checks if the string starts and ends with matching brackets.
  /// e.g., `(abc)`, `[abc]`, `{abc}`, `<abc>`.
  bool isBracketWrapped() {
    // A wrapped string must have at least 2 characters.
    if (length < 2) return false;
    // Check for each pair of matching brackets.
    return (startsWith('(') && endsWith(')')) ||
        (startsWith('[') && endsWith(']')) ||
        (startsWith('{') && endsWith('}')) ||
        (startsWith('<') && endsWith('>'));
  }

  /// Compares this string to [other], with options for case-insensitivity
  /// and apostrophe normalization.
  bool isEquals(String? other, {bool ignoreCase = true, bool normalizeApostrophe = true}) {
    // If other string is null, they can't be equal.
    if (other == null) return false;
    // Create mutable copies for normalization.
    String first = this;
    String second = other;

    // If ignoring case, convert both to lowercase.
    if (ignoreCase) {
      first = first.toLowerCase();
      second = second.toLowerCase();
    }
    // If normalizing apostrophes, replace variants with a standard one.
    if (normalizeApostrophe) {
      first = first.replaceAll(RegExp("['’]"), "'");
      second = second.replaceAll(RegExp("['’]"), "'");
    }
    // Perform the final comparison.
    return first == second;
  }

  /// Checks if this string contains [other] in a case-insensitive manner.
  bool containsIgnoreCase(String? other) {
    // If other is null or empty, it cannot be contained.
    if (other == null || other.isEmpty) return false;
    // Perform a case-insensitive search.
    return toLowerCase().contains(other.toLowerCase());
  }

  String getFirstDiffChar(String other) {
    final int minLength = length < other.length ? length : other.length;

    for (int i = 0; i < minLength; i++) {
      if (this[i] != other[i]) {
        return other[i];
      }
    }

    // If we reach this point, the shorter string is a prefix of the longer one.
    // The first "different" character is the first character of the remaining part
    // of the longer string.
    if (length > other.length) {
      return this[minLength];
    } else if (other.length > length) {
      return other[minLength];
    }

    // If the strings are identical, return an empty string.
    return '';
  }
}
