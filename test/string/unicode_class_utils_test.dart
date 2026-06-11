import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/unicode_class_type.dart';
import 'package:saropa_dart_utils/string/unicode_class_utils.dart';

// cspell: disable
void main() {
  group('String Unicode Utils', () {
    group('findUnicodeClassType - empty and blank', () {
      test('should return null for empty string', () {
        expect(findUnicodeClassType(''), isNull);
      });

      test('should return null for single ASCII space (trimmed away)', () {
        expect(findUnicodeClassType(' '), isNull);
      });

      test('should return null for multiple ASCII spaces', () {
        expect(findUnicodeClassType('   '), isNull);
      });

      test('should return null for mixed ASCII whitespace', () {
        expect(findUnicodeClassType(' \t \n '), isNull);
      });

      test('should return null for a tab only', () {
        expect(findUnicodeClassType('\t'), isNull);
      });

      test('should return null for a newline only', () {
        expect(findUnicodeClassType('\n'), isNull);
      });

      // The narrow no-break space (U+202F) survives Dart's String.trim, so this
      // asserts the ignoreWhitespace scan — not trim — is what skips it.
      test('should return null for narrow no-break space (survives trim)', () {
        expect(findUnicodeClassType(' '), isNull);
      });

      // The ideographic space (U+3000) also survives trim.
      test('should return null for ideographic space only', () {
        expect(findUnicodeClassType('　'), isNull);
      });
    });

    group('findUnicodeClassType - BasicLatin', () {
      test('should classify lowercase a..z as BasicLatin', () {
        expect(findUnicodeClassType('a'), UnicodeClassType.BasicLatin);
        expect(findUnicodeClassType('z'), UnicodeClassType.BasicLatin);
      });

      test('should classify uppercase letters as BasicLatin', () {
        expect(findUnicodeClassType('A'), UnicodeClassType.BasicLatin);
      });

      test('should classify digits 0 and 9 as BasicLatin', () {
        expect(findUnicodeClassType('0'), UnicodeClassType.BasicLatin);
        expect(findUnicodeClassType('9'), UnicodeClassType.BasicLatin);
      });
    });

    group('findUnicodeClassType - CJK and Arabic (spec samples)', () {
      test('should classify CJK ideographs', () {
        // '相浦由莉絵' — String.fromCharCodes is not a const constructor.
        final String cjk = String.fromCharCodes(<int>[
          0x76F8, 0x6D66, 0x7531, 0x83C9, 0x7D75,
        ]);
        expect(findUnicodeClassType(cjk), UnicodeClassType.CJKUnifiedIdeographs);
      });

      test('should classify Arabic script', () {
        // 'سلامی جمہوریہ پاكِستان'
        final String arabic = String.fromCharCodes(<int>[
          0x0633, 0x0644, 0x0627, 0x0645, 0x06CC, 0x0020,
          0x062C, 0x0645, 0x06C1, 0x0648, 0x0631, 0x06CC, 0x06C1, 0x0020,
          0x067E, 0x0627, 0x0643, 0x0650, 0x0633, 0x062A, 0x0627, 0x0646,
        ]);
        expect(findUnicodeClassType(arabic), UnicodeClassType.Arabic);
      });

      test('should skip Latin prefix and report Arabic', () {
        // ingnore latin
        // 'ignore اختبار'
        final String mixed = String.fromCharCodes(<int>[
          0x69, 0x67, 0x6E, 0x6F, 0x72, 0x65, 0x20,
          0x0627, 0x062E, 0x062A, 0x0628, 0x0627, 0x0631,
        ]);
        expect(
          findUnicodeClassType(mixed, ignoreBasicLatin: true, firstCharOnly: false),
          UnicodeClassType.Arabic,
        );
      });
    });

    group('findUnicodeClassType - specific scripts and symbols', () {
      test('should classify Cyrillic', () {
        expect(findUnicodeClassType('А'), UnicodeClassType.Cyrillic); // 'А'
      });

      test('should classify Hebrew', () {
        expect(findUnicodeClassType('א'), UnicodeClassType.Hebrew); // 'א'
      });

      test('should classify Greek', () {
        // 'Α' (Greek capital alpha)
        expect(findUnicodeClassType('Α'), UnicodeClassType.GreekOrGreekCoptic);
      });

      test('should classify Hiragana', () {
        expect(findUnicodeClassType('あ'), UnicodeClassType.Hiragana); // 'あ'
      });

      test('should classify Katakana', () {
        expect(findUnicodeClassType('ア'), UnicodeClassType.Katakana); // 'ア'
      });

      test('should classify a Hangul syllable', () {
        expect(findUnicodeClassType('가'), UnicodeClassType.HangulSyllables); // '가'
      });

      test('should classify Thai', () {
        expect(findUnicodeClassType('ก'), UnicodeClassType.Thai); // 'ก'
      });

      test('should classify Devanagari', () {
        expect(findUnicodeClassType('अ'), UnicodeClassType.Devanagari); // 'अ'
      });

      test('should classify the euro sign as a currency symbol', () {
        expect(findUnicodeClassType('€'), UnicodeClassType.CurrencySymbols); // '€'
      });

      test('should classify a rightwards arrow', () {
        expect(findUnicodeClassType('→'), UnicodeClassType.Arrows); // '→'
      });
    });

    group('findUnicodeClassType - whitespace predicate', () {
      // Each whitespace flavor must be skipped (ignoreWhitespace: true) so a
      // string of only that character returns null after the scan.
      test('should skip every whitespace flavor when ignoreWhitespace is true', () {
        for (final int ws in _whitespaceSamples) {
          expect(
            findUnicodeClassType(String.fromCharCode(ws)),
            isNull,
            reason: 'U+${ws.toRadixString(16)} should be skipped',
          );
        }
      });

      // With ignoreWhitespace: false the same runes classify into their block.
      test('should classify NBSP to Latin1Supplement when not ignoring whitespace', () {
        expect(
          findUnicodeClassType(' ', ignoreWhitespace: false),
          UnicodeClassType.Latin1Supplement,
        );
      });

      test('should classify en-space to GeneralPunctuation when not ignoring whitespace', () {
        expect(
          findUnicodeClassType(' ', ignoreWhitespace: false),
          UnicodeClassType.GeneralPunctuation,
        );
      });

      test('should classify ideographic space to CJK punctuation when not ignoring whitespace', () {
        expect(
          findUnicodeClassType('　', ignoreWhitespace: false),
          UnicodeClassType.CJKSymbolsAndPunctuation,
        );
      });
    });

    group('isUnicodeWhitespace', () {
      test('should return true for every documented whitespace rune', () {
        for (final int ws in _whitespaceSamples) {
          expect(
            isUnicodeWhitespace(ws),
            isTrue,
            reason: 'U+${ws.toRadixString(16)} should be whitespace',
          );
        }
      });

      test('should return false for a letter', () {
        expect(isUnicodeWhitespace(0x41), isFalse); // 'A'
      });

      test('should return false for an astral code point', () {
        expect(isUnicodeWhitespace(0x1F600), isFalse); // emoji
      });
    });

    group('findUnicodeClassType - block boundaries', () {
      // Table-driven: every block's first and last rune must map to that block.
      // This catches off-by-one drift in any range bound.
      test('should map each block start and end to that block', () {
        for (final UnicodeClass block in unicodeClassRanges) {
          // Surrogate ranges are never reachable from a valid Dart string, so
          // building a String.fromCharCode for them would be meaningless; the
          // table-integrity tests below cover those entries instead.
          if (_isSurrogateBlock(block.type)) {
            continue;
          }
          // Whitespace bounds (e.g. ogham space U+1680) are skipped by the
          // default scan, so assert with ignoreWhitespace disabled.
          final UnicodeClassType? atStart = findUnicodeClassType(
            String.fromCharCode(block.start),
            ignoreWhitespace: false,
          );
          final UnicodeClassType? atEnd = findUnicodeClassType(
            String.fromCharCode(block.end),
            ignoreWhitespace: false,
          );
          expect(atStart, block.type, reason: 'start of ${block.type}');
          expect(atEnd, block.type, reason: 'end of ${block.type}');
        }
      });
    });

    group('findUnicodeClassType - unassigned gaps', () {
      // The table has holes; a rune inside a gap matches no block -> null. This
      // is the highest-value coverage gap (silent null in unassigned ranges).
      test('should return null between Syriac and Thaana (U+0750)', () {
        expect(findUnicodeClassType('ݐ'), isNull);
      });

      test('should return null in the U+0860 gap before Devanagari', () {
        expect(findUnicodeClassType('ࡠ'), isNull);
      });

      test('should return null between Tai Le and Khmer Symbols (U+1990)', () {
        expect(findUnicodeClassType('ᦐ'), isNull);
      });
    });

    group('findUnicodeClassType - surrogates and astral plane (BMP-only)', () {
      // An emoji is one rune above U+FFFF; the table tops out at Specials, so
      // it matches no block. This documents the BMP-only limit.
      test('should return null for an astral emoji rune', () {
        expect(findUnicodeClassType('\u{1F600}'), isNull);
      });

      // runes never yields a lone surrogate from a valid Dart string, so the
      // three surrogate enum blocks are unreachable via this API.
      test('should never expose surrogate blocks from valid strings', () {
        // A surrogate pair decodes to a single astral rune (null), never to a
        // surrogate block.
        const String pair = '\u{1F4A9}';
        final UnicodeClassType? result = findUnicodeClassType(pair);
        expect(result, isNot(UnicodeClassType.HighSurrogates));
        expect(result, isNot(UnicodeClassType.HighPrivateUseSurrogates));
        expect(result, isNot(UnicodeClassType.LowSurrogates));
        expect(result, isNull);
      });
    });

    group('findUnicodeClassType - firstCharOnly semantics', () {
      test('should skip leading whitespace then take the first real rune', () {
        // '  一abc' -> CJK (leading spaces skipped, first real rune wins)
        expect(
          findUnicodeClassType('  一abc'),
          UnicodeClassType.CJKUnifiedIdeographs,
        );
      });

      test('should stop at the first match when firstCharOnly is false', () {
        // 'a一' -> BasicLatin because 'a' matches first; scanning does not
        // continue past the first matched rune.
        expect(
          findUnicodeClassType('a一', firstCharOnly: false),
          UnicodeClassType.BasicLatin,
        );
      });
    });

    group('findUnicodeClassType - ignoreBasicLatin interactions', () {
      test('should return null for Latin-only when ignoring Latin (firstChar)', () {
        // 'abc' with ignoreBasicLatin + firstCharOnly -> first rune skipped in
        // the inner loop, then the outer loop breaks -> null.
        expect(
          findUnicodeClassType('abc', ignoreBasicLatin: true),
          isNull,
        );
      });

      test('should reach Cyrillic when scanning past ignored Latin', () {
        // 'aЀ' with ignoreBasicLatin + firstCharOnly:false -> Cyrillic.
        expect(
          findUnicodeClassType('aЀ', ignoreBasicLatin: true, firstCharOnly: false),
          UnicodeClassType.Cyrillic,
        );
      });

      test('should return null when firstCharOnly breaks before reaching Cyrillic', () {
        // 'aЀ' with ignoreBasicLatin + firstCharOnly:true -> null: 'a' is Latin
        // (skipped in inner loop) but firstCharOnly breaks the outer loop, so
        // the Cyrillic rune is never inspected. Non-obvious refactor trap.
        expect(
          findUnicodeClassType('aЀ', ignoreBasicLatin: true),
          isNull,
        );
      });
    });

    group('findUnicodeClassType - combining marks', () {
      // Built from explicit code points (NOT a precomposed 'é' literal, which is
      // a single U+00E9 rune in Latin1Supplement) so the two-rune sequence
      // base-letter + combining-acute is guaranteed.
      final String decomposedEAcute = String.fromCharCodes(<int>[
        0x65, // 'e' (BasicLatin)
        0x0301, // combining acute accent (CombiningDiacriticalMarks)
      ]);

      test('should classify the base letter before a combining mark', () {
        // First rune 'e' is BasicLatin.
        expect(
          findUnicodeClassType(decomposedEAcute),
          UnicodeClassType.BasicLatin,
        );
      });

      test('should reach the combining mark when Latin is ignored and scanning', () {
        // With ignoreBasicLatin + firstCharOnly:false -> CombiningDiacriticalMarks.
        expect(
          findUnicodeClassType(
            decomposedEAcute,
            ignoreBasicLatin: true,
            firstCharOnly: false,
          ),
          UnicodeClassType.CombiningDiacriticalMarks,
        );
      });
    });

    group('unicodeClassRanges - table integrity', () {
      test('should be sorted ascending and non-overlapping', () {
        for (int i = 1; i < unicodeClassRanges.length; i++) {
          final UnicodeClass prev = unicodeClassRanges[i - 1];
          final UnicodeClass curr = unicodeClassRanges[i];
          // start[i] > end[i-1] guarantees no overlap and strict ascending order.
          expect(
            curr.start > prev.end,
            isTrue,
            reason: '${curr.type} start must exceed ${prev.type} end',
          );
        }
      });

      test('should have start <= end for every block', () {
        for (final UnicodeClass block in unicodeClassRanges) {
          expect(block.start <= block.end, isTrue, reason: '${block.type}');
        }
      });

      test('should contain every enum value exactly once', () {
        final List<UnicodeClassType> typesInTable =
            unicodeClassRanges.map((UnicodeClass b) => b.type).toList();
        // Catch a future enum addition that forgets its range entry, and any
        // accidental duplicate range row.
        for (final UnicodeClassType type in UnicodeClassType.values) {
          expect(
            typesInTable.where((UnicodeClassType t) => t == type).length,
            1,
            reason: '$type must appear exactly once in unicodeClassRanges',
          );
        }
        expect(typesInTable, hasLength(UnicodeClassType.values.length));
      });
    });
  });
}

/// Every whitespace code point the predicate must recognize, per the spec's
/// Bulletproofing list (ASCII controls + Unicode space separators).
const List<int> _whitespaceSamples = <int>[
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0x85, 0xA0,
  0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005,
  0x2006, 0x2007, 0x2008, 0x2009, 0x200A,
  0x2028, 0x2029, 0x202F, 0x205F, 0x3000,
];

/// True for the three surrogate blocks, which are unreachable from a valid Dart
/// string and therefore cannot be exercised by `String.fromCharCode` round-trips.
bool _isSurrogateBlock(UnicodeClassType type) =>
    type == UnicodeClassType.HighSurrogates ||
    type == UnicodeClassType.HighPrivateUseSurrogates ||
    type == UnicodeClassType.LowSurrogates;
// cspell: enable
