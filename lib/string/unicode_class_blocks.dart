import 'package:saropa_dart_utils/string/unicode_class_type.dart';

/// A single Unicode named block paired with its inclusive code-point range.
///
/// [start] and [end] are both inclusive: a rune `r` belongs to this block when
/// `start <= r && r <= end`. Ranges never overlap and are stored sorted in the
/// internal registry, which lets `findUnicodeClassType` stop at the first match.
///
/// Example:
/// ```dart
/// const block = UnicodeClass(UnicodeClassType.BasicLatin, start: 0x0000, end: 0x007F);
/// block.start <= 0x41 && 0x41 <= block.end; // true — 'A' is BasicLatin
/// ```
class UnicodeClass {
  /// Creates a block descriptor for [type] spanning [start]..[end] inclusive.
  /// Audited: 2026-06-12 11:26 EDT
  const UnicodeClass(this.type, {required this.start, required this.end});

  /// The named block this range describes.
  final UnicodeClassType type;

  /// First code point of the block (inclusive).
  final int start;

  /// Last code point of the block (inclusive).
  final int end;
}

/// The Unicode block range table backing `findUnicodeClassType`.
///
/// Exposed (not private) so meta-tests can assert it stays sorted, gap-correct,
/// and one-entry-per-enum-value as the enum evolves. Values are the inclusive
/// BMP block bounds from the .NET "Supported Named Blocks" list; the original
/// `.toSigned(32)` coercions were dropped on import because every bound is well
/// below 2^31, making the coercion a no-op.
///
/// REF: https://learn.microsoft.com/dotnet/standard/base-types/character-classes-in-regular-expressions#supported-named-blocks
// cspell: disable
const List<UnicodeClass> unicodeClassRanges = <UnicodeClass>[
  UnicodeClass(UnicodeClassType.BasicLatin, start: 0x0000, end: 0x007F),
  UnicodeClass(UnicodeClassType.Latin1Supplement, start: 0x0080, end: 0x00FF),
  UnicodeClass(UnicodeClassType.LatinExtendedA, start: 0x0100, end: 0x017F),
  UnicodeClass(UnicodeClassType.LatinExtendedB, start: 0x0180, end: 0x024F),
  UnicodeClass(UnicodeClassType.IPAExtensions, start: 0x0250, end: 0x02AF),
  UnicodeClass(UnicodeClassType.SpacingModifierLetters, start: 0x02B0, end: 0x02FF),
  UnicodeClass(UnicodeClassType.CombiningDiacriticalMarks, start: 0x0300, end: 0x036F),
  UnicodeClass(UnicodeClassType.GreekOrGreekCoptic, start: 0x0370, end: 0x03FF),
  UnicodeClass(UnicodeClassType.Cyrillic, start: 0x0400, end: 0x04FF),
  UnicodeClass(UnicodeClassType.CyrillicSupplement, start: 0x0500, end: 0x052F),
  UnicodeClass(UnicodeClassType.Armenian, start: 0x0530, end: 0x058F),
  UnicodeClass(UnicodeClassType.Hebrew, start: 0x0590, end: 0x05FF),
  UnicodeClass(UnicodeClassType.Arabic, start: 0x0600, end: 0x06FF),
  UnicodeClass(UnicodeClassType.Syriac, start: 0x0700, end: 0x074F),
  UnicodeClass(UnicodeClassType.Thaana, start: 0x0780, end: 0x07BF),
  UnicodeClass(UnicodeClassType.Devanagari, start: 0x0900, end: 0x097F),
  UnicodeClass(UnicodeClassType.Bengali, start: 0x0980, end: 0x09FF),
  UnicodeClass(UnicodeClassType.Gurmukhi, start: 0x0A00, end: 0x0A7F),
  UnicodeClass(UnicodeClassType.Gujarati, start: 0x0A80, end: 0x0AFF),
  UnicodeClass(UnicodeClassType.Oriya, start: 0x0B00, end: 0x0B7F),
  UnicodeClass(UnicodeClassType.Tamil, start: 0x0B80, end: 0x0BFF),
  UnicodeClass(UnicodeClassType.Telugu, start: 0x0C00, end: 0x0C7F),
  UnicodeClass(UnicodeClassType.Kannada, start: 0x0C80, end: 0x0CFF),
  UnicodeClass(UnicodeClassType.Malayalam, start: 0x0D00, end: 0x0D7F),
  UnicodeClass(UnicodeClassType.Sinhala, start: 0x0D80, end: 0x0DFF),
  UnicodeClass(UnicodeClassType.Thai, start: 0x0E00, end: 0x0E7F),
  UnicodeClass(UnicodeClassType.Lao, start: 0x0E80, end: 0x0EFF),
  UnicodeClass(UnicodeClassType.Tibetan, start: 0x0F00, end: 0x0FFF),
  UnicodeClass(UnicodeClassType.Myanmar, start: 0x1000, end: 0x109F),
  UnicodeClass(UnicodeClassType.Georgian, start: 0x10A0, end: 0x10FF),
  UnicodeClass(UnicodeClassType.HangulJamo, start: 0x1100, end: 0x11FF),
  UnicodeClass(UnicodeClassType.Ethiopic, start: 0x1200, end: 0x137F),
  UnicodeClass(UnicodeClassType.Cherokee, start: 0x13A0, end: 0x13FF),
  UnicodeClass(UnicodeClassType.UnifiedCanadianAboriginalSyllabics, start: 0x1400, end: 0x167F),
  UnicodeClass(UnicodeClassType.Ogham, start: 0x1680, end: 0x169F),
  UnicodeClass(UnicodeClassType.Runic, start: 0x16A0, end: 0x16FF),
  UnicodeClass(UnicodeClassType.Tagalog, start: 0x1700, end: 0x171F),
  UnicodeClass(UnicodeClassType.Hanunoo, start: 0x1720, end: 0x173F),
  UnicodeClass(UnicodeClassType.Buhid, start: 0x1740, end: 0x175F),
  UnicodeClass(UnicodeClassType.Tagbanwa, start: 0x1760, end: 0x177F),
  UnicodeClass(UnicodeClassType.Khmer, start: 0x1780, end: 0x17FF),
  UnicodeClass(UnicodeClassType.Mongolian, start: 0x1800, end: 0x18AF),
  UnicodeClass(UnicodeClassType.Limbu, start: 0x1900, end: 0x194F),
  UnicodeClass(UnicodeClassType.TaiLe, start: 0x1950, end: 0x197F),
  UnicodeClass(UnicodeClassType.KhmerSymbols, start: 0x19E0, end: 0x19FF),
  UnicodeClass(UnicodeClassType.PhoneticExtensions, start: 0x1D00, end: 0x1D7F),
  UnicodeClass(UnicodeClassType.LatinExtendedAdditional, start: 0x1E00, end: 0x1EFF),
  UnicodeClass(UnicodeClassType.GreekExtended, start: 0x1F00, end: 0x1FFF),
  UnicodeClass(UnicodeClassType.GeneralPunctuation, start: 0x2000, end: 0x206F),
  UnicodeClass(UnicodeClassType.SuperscriptsAndSubscripts, start: 0x2070, end: 0x209F),
  UnicodeClass(UnicodeClassType.CurrencySymbols, start: 0x20A0, end: 0x20CF),
  UnicodeClass(UnicodeClassType.CombiningDiacriticalMarksForSymbols, start: 0x20D0, end: 0x20FF),
  UnicodeClass(UnicodeClassType.LetterLikeSymbols, start: 0x2100, end: 0x214F),
  UnicodeClass(UnicodeClassType.NumberForms, start: 0x2150, end: 0x218F),
  UnicodeClass(UnicodeClassType.Arrows, start: 0x2190, end: 0x21FF),
  UnicodeClass(UnicodeClassType.MathematicalOperators, start: 0x2200, end: 0x22FF),
  UnicodeClass(UnicodeClassType.MiscellaneousTechnical, start: 0x2300, end: 0x23FF),
  UnicodeClass(UnicodeClassType.ControlPictures, start: 0x2400, end: 0x243F),
  UnicodeClass(UnicodeClassType.OpticalCharacterRecognition, start: 0x2440, end: 0x245F),
  UnicodeClass(UnicodeClassType.EnclosedAlphanumerics, start: 0x2460, end: 0x24FF),
  UnicodeClass(UnicodeClassType.BoxDrawing, start: 0x2500, end: 0x257F),
  UnicodeClass(UnicodeClassType.BlockElements, start: 0x2580, end: 0x259F),
  UnicodeClass(UnicodeClassType.GeometricShapes, start: 0x25A0, end: 0x25FF),
  UnicodeClass(UnicodeClassType.MiscellaneousSymbols, start: 0x2600, end: 0x26FF),
  UnicodeClass(UnicodeClassType.Dingbats, start: 0x2700, end: 0x27BF),
  UnicodeClass(UnicodeClassType.MiscellaneousMathematicalSymbolsA, start: 0x27C0, end: 0x27EF),
  UnicodeClass(UnicodeClassType.SupplementalArrowsA, start: 0x27F0, end: 0x27FF),
  UnicodeClass(UnicodeClassType.BraillePatterns, start: 0x2800, end: 0x28FF),
  UnicodeClass(UnicodeClassType.SupplementalArrowsB, start: 0x2900, end: 0x297F),
  UnicodeClass(UnicodeClassType.MiscellaneousMathematicalSymbolsB, start: 0x2980, end: 0x29FF),
  UnicodeClass(UnicodeClassType.SupplementalMathematicalOperators, start: 0x2A00, end: 0x2AFF),
  UnicodeClass(UnicodeClassType.MiscellaneousSymbolsAndArrows, start: 0x2B00, end: 0x2BFF),
  UnicodeClass(UnicodeClassType.CJKRadicalsSupplement, start: 0x2E80, end: 0x2EFF),
  UnicodeClass(UnicodeClassType.KangxiRadicals, start: 0x2F00, end: 0x2FDF),
  UnicodeClass(UnicodeClassType.IdeographicDescriptionCharacters, start: 0x2FF0, end: 0x2FFF),
  UnicodeClass(UnicodeClassType.CJKSymbolsAndPunctuation, start: 0x3000, end: 0x303F),
  UnicodeClass(UnicodeClassType.Hiragana, start: 0x3040, end: 0x309F),
  UnicodeClass(UnicodeClassType.Katakana, start: 0x30A0, end: 0x30FF),
  UnicodeClass(UnicodeClassType.Bopomofo, start: 0x3100, end: 0x312F),
  UnicodeClass(UnicodeClassType.HangulCompatibilityJamo, start: 0x3130, end: 0x318F),
  UnicodeClass(UnicodeClassType.Kanbun, start: 0x3190, end: 0x319F),
  UnicodeClass(UnicodeClassType.BopomofoExtended, start: 0x31A0, end: 0x31BF),
  UnicodeClass(UnicodeClassType.KatakanaPhoneticExtensions, start: 0x31F0, end: 0x31FF),
  UnicodeClass(UnicodeClassType.EnclosedCJKLettersAndMonths, start: 0x3200, end: 0x32FF),
  UnicodeClass(UnicodeClassType.CJKCompatibility, start: 0x3300, end: 0x33FF),
  UnicodeClass(UnicodeClassType.CJKUnifiedIdeographsExtensionA, start: 0x3400, end: 0x4DBF),
  UnicodeClass(UnicodeClassType.YijingHexagramSymbols, start: 0x4DC0, end: 0x4DFF),
  UnicodeClass(UnicodeClassType.CJKUnifiedIdeographs, start: 0x4E00, end: 0x9FFF),
  UnicodeClass(UnicodeClassType.YiSyllables, start: 0xA000, end: 0xA48F),
  UnicodeClass(UnicodeClassType.YiRadicals, start: 0xA490, end: 0xA4CF),
  UnicodeClass(UnicodeClassType.HangulSyllables, start: 0xAC00, end: 0xD7AF),
  UnicodeClass(UnicodeClassType.HighSurrogates, start: 0xD800, end: 0xDB7F),
  UnicodeClass(UnicodeClassType.HighPrivateUseSurrogates, start: 0xDB80, end: 0xDBFF),
  UnicodeClass(UnicodeClassType.LowSurrogates, start: 0xDC00, end: 0xDFFF),
  UnicodeClass(UnicodeClassType.PrivateUseOrPrivateUseArea, start: 0xE000, end: 0xF8FF),
  UnicodeClass(UnicodeClassType.CJKCompatibilityIdeographs, start: 0xF900, end: 0xFAFF),
  UnicodeClass(UnicodeClassType.AlphabeticPresentationForms, start: 0xFB00, end: 0xFB4F),
  UnicodeClass(UnicodeClassType.ArabicPresentationFormsA, start: 0xFB50, end: 0xFDFF),
  UnicodeClass(UnicodeClassType.VariationSelectors, start: 0xFE00, end: 0xFE0F),
  UnicodeClass(UnicodeClassType.CombiningHalfMarks, start: 0xFE20, end: 0xFE2F),
  UnicodeClass(UnicodeClassType.CJKCompatibilityForms, start: 0xFE30, end: 0xFE4F),
  UnicodeClass(UnicodeClassType.SmallFormVariants, start: 0xFE50, end: 0xFE6F),
  UnicodeClass(UnicodeClassType.ArabicPresentationFormsB, start: 0xFE70, end: 0xFEFF),
  UnicodeClass(UnicodeClassType.HalfWidthAndFullWidthForms, start: 0xFF00, end: 0xFFEF),
  UnicodeClass(UnicodeClassType.Specials, start: 0xFFF0, end: 0xFFFF),
];
// cspell: enable
