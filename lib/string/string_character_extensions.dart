import 'package:characters/characters.dart';

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
  /// **Args:**
  /// - [graphemeStart]: The starting grapheme index (inclusive).
  /// - [graphemeEnd]: The ending grapheme index (exclusive). If null, goes to end.
  ///
  /// **Returns:**
  /// The substring between the grapheme indices, or empty string if invalid.
  String substringCharacter(int graphemeStart, [int? graphemeEnd]) {
    if (isEmpty) return '';

    final Characters chars = characters;
    final int len = chars.length;

    if (graphemeStart < 0 || graphemeStart > len) return '';

    final int end = graphemeEnd ?? len;
    if (end < graphemeStart || end > len) return '';
    if (graphemeStart == end) return '';

    return chars.skip(graphemeStart).take(end - graphemeStart).toString();
  }

  /// Gets the first grapheme cluster (character).
  ///
  /// **Args:**
  /// - [trim]: If true (default), trims the string before getting the first character.
  /// - [supportGraphemes]: If true (default), handles multi-byte Unicode characters
  ///   as single grapheme clusters (e.g., emoji with skin tones, family emojis).
  ///
  /// **Returns:**
  /// The first character, or empty string if the string is empty.
  String firstCharacter({bool trim = true, bool supportGraphemes = true}) {
    final String effective = trim ? this.trim() : this;
    if (effective.isEmpty) return '';

    if (supportGraphemes) {
      return effective.characters.first;
    }

    // Without grapheme support, return the first rune (code point)
    return String.fromCharCode(effective.runes.first);
  }

  /// Gets the second grapheme cluster (character).
  ///
  /// **Args:**
  /// - [trim]: If true (default), trims the string before getting the character.
  /// - [supportGraphemes]: If true (default), handles multi-byte Unicode characters
  ///   as single grapheme clusters (e.g., emoji with skin tones, family emojis).
  ///
  /// **Returns:**
  /// The second character, or empty string if the string has fewer than 2 characters.
  String secondCharacter({bool trim = true, bool supportGraphemes = true}) {
    final String effective = trim ? this.trim() : this;
    if (effective.isEmpty) return '';

    if (supportGraphemes) {
      final Characters chars = effective.characters;
      if (chars.length < 2) return '';
      return chars.elementAt(1);
    }

    // Without grapheme support, use runes (code points)
    final List<int> runeList = effective.runes.toList();
    if (runeList.length < 2) return '';
    return String.fromCharCode(runeList[1]);
  }

  /// Gets the grapheme length (number of user-perceived characters).
  ///
  /// This counts Unicode grapheme clusters rather than code units.
  /// For example, an emoji like 👨‍👩‍👧 counts as 1 grapheme even though
  /// it consists of multiple code points.
  int get graphemeLength => characters.length;
}
