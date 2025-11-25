/// Extension methods for grapheme-aware character operations.
///
/// These methods work with Unicode grapheme clusters (user-perceived characters)
/// rather than raw code units or code points.
extension StringCharacterExtensions on String {
  /// Gets a grapheme-aware substring.
  ///
  /// Unlike the standard [substring] which works with code units, this method
  /// counts and extracts based on user-perceived characters (grapheme clusters).
  ///
  /// Args:
  ///   graphemeStart: The starting grapheme index (inclusive).
  ///   graphemeEnd: The ending grapheme index (exclusive). If null, goes to end.
  ///
  /// Returns:
  ///   The substring between the grapheme indices, or empty string if invalid.
  String substringCharacter(int graphemeStart, [int? graphemeEnd]) {
    if (isEmpty) return '';

    // Convert to runes for grapheme-aware processing
    final List<int> runeList = runes.toList();
    final int len = runeList.length;

    if (graphemeStart < 0 || graphemeStart > len) return '';

    final int end = graphemeEnd ?? len;
    if (end < graphemeStart || end > len) return '';
    if (graphemeStart == end) return '';

    return String.fromCharCodes(runeList.sublist(graphemeStart, end));
  }

  /// Gets the first grapheme cluster (character).
  ///
  /// Args:
  ///   trim: If true (default), trims the string before getting the first character.
  ///   supportGraphemes: If true (default), handles multi-byte Unicode characters.
  ///
  /// Returns:
  ///   The first character, or empty string if the string is empty.
  String firstCharacter({bool trim = true, bool supportGraphemes = true}) {
    final String effective = trim ? this.trim() : this;
    if (effective.isEmpty) return '';

    if (supportGraphemes) {
      return String.fromCharCode(effective.runes.first);
    }

    return effective[0];
  }

  /// Gets the second grapheme cluster (character).
  ///
  /// Args:
  ///   trim: If true (default), trims the string before getting the character.
  ///   supportGraphemes: If true (default), handles multi-byte Unicode characters.
  ///
  /// Returns:
  ///   The second character, or empty string if the string has fewer than 2 characters.
  String secondCharacter({bool trim = true, bool supportGraphemes = true}) {
    final String effective = trim ? this.trim() : this;
    if (effective.isEmpty) return '';

    if (supportGraphemes) {
      final List<int> runeList = effective.runes.toList();
      if (runeList.length < 2) return '';
      return String.fromCharCode(runeList[1]);
    }

    if (effective.length < 2) return '';
    return effective[1];
  }

  /// Gets the grapheme length (number of user-perceived characters).
  ///
  /// This counts Unicode grapheme clusters rather than code units.
  /// For example, an emoji like 👨‍👩‍👧 counts as 1 grapheme even though
  /// it consists of multiple code points.
  int get graphemeLength => runes.length;
}
