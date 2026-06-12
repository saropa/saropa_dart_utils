// The enum members below are a verbatim transcription of the public .NET
// "Supported Named Blocks" identifiers, which use PascalCase (e.g. `BasicLatin`,
// `CJKUnifiedIdeographs`). Renaming them to Dart's `lowerCamelCase` would break
// the one-to-one correspondence with the upstream Unicode/.NET names that makes
// this table auditable against the source, so the lint is suppressed file-wide.
// ignore_for_file: constant_identifier_names

/// Unicode named blocks of the Basic Multilingual Plane (U+0000 - U+FFFF).
///
/// Each member names a contiguous Unicode block. The set mirrors the .NET
/// "Supported Named Blocks" list so the data can be audited line-by-line against
/// the upstream reference.
///
/// The inclusive code-point range for each block is NOT repeated here: it lives
/// once in `unicodeClassRanges` (see `unicode_class_blocks.dart`), the single
/// source of truth that `findUnicodeClassType` actually reads. Duplicating the
/// ranges in per-member doc comments would let the two drift when a bound is
/// retuned, so the range column is intentionally kept only in that table.
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
// cspell: disable
enum UnicodeClassType {
  BasicLatin,
  Latin1Supplement,
  LatinExtendedA,
  LatinExtendedB,
  IPAExtensions,
  SpacingModifierLetters,
  CombiningDiacriticalMarks,
  GreekOrGreekCoptic,
  Cyrillic,
  CyrillicSupplement,
  Armenian,
  Hebrew,
  Arabic,
  Syriac,
  Thaana,
  Devanagari,
  Bengali,
  Gurmukhi,
  Gujarati,
  Oriya,
  Tamil,
  Telugu,
  Kannada,
  Malayalam,
  Sinhala,
  Thai,
  Lao,
  Tibetan,
  Myanmar,
  Georgian,
  HangulJamo,
  Ethiopic,
  Cherokee,
  UnifiedCanadianAboriginalSyllabics,
  Ogham,
  Runic,
  Tagalog,
  Hanunoo,
  Buhid,
  Tagbanwa,
  Khmer,
  Mongolian,
  Limbu,
  TaiLe,
  KhmerSymbols,
  PhoneticExtensions,
  LatinExtendedAdditional,
  GreekExtended,
  GeneralPunctuation,
  SuperscriptsAndSubscripts,
  CurrencySymbols,
  CombiningDiacriticalMarksForSymbols,
  LetterLikeSymbols,
  NumberForms,
  Arrows,
  MathematicalOperators,
  MiscellaneousTechnical,
  ControlPictures,
  OpticalCharacterRecognition,
  EnclosedAlphanumerics,
  BoxDrawing,
  BlockElements,
  GeometricShapes,
  MiscellaneousSymbols,
  Dingbats,
  MiscellaneousMathematicalSymbolsA,
  SupplementalArrowsA,
  BraillePatterns,
  SupplementalArrowsB,
  MiscellaneousMathematicalSymbolsB,
  SupplementalMathematicalOperators,
  MiscellaneousSymbolsAndArrows,
  CJKRadicalsSupplement,
  KangxiRadicals,
  IdeographicDescriptionCharacters,
  CJKSymbolsAndPunctuation,
  Hiragana,
  Katakana,
  Bopomofo,
  HangulCompatibilityJamo,
  Kanbun,
  BopomofoExtended,
  KatakanaPhoneticExtensions,
  EnclosedCJKLettersAndMonths,
  CJKCompatibility,
  CJKUnifiedIdeographsExtensionA,
  YijingHexagramSymbols,
  CJKUnifiedIdeographs,
  YiSyllables,
  YiRadicals,
  HangulSyllables,
  HighSurrogates,
  HighPrivateUseSurrogates,
  LowSurrogates,
  PrivateUseOrPrivateUseArea,
  CJKCompatibilityIdeographs,
  AlphabeticPresentationForms,
  ArabicPresentationFormsA,
  VariationSelectors,
  CombiningHalfMarks,

  /// China-Japan unified compatibility forms (the one block whose name is not
  /// self-evident from its identifier).
  CJKCompatibilityForms,

  SmallFormVariants,
  ArabicPresentationFormsB,
  HalfWidthAndFullWidthForms,
  Specials,
}

// cspell: enable
