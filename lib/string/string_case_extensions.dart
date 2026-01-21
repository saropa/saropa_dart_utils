import 'package:saropa_dart_utils/list/list_extensions.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

final RegExp _allLetterLowerCaseRegex = RegExp(r'^[\p{Ll}]+$', unicode: true);

final RegExp _anyCaseLetterRegex = RegExp(r'^[\p{L}]+$', unicode: true);

final RegExp _allLetterUpperCaseRegex = RegExp(r'^[A-Z]+$');

final RegExp _splitCapitalizedWithNumbersRegex = RegExp('(?<=[a-z])(?=[A-Z0-9])');

final RegExp _splitCapitalizedRegex = RegExp('(?<=[a-z])(?=[A-Z])');

/// Extension methods for [String] to provide advanced case manipulation functionalities.
extension StringCaseExtensions on String {
  /// Checks if the string contains only lowercase letters (a-z).
  ///
  /// This method uses a regular expression to determine if all characters in the string
  /// are lowercase letters. It does not consider numbers, symbols, or whitespace as
  ///  lowercase letters.
  ///
  /// Returns:
  /// `true` if the string consists entirely of lowercase letters, `false` otherwise.
  ///  Returns `false` for empty strings.
  ///
  /// Example:
  /// ```dart
  /// 'lowercase'.isAllLetterLowerCase; // Returns true
  /// 'MixedCase'.isAllLetterLowerCase; // Returns false
  /// '123'.isAllLetterLowerCase;     // Returns false
  /// ''.isAllLetterLowerCase;        // Returns false
  /// ```
  bool get isAllLetterLowerCase => _allLetterLowerCaseRegex.hasMatch(this);

  /// Checks if the string contains only letters, regardless of case (a-z, A-Z).
  ///
  /// This method uses a regular expression to check if all characters in the string
  /// are alphabetic characters, either lowercase or uppercase. It does not consider
  /// numbers, symbols, or whitespace as letters.
  ///
  /// Returns:
  /// `true` if the string consists entirely of alphabetic characters, `false` otherwise.
  ///  Returns `false` for empty strings.
  ///
  /// Example:
  /// ```dart
  /// 'LettersOnly'.isAnyCaseLetter; // Returns true
  /// 'mixedCASE'.isAnyCaseLetter;   // Returns true
  /// '123Letters'.isAnyCaseLetter;  // Returns false
  /// ''.isAnyCaseLetter;           // Returns false
  /// ```
  ///
  /// NOTE: supports unicode
  bool get isAnyCaseLetter => _anyCaseLetterRegex.hasMatch(this);

  /// Checks if the string contains only uppercase letters (A-Z).
  ///
  /// This method uses a regular expression to determine if all characters in the string
  /// are uppercase letters. It does not consider numbers, symbols, or whitespace as
  ///  uppercase letters.
  ///
  /// Returns:
  /// `true` if the string consists entirely of uppercase letters, `false` otherwise.
  ///  Returns `false` for empty strings.
  ///
  /// Example:
  /// ```dart
  /// 'UPPERCASE'.isAllLetterUpperCase; // Returns true
  /// 'MixedCase'.isAllLetterUpperCase; // Returns false
  /// '123'.isAllLetterUpperCase;     // Returns false
  /// ''.isAllLetterUpperCase;        // Returns false
  /// ```
  bool get isAllLetterUpperCase => _allLetterUpperCaseRegex.hasMatch(this);

  /// Capitalizes the first letter of each word in the string, leaving other characters as they are.
  ///
  /// Words are delimited by spaces. If `lowerCaseRemaining` is set to `true`, all characters
  /// except the first letter of each word are converted to lowercase.
  ///
  /// Parameters:
  ///   - `lowerCaseRemaining`: A boolean value. If `true`, converts the remaining characters of
  ///      each word to lowercase. Defaults to `false`.
  ///
  /// Returns:
  /// A new string with the first letter of each word capitalized. Returns the original string if
  ///  it is empty.
  ///
  /// Example:
  /// ```dart
  /// 'hello world'.capitalizeWords(); // Returns 'Hello World'
  /// 'mixed CASE words'.capitalizeWords(lowerCaseRemaining: true); // Returns 'Mixed Case Words'
  /// ''.capitalizeWords(); // Returns ''
  /// ```
  String capitalizeWords({bool makeLowerCaseRemaining = false}) {
    if (isEmpty) {
      // failed null or empty check
      return this;
    }

    final List<String> originalWords = split(' '); // Keep original words with spaces

    // The original code was using words() which effectively removed extra spaces.
    final List<String> capitalizedWords = originalWords.map((String word) {
      if (word.isNotEmpty) {
        return word.capitalize(makeLowerCaseRemaining: makeLowerCaseRemaining);
      }
      return word; // Keep empty strings (for multiple spaces)
    }).toList();

    return capitalizedWords.join(' ');
  }

  /// Converts the first character of the string to lowercase, leaving the rest of the string unchanged.
  ///
  /// If the string is empty, it returns an empty string.
  ///
  /// Returns:
  /// A new string with the first character in lowercase, or an empty string if the original string is empty.
  ///
  /// Example:
  /// ```dart
  /// 'MixedCase'.lowerCaseFirstChar(); // Returns 'mixedCase'
  /// 'lowercase'.lowerCaseFirstChar(); // Returns 'lowercase'
  /// ''.lowerCaseFirstChar();        // Returns ''
  /// ```
  String lowerCaseFirstChar() => isEmpty ? '' : this[0].toLowerCase() + substringSafe(1);

  /// Converts the first character of the string to uppercase, leaving the rest of the string unchanged.
  ///
  /// If the string is empty, it returns an empty string.
  ///
  /// Returns:
  /// A new string with the first character in uppercase, or an empty string if the original string is empty.
  ///
  /// Example:
  /// ```dart
  /// 'mixedCase'.upperCaseFirstChar(); // Returns 'MixedCase'
  /// 'UPPERCASE'.upperCaseFirstChar(); // Returns 'UPPERCASE'
  /// ''.upperCaseFirstChar();        // Returns ''
  /// ```
  String upperCaseFirstChar() => isEmpty ? '' : this[0].toUpperCase() + substringSafe(1);

  /// Converts the string to title case, capitalizing the first letter and lowercasing the rest.
  ///
  /// If the string is empty, it returns an empty string.
  ///
  /// Returns:
  /// A new string in title case, or an empty string if the original string is empty.
  ///
  /// Example:
  /// ```dart
  /// 'mIxEd cAsE'.titleCase(); // Returns 'Mixed case'
  /// 'TITLE CASE'.titleCase(); // Returns 'Title case'
  /// ''.titleCase();           // Returns ''
  /// ```
  String titleCase() => isEmpty ? '' : this[0].toUpperCase() + substringSafe(1).toLowerCase();

  /// Converts only the Latin alphabetic characters (a-z) in the string to uppercase, leaving
  /// other characters unchanged.
  ///
  /// This method iterates through the string and converts any Latin lowercase letters to uppercase,
  /// while leaving numbers, symbols, whitespace, and non-Latin characters untouched.
  ///
  /// Performance: Uses [StringBuffer] for O(n) time complexity instead of string concatenation
  /// which would be O(n²).
  ///
  /// Returns:
  /// A new string with Latin alphabetic characters converted to uppercase.
  ///
  // cspell: ignore latincafé123 uppercased
  /// Example:
  /// ```dart
  /// 'latincafé123'.toUpperLatinOnly(); // Returns 'LATINcafé123' (only 'latin' part is uppercased)
  /// 'UPPERCASE'.toUpperLatinOnly();    // Returns 'UPPERCASE' (already uppercase)
  /// ''.toUpperLatinOnly();             // Returns ''
  /// ```
  String toUpperLatinOnly() {
    if (isEmpty) {
      return '';
    }

    // Use StringBuffer for O(n) performance instead of O(n²) string concatenation
    final StringBuffer buffer = StringBuffer();

    // ASCII code points for lowercase Latin letters
    const int codeUnitA = 0x61; // 'a'
    const int codeUnitZ = 0x7A; // 'z'

    // Don't iterate over runes because unicode / emoji == multiple runes
    for (int i = 0; i < length; i++) {
      final String s = this[i];
      final int codeUnit = s.codeUnitAt(0);
      if (codeUnit >= codeUnitA && codeUnit <= codeUnitZ) {
        buffer.write(s.toUpperCase());
      } else {
        buffer.write(s);
      }
    }

    // NOTE: If you want toUpperLatinOnly() to perform a more visually "correct" uppercasing of
    // accented Latin characters (transforming 'é' to 'É', 'à' to 'À', etc.), then you'll need to
    // modify the toUpperLatinOnly() method to include special handling for these characters. This
    // would likely involve:
    //
    // Creating a mapping of lowercase accented Latin characters to their uppercase counterparts.
    // You would need to identify the specific accented characters you want to handle.
    //
    // Checking for these lowercase accented characters in your loop.
    //
    // Replacing them with their uppercase equivalents from your mapping if found.
    //
    // For other characters, keep the existing toUpperCase() logic.
    return buffer.toString();
  }

  /// Capitalizes the first letter of the string, leaving the rest of the string unchanged.
  ///
  /// If `lowerCaseRemaining` is set to `true`, all characters after the first one are converted
  ///  to lowercase.
  ///
  /// Parameters:
  ///   - `lowerCaseRemaining`: A boolean value. If `true`, converts the remaining characters to
  ///  lowercase. Defaults to `false`.
  ///
  /// Returns:
  /// A new string with the first letter capitalized. Returns the original string if it is empty.
  ///
  /// Example:
  /// ```dart
  /// 'lowercase'.capitalize(); // Returns 'Lowercase'
  /// 'mIxEd'.capitalize(lowerCaseRemaining: true); // Returns 'Mixed'
  /// ''.capitalize();        // Returns ''
  /// ```
  String capitalize({bool makeLowerCaseRemaining = false}) {
    if (isEmpty) {
      // failed null or empty check
      return this;
    }

    // https://stackoverflow.com/questions/29628989/how-to-capitalize-the-first-letter-of-a-string-in-dart
    if (makeLowerCaseRemaining) {
      return '${this[0].toUpperCase()}${substringSafe(1).toLowerCase()}';
    }

    return '${this[0].toUpperCase()}${substringSafe(1)}';
  }

  /// Extracts and concatenates only the uppercase letters from the string.
  ///
  /// This method iterates through the runes of the string and checks if each character is an uppercase letter.
  /// If it is, the character is appended to the result.
  ///
  /// Performance: Uses [StringBuffer] for O(n) time complexity instead of string concatenation
  /// which would be O(n²).
  ///
  /// Returns:
  /// A new string containing only the uppercase letters from the original string.
  ///
  /// Example:
  /// ```dart
  /// 'Ben Bright 1234'.upperCaseLettersOnly(); // Returns 'BB'
  /// 'UPPERCASE'.upperCaseLettersOnly();       // Returns 'UPPERCASE'
  /// 'lowercase'.upperCaseLettersOnly();       // Returns ''
  /// ''.upperCaseLettersOnly();                // Returns ''
  /// ```
  String upperCaseLettersOnly() {
    if (isEmpty) {
      return '';
    }

    // Use StringBuffer for O(n) performance instead of O(n²) string concatenation
    final StringBuffer buffer = StringBuffer();

    // https://stackoverflow.com/questions/9286885/how-to-iterate-over-a-string-char-by-char-in-dart
    for (final int rune in runes) {
      final String c = String.fromCharCode(rune);

      if (c.isAllLetterUpperCase) {
        buffer.write(c);
      }
    }

    return buffer.toString();
  }

  /// Finds and returns a list of words from the string that are capitalized (start with an
  ///  uppercase letter).
  ///
  /// This method splits the string into words and then filters out the words that start with
  ///  an uppercase letter.
  ///
  /// The definition of a 'word' is determined by the [words] method of [StringExtensions].
  ///
  /// Returns:
  /// A [List<String>?] containing the capitalized words found in the string, or `null` if no
  ///  capitalized words are found, or if the original string is empty.
  ///
  /// Example:
  /// ```dart
  /// 'Find Capitalized Words'.findCapitalizedWords(); // Returns ['Find', 'Capitalized', 'Words']
  /// 'No capitalized words'.findCapitalizedWords();  // Returns null
  /// ''.findCapitalizedWords();                     // Returns null
  /// ```
  List<String>? findCapitalizedWords() {
    if (isEmpty) {
      // failed null or empty check
      return null;
    }

    return words()
        ?.where((String word) => word.isNotEmpty && word[0].isAllLetterUpperCase)
        .toList()
        .nullIfEmpty();
  }

  /// Inserts a space between words that are capitalized in a string (CamelCase or PascalCase).
  ///
  /// This method splits the string based on capitalization patterns (e.g., from CamelCase to "Camel Case")
  /// and then joins the split parts with spaces. If `splitNumbers` is true, it also splits words before numbers
  /// (e.g., "Numbers123" to "Numbers 123").
  ///
  /// Parameters:
  ///   - `splitNumbers`: A boolean value. If `true`, also splits words before numbers. Defaults to `false`.
  ///
  /// Returns:
  /// A new string with spaces inserted between capitalized words. Returns an empty string if the original string is empty.
  ///
  /// Example:
  /// ```dart
  /// 'InsertSpaceBetweenCapitalized'.insertSpaceBetweenCapitalized(); // Returns 'Insert Space Between Capitalized'
  /// 'SplitNumbers123'.insertSpaceBetweenCapitalized(splitNumbers: true); // Returns 'Split Numbers 123'
  /// ''.insertSpaceBetweenCapitalized(); // Returns ''
  /// ```
  ///
  /// NOTE:  No split for Unicode
  /// NOTE:  .trim() is applied afterwards
  String insertSpaceBetweenCapitalized({bool splitNumbers = false}) {
    if (isEmpty) {
      // failed null or empty check
      return '';
    }

    final List<String> words = splitCapitalized(splitNumbers: splitNumbers);
    if (words.isEmpty) {
      return '';
    }

    // the first word may not be capitalized
    words[0] = words[0].capitalize();

    return words.join(' ').trim();
  }

  /// Splits a CamelCase or PascalCase string into a list of words based on capitalization.
  ///
  /// This method uses regular expressions to split the string at the boundaries between lowercase
  /// and uppercase letters, effectively separating CamelCase or PascalCase words.
  ///  If `splitNumbers` is true, it also splits before numbers that follow lowercase letters.
  ///
  /// Parameters:
  ///   - `splitNumbers`: A boolean value. If `true`, also splits words before numbers.
  ///  Defaults to `false`.
  ///
  /// Returns:
  /// A [List<String>] of words split from the CamelCase or PascalCase string.
  ///
  /// Example:
  /// ```dart
  /// 'SplitCapitalizedWords'.splitCapitalized(); // Returns ['Split', 'Capitalized', 'Words']
  /// 'Numbers123Split'.splitCapitalized(splitNumbers: true); // Returns ['Numbers', '123', 'Split']
  /// ''.splitCapitalized(); // Returns []
  /// ```
  List<String> splitCapitalized({bool splitNumbers = false}) {
    // Return empty list for empty input string
    if (isEmpty) {
      return <String>[];
    }

    // ref: https://stackoverflow.com/questions/53718516/separate-a-pascalcase-string-into-separate-words-using-dart
    final RegExp pattern = splitNumbers
        // RegExp to split numbers
        ? _splitCapitalizedWithNumbersRegex
        : _splitCapitalizedRegex;

    return split(pattern);
  }

  /// Finds and returns a list of words from the string that are uncapitalized (start with a
  ///  lowercase letter).
  ///
  /// This method splits the string into words and then filters out the words that start with a
  ///  lowercase letter.
  /// The definition of a 'word' is determined by the [words] method of [StringExtensions].
  ///
  /// Returns:
  /// A [List<String>?] containing the uncapitalized words found in the string, or `null` if no
  ///  uncapitalized words are found, or if the original string is empty.
  ///
  /// Example:
  /// ```dart
  /// 'Find uncapitalized Words here'.unCapitalizedWords(); // Returns ['uncapitalized', 'here']
  /// 'CAPITALIZED WORDS'.unCapitalizedWords();           // Returns null
  /// ''.unCapitalizedWords();                              // Returns null
  /// ```
  List<String>? unCapitalizedWords() => words()
      ?.where((String word) => word.isNotEmpty && word[0].isAllLetterLowerCase)
      .toList()
      .nullIfEmpty();
}
