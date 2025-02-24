/// Extension on [String] to provide punctuation removal functionality.
extension StringPunctuation on String {
  /// Regular expression to remove punctuation while preserving alphabetic characters,
  /// **numbers**, and whitespace.
  ///
  /// This regex `r'[^\p{L}\s\p{N}]+'` works as follows:
  ///   - `[^...]`:  Negation - matches any character that is *not* in the set.
  ///   - `\p{L}`:    Unicode property for "Letter". This matches any kind of letter from any language.
  ///   - `\s`:     Whitespace characters (spaces, tabs, newlines, etc.).
  ///   - `\p{N}`:    Unicode property for "Number". This matches any kind of numeric character in any script.
  ///   - `+`:      Matches one or more occurrences of the preceding element.
  ///
  /// Therefore, the entire regex matches one or more characters that are NOT letters, NOT whitespace, **and NOT numbers**,
  /// effectively targeting punctuation and symbols for removal, while preserving letters, whitespace, and numbers.
  static final RegExp punctuationRegex = RegExp(r'[^\p{L}\s\p{N}]+', unicode: true);

  /// Removes punctuation characters from a string, while preserving
  /// alphabetic characters (including accented characters and characters
  /// from other languages like Chinese, Japanese, and Korean), **numbers**, and whitespace.
  ///
  /// The method uses a Unicode-aware regular expression ([punctuationRegex]) to identify and remove
  /// any character that is not a letter (as defined by Unicode Letter property `\p{L}`), whitespace (`\s`), or a number (`\p{N}`).
  /// This ensures that accented characters, characters from non-Latin alphabets, numbers, and various whitespace
  /// characters are correctly preserved, while common punctuation marks and symbols are removed.
  ///
  /// Note: Symbols that are not categorized as punctuation by the regex and are not letters, numbers, or whitespace will be removed.
  /// Emojis and certain special symbols might be removed as they are not classified as Unicode Letters, Numbers, or whitespace.
  ///
  /// Returns:
  ///   A new string with punctuation removed, while preserving letters, numbers, and whitespace.
  ///
  /// Example:
  /// ```dart
  /// String text = "Hello, world!  你好世界！(This is a test).";
  /// String cleanedText = text.removePunctuation();
  /// print(cleanedText); // Output: Hello world 你好世界 This is a test
  ///
  /// String accentedText = "café, résumé.";
  /// String cleanedAccentedText = accentedText.removePunctuation();
  /// print(cleanedAccentedText); // Output: café résumé
  ///
  /// String mixedText = "Text with 123 punctuation marks!";
  /// String cleanedMixedText = mixedText.removePunctuation();
  /// print(cleanedMixedText); // Output: Text with 123 punctuation marks
  /// ```
  String removePunctuation() => replaceAll(punctuationRegex, '');
}
