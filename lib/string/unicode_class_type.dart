// The enum members below are a verbatim transcription of the public .NET
// "Supported Named Blocks" identifiers, which use PascalCase (e.g. `BasicLatin`,
// `CJKUnifiedIdeographs`). Renaming them to Dart's `lowerCamelCase` would break
// the one-to-one correspondence with the upstream Unicode/.NET names that makes
// this table auditable against the source, so the lint is suppressed file-wide.
// ignore_for_file: constant_identifier_names

/// Unicode named blocks of the Basic Multilingual Plane (U+0000 - U+FFFF).
///
/// Each member names a contiguous Unicode block and documents its inclusive
/// code-point range. The set mirrors the .NET "Supported Named Blocks" list so
/// the data can be audited line-by-line against the upstream reference.
///
/// Edge cases:
/// - This covers only the BMP. Astral-plane code points (U+10000 and above,
///   such as most emoji) fall outside every block here and are unclassifiable
///   via [findUnicodeClassType].
/// - [HighSurrogates], [HighPrivateUseSurrogates] and [LowSurrogates] exist for
///   completeness but are effectively unreachable from a valid Dart string:
///   `String.runes` never yields a lone surrogate, it decodes a surrogate pair
///   into a single code point above U+FFFF.
///
/// REF: https://learn.microsoft.com/dotnet/standard/base-types/character-classes-in-regular-expressions#supported-named-blocks
///
/// Example:
/// ```dart
/// findUnicodeClassType('a'); // UnicodeClassType.BasicLatin
/// ```
enum UnicodeClassType {
  /// Hex range: 0000 - 007F
  BasicLatin,

  /// Hex range: 0080 - 00FF
  Latin1Supplement,

  /// Hex range: 0100 - 017F
  LatinExtendedA,

  /// Hex range: 0180 - 024F
  LatinExtendedB,

  /// Hex range: 0250 - 02AF
  IPAExtensions,

  /// Hex range: 02B0 - 02FF
  SpacingModifierLetters,

  /// Hex range: 0300 - 036F
  CombiningDiacriticalMarks,

  /// Hex range: 0370 - 03FF
  GreekOrGreekCoptic,

  /// Hex range: 0400 - 04FF
  Cyrillic,

  /// Hex range: 0500 - 052F
  CyrillicSupplement,

  /// Hex range: 0530 - 058F
  Armenian,

  /// Hex range: 0590 - 05FF
  Hebrew,

  /// Hex range: 0600 - 06FF
  Arabic,

  /// Hex range: 0700 - 074F
  Syriac,

  /// Hex range: 0780 - 07BF
  Thaana,

  /// Hex range: 0900 - 097F
  Devanagari,

  /// Hex range: 0980 - 09FF
  Bengali,

  /// Hex range: 0A00 - 0A7F
  Gurmukhi,

  /// Hex range: 0A80 - 0AFF
  Gujarati,

  /// Hex range: 0B00 - 0B7F
  Oriya,

  /// Hex range: 0B80 - 0BFF
  Tamil,

  /// Hex range: 0C00 - 0C7F
  Telugu,

  /// Hex range: 0C80 - 0CFF
  Kannada,

  /// Hex range: 0D00 - 0D7F
  Malayalam,

  /// Hex range: 0D80 - 0DFF
  Sinhala,

  /// Hex range: 0E00 - 0E7F
  Thai,

  /// Hex range: 0E80 - 0EFF
  Lao,

  /// Hex range: 0F00 - 0FFF
  Tibetan,

  /// Hex range: 1000 - 109F
  Myanmar,

  /// Hex range: 10A0 - 10FF
  Georgian,

  /// Hex range: 1100 - 11FF
  HangulJamo,

  /// Hex range: 1200 - 137F
  Ethiopic,

  /// Hex range: 13A0 - 13FF
  Cherokee,

  /// Hex range: 1400 - 167F
  UnifiedCanadianAboriginalSyllabics,

  /// Hex range: 1680 - 169F
  Ogham,

  /// Hex range: 16A0 - 16FF
  Runic,

  /// Hex range: 1700 - 171F
  Tagalog,

  /// Hex range: 1720 - 173F
  Hanunoo,

  /// Hex range: 1740 - 175F
  Buhid,

  /// Hex range: 1760 - 177F
  Tagbanwa,

  /// Hex range: 1780 - 17FF
  Khmer,

  /// Hex range: 1800 - 18AF
  Mongolian,

  /// Hex range: 1900 - 194F
  Limbu,

  /// Hex range: 1950 - 197F
  TaiLe,

  /// Hex range: 19E0 - 19FF
  KhmerSymbols,

  /// Hex range: 1D00 - 1D7F
  PhoneticExtensions,

  /// Hex range: 1E00 - 1EFF
  LatinExtendedAdditional,

  /// Hex range: 1F00 - 1FFF
  GreekExtended,

  /// Hex range: 2000 - 206F
  GeneralPunctuation,

  /// Hex range: 2070 - 209F
  SuperscriptsAndSubscripts,

  /// Hex range: 20A0 - 20CF
  CurrencySymbols,

  /// Hex range: 20D0 - 20FF
  CombiningDiacriticalMarksForSymbols,

  /// Hex range: 2100 - 214F
  LetterLikeSymbols,

  /// Hex range: 2150 - 218F
  NumberForms,

  /// Hex range: 2190 - 21FF
  Arrows,

  /// Hex range: 2200 - 22FF
  MathematicalOperators,

  /// Hex range: 2300 - 23FF
  MiscellaneousTechnical,

  /// Hex range: 2400 - 243F
  ControlPictures,

  /// Hex range: 2440 - 245F
  OpticalCharacterRecognition,

  /// Hex range: 2460 - 24FF
  EnclosedAlphanumerics,

  /// Hex range: 2500 - 257F
  BoxDrawing,

  /// Hex range: 2580 - 259F
  BlockElements,

  /// Hex range: 25A0 - 25FF
  GeometricShapes,

  /// Hex range: 2600 - 26FF
  MiscellaneousSymbols,

  /// Hex range: 2700 - 27BF
  Dingbats,

  /// Hex range: 27C0 - 27EF
  MiscellaneousMathematicalSymbolsA,

  /// Hex range: 27F0 - 27FF
  SupplementalArrowsA,

  /// Hex range: 2800 - 28FF
  BraillePatterns,

  /// Hex range: 2900 - 297F
  SupplementalArrowsB,

  /// Hex range: 2980 - 29FF
  MiscellaneousMathematicalSymbolsB,

  /// Hex range: 2A00 - 2AFF
  SupplementalMathematicalOperators,

  /// Hex range: 2B00 - 2BFF
  MiscellaneousSymbolsAndArrows,

  /// Hex range: 2E80 - 2EFF
  CJKRadicalsSupplement,

  /// Hex range: 2F00 - 2FDF
  KangxiRadicals,

  /// Hex range: 2FF0 - 2FFF
  IdeographicDescriptionCharacters,

  /// Hex range: 3000 - 303F
  CJKSymbolsAndPunctuation,

  /// Hex range: 3040 - 309F
  Hiragana,

  /// Hex range: 30A0 - 30FF
  Katakana,

  /// Hex range: 3100 - 312F
  Bopomofo,

  /// Hex range: 3130 - 318F
  HangulCompatibilityJamo,

  /// Hex range: 3190 - 319F
  Kanbun,

  /// Hex range: 31A0 - 31BF
  BopomofoExtended,

  /// Hex range: 31F0 - 31FF
  KatakanaPhoneticExtensions,

  /// Hex range: 3200 - 32FF
  EnclosedCJKLettersAndMonths,

  /// Hex range: 3300 - 33FF
  CJKCompatibility,

  /// Hex range: 3400 - 4DBF
  CJKUnifiedIdeographsExtensionA,

  /// Hex range: 4DC0 - 4DFF
  YijingHexagramSymbols,

  /// Hex range: 4E00 - 9FFF
  CJKUnifiedIdeographs,

  /// Hex range: A000 - A48F
  YiSyllables,

  /// Hex range: A490 - A4CF
  YiRadicals,

  /// Hex range: AC00 - D7AF
  HangulSyllables,

  /// Hex range: D800 - DB7F
  HighSurrogates,

  /// Hex range: DB80 - DBFF
  HighPrivateUseSurrogates,

  /// Hex range: DC00 - DFFF
  LowSurrogates,

  /// Hex range: E000 - F8FF
  PrivateUseOrPrivateUseArea,

  /// Hex range: F900 - FAFF
  CJKCompatibilityIdeographs,

  /// Hex range: FB00 - FB4F
  AlphabeticPresentationForms,

  /// Hex range: FB50 - FDFF
  ArabicPresentationFormsA,

  /// Hex range: FE00 - FE0F
  VariationSelectors,

  /// Hex range: FE20 - FE2F
  CombiningHalfMarks,

  /// China-Japan unified compatibility forms.
  ///
  /// Hex range: FE30 - FE4F
  CJKCompatibilityForms,

  /// Hex range: FE50 - FE6F
  SmallFormVariants,

  /// Hex range: FE70 - FEFF
  ArabicPresentationFormsB,

  /// Hex range: FF00 - FFEF
  HalfWidthAndFullWidthForms,

  /// Hex range: FFF0 - FFFF
  Specials,
}
