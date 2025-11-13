/// An extension on the String class to provide utility methods for handling
/// diacritical marks (accents).
extension StringDiacriticsExtensions on String {
  /// A lazily-initialized, reversed version of [_accentsMap].
  ///
  /// This map is created only once and cached for high performance. It maps
  /// each diacritic character (e.g., 'á') to its base character (e.g., 'a').
  static final Map<String, String> _reverseAccentsMap = _createReverseMap();

  /// A private helper function to create the reversed map from [_accentsMap].
  /// This is executed only once to initialize [_reverseAccentsMap].
  static Map<String, String> _createReverseMap() {
    final Map<String, String> reverseMap = <String, String>{};
    _accentsMap.forEach((String baseChar, List<String> diacriticList) {
      for (final String diacritic in diacriticList) {
        reverseMap[diacritic] = baseChar;
      }
    });
    return reverseMap;
  }

  // --- Public Methods ---

  /// Accurately checks if the string contains any diacritical characters
  /// that can be removed by the [removeDiacritics] method.
  ///
  /// Returns `true` if a known diacritic character is found, `false` otherwise.
  bool containsDiacritics() {
      // An empty string cannot contain diacritics.
      if (isEmpty) {
        return false;
      }
      // Check if any character in the string exists as a key in our map of diacritics.
      // This is more accurate than the previous regex approach.
      return split('').any((String char) => _reverseAccentsMap.containsKey(char));
  }

  /// Removes diacritical marks from the string, replacing them with their
  /// base ASCII equivalents (e.g., 'é' becomes 'e').
  ///
  /// This method is optimized to perform well by using a pre-computed map.
  String removeDiacritics() {
      // If the string is empty, return an empty string immediately.
      if (isEmpty) {
        return '';
      }

      // Use the pre-computed reversed map for an efficient lookup.
      // We map each character: if it's in our map, we replace it; otherwise,
      // we keep the original. Then we join the characters back into a string.
      return split('').map((String char) => _reverseAccentsMap[char] ?? char).join('');
  }

  // --- Private Static Members ---

  /// A map where keys are base ASCII characters and values are lists of
  /// their corresponding accented (diacritic) characters.
  // cspell: ignore Eszett
  // dart format off
  static const Map<String, List<String>> _accentsMap = <String, List<String>>{
    // Vowels
    'a': <String>['á', 'à', 'ä', 'â', 'ã', 'å', 'ą', 'ā', 'ă', 'ǎ', 'ȁ', 'ȃ', 'ȧ', 'ǡ', 'ǟ', 'ǻ'],
    'e': <String>['é', 'è', 'ë', 'ê', 'ę', 'ē', 'ĕ', 'ė', 'ě', 'ȅ', 'ȇ', 'ȩ', 'ɇ', 'ḕ', 'ḗ', 'ḙ', 'ḛ', 'ḝ', 'ẹ', 'ẻ', 'ẽ', 'ế'],
    'i': <String>['í', 'ì', 'ï', 'î', 'ī', 'ĭ', 'į', 'ǐ', 'ȉ', 'ȋ', 'ɨ', 'ḭ', 'ḯ', 'ỉ', 'ị', 'ĩ'],
    'o': <String>['ó', 'ò', 'ö', 'ô', 'õ', 'ø', 'ō', 'ŏ', 'ő', 'ǒ', 'ȍ', 'ȏ', 'ȫ', 'ȭ', 'ȯ', 'ȱ', 'ɔ', 'ṍ', 'ṏ', 'ṑ', 'ṓ', 'ọ'],
    'u': <String>['ú', 'ù', 'ü', 'û', 'ů', 'ų', 'ū', 'ŭ', 'ű', 'ǔ', 'ȕ', 'ȗ', 'ṳ', 'ṵ', 'ṷ', 'ṹ', 'ṻ', 'ụ', 'ủ', 'ũ'],
    'y': <String>['ý', 'ÿ', 'ȳ', 'ẏ', 'ỵ', 'ỷ', 'ỹ', 'ỿ'],

    // Consonants
    'c': <String>['č', 'ç', 'ć', 'ĉ', 'ċ', 'ȼ', 'ɕ', 'ḉ'],
    'd': <String>['ď', 'đ', 'ḑ', 'ḓ'],
    'g': <String>['ǵ', 'ğ', 'ġ', 'ģ', 'ĝ', 'ǧ', 'ǥ'],
    'h': <String>['ĥ', 'ħ'],
    'j': <String>['ĵ'],
    'k': <String>['ķ', 'ǩ', 'ḵ'],
    'l': <String>['ľ', 'ł', 'ĺ', 'ļ', 'ḷ', 'ḹ', 'ḻ', 'ḽ'],
    'n': <String>['ň', 'ñ', 'ń', 'ņ', 'ŉ', 'ŋ', 'ȵ', 'ɲ', 'ṅ', 'ṇ', 'ṉ', 'ṋ'],
    'r': <String>['ř', 'ŕ', 'ŗ', 'ṙ', 'ṛ', 'ṝ', 'ṟ'],
    's': <String>['š', 'ś', 'ş', 'ș', 'ȿ', 'ṡ', 'ṣ', 'ṥ', 'ṧ', 'ṩ'],
    't': <String>['ť', 'ț', 'ṫ', 'ṭ', 'ṯ', 'ṱ'],
    'w': <String>['ŵ', 'ẁ', 'ẃ', 'ẅ'],
    'z': <String>['ž', 'ź', 'ż', 'ƶ', 'ȥ', 'ɀ'],

    // Uppercase Vowels
    'A': <String>['Á', 'À', 'Ä', 'Â', 'Ã', 'Å', 'Ą', 'Ā', 'Ă', 'Ǎ', 'Ȁ', 'Ȃ', 'Ȧ', 'Ǡ', 'Ǟ', 'Ǻ'],
    'E': <String>['É', 'È', 'Ë', 'Ê', 'Ę', 'Ē', 'Ĕ', 'Ė', 'Ě', 'Ȅ', 'Ȇ', 'Ȩ', 'Ɇ', 'Ḕ', 'Ḗ', 'Ḙ', 'Ḛ', 'Ḝ', 'Ẹ', 'Ẻ', 'Ẽ', 'Ế'],
    'I': <String>['Í', 'Ì', 'Ï', 'Î', 'Ī', 'Ĭ', 'Į', 'Ǐ', 'Ȉ', 'Ȋ', 'Ɨ', 'Ḭ', 'Ḯ', 'Ỉ', 'Ị', 'Ĩ'],
    'O': <String>['Ó', 'Ò', 'Ö', 'Ô', 'Õ', 'Ø', 'Ō', 'Ŏ', 'Ő', 'Ǒ', 'Ȍ', 'Ȏ', 'Ȫ', 'Ȭ', 'Ȯ', 'Ȱ', 'Ɔ', 'Ṍ', 'Ṏ', 'Ṑ', 'Ṓ', 'Ọ'],
    'U': <String>['Ú', 'Ù', 'Ü', 'Û', 'Ů', 'Ų', 'Ū', 'Ŭ', 'Ű', 'Ǔ', 'Ȕ', 'Ȗ', 'Ṳ', 'Ṵ', 'Ṷ', 'Ṹ', 'Ṻ', 'Ụ', 'Ủ', 'Ũ'],
    'Y': <String>['Ý', 'Ÿ', 'Ȳ', 'Ẏ', 'Ỵ', 'Ỷ', 'Ỹ'],

    // Uppercase Consonants
    'C': <String>['Č', 'Ç', 'Ć', 'Ĉ', 'Ċ', 'Ȼ', 'Ƈ', 'Ḉ'],
    'D': <String>['Ď', 'Đ', 'Ḑ', 'Ḓ'],
    'G': <String>['Ǵ', 'Ğ', 'Ġ', 'Ģ', 'Ĝ', 'Ǧ', 'Ǥ'],
    'H': <String>['Ĥ', 'Ħ'],
    'J': <String>['Ĵ'],
    'K': <String>['Ķ', 'Ǩ', 'Ḵ'],
    'L': <String>['Ľ', 'Ł', 'Ĺ', 'Ļ', 'Ḷ', 'Ḹ', 'Ḻ', 'Ḽ'],
    'N': <String>['Ň', 'Ñ', 'Ń', 'Ņ', 'Ɲ', 'Ƞ', 'Ṅ', 'Ṇ', 'Ṉ', 'Ṋ'],
    'R': <String>['Ř', 'Ŕ', 'Ŗ', 'Ṙ', 'Ṛ', 'Ṝ', 'Ṟ'],
    'S': <String>['Š', 'Ś', 'Ş', 'Ș', 'Ṡ', 'Ṣ', 'Ṥ', 'Ṧ', 'Ṩ'],
    'T': <String>['Ť', 'Ţ', 'Ṫ', 'Ṭ', 'Ṯ', 'Ṱ'],
    'W': <String>['Ŵ', 'Ẁ', 'Ẃ', 'Ẅ'],
    'Z': <String>['Ž', 'Ź', 'Ż', 'Ƶ', 'Ȥ', 'Ẕ'],

    // Special Cases: Ligatures and the German Eszett
    'ss': <String>['ß'],
    'SS': <String>['ẞ'],
    'ae': <String>['æ'],
    'AE': <String>['Æ'],
    'oe': <String>['œ'],
    'OE': <String>['Œ'],
  };
// dart format on
}
