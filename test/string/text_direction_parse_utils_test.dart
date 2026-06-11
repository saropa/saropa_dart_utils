import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/text_direction_parse_utils.dart';

void main() {
  // cspell: disable
  group('TextDirectionParseUtils.tryParse', () {
    group('exact tokens', () {
      test('should parse exact lowercase ltr', () {
        expect(TextDirectionParseUtils.tryParse('ltr'), TextWritingDirection.ltr);
      });

      test('should parse exact lowercase rtl', () {
        expect(TextDirectionParseUtils.tryParse('rtl'), TextWritingDirection.rtl);
      });
    });

    group('case-insensitivity', () {
      test('should accept full uppercase', () {
        expect(TextDirectionParseUtils.tryParse('LTR'), TextWritingDirection.ltr);
        expect(TextDirectionParseUtils.tryParse('RTL'), TextWritingDirection.rtl);
      });

      test('should accept mixed case', () {
        expect(TextDirectionParseUtils.tryParse('Ltr'), TextWritingDirection.ltr);
        expect(TextDirectionParseUtils.tryParse('rTl'), TextWritingDirection.rtl);
      });

      // Spec "Case extremes": exercise several per-letter case permutations so a
      // future change to the lowercasing step can't silently break one casing.
      test('should accept arbitrary case permutations', () {
        expect(TextDirectionParseUtils.tryParse('lTr'), TextWritingDirection.ltr);
        expect(TextDirectionParseUtils.tryParse('ltR'), TextWritingDirection.ltr);
        expect(TextDirectionParseUtils.tryParse('Ltr'), TextWritingDirection.ltr);
        expect(TextDirectionParseUtils.tryParse('RtL'), TextWritingDirection.rtl);
        expect(TextDirectionParseUtils.tryParse('rTL'), TextWritingDirection.rtl);
        expect(TextDirectionParseUtils.tryParse('RTl'), TextWritingDirection.rtl);
      });

      // Locale-insensitive lowercasing: the tokens use only l/t/r, none of which
      // is the Turkish dotted/dotless-I, so the result can't depend on locale.
      test('should be independent of locale (no Turkish-I pitfall)', () {
        expect(TextDirectionParseUtils.tryParse('LTR'), TextWritingDirection.ltr);
        expect(TextDirectionParseUtils.tryParse('RTL'), TextWritingDirection.rtl);
      });
    });

    group('leading/trailing whitespace is trimmed', () {
      test('should trim ASCII spaces', () {
        expect(TextDirectionParseUtils.tryParse('  ltr  '), TextWritingDirection.ltr);
      });

      test('should trim tabs and newlines', () {
        expect(TextDirectionParseUtils.tryParse('\trtl\n'), TextWritingDirection.rtl);
        expect(TextDirectionParseUtils.tryParse('\nltr\r\n'), TextWritingDirection.ltr);
      });

      // String.trim() strips Unicode whitespace too; pin this so a future
      // change to the trimming step can't silently regress the contract.
      test('should trim non-breaking space (U+00A0)', () {
        expect(TextDirectionParseUtils.tryParse(' ltr '), TextWritingDirection.ltr);
      });

      test('should trim thin space (U+2009)', () {
        expect(TextDirectionParseUtils.tryParse(' ltr '), TextWritingDirection.ltr);
      });

      test('should trim ideographic space (U+3000)', () {
        expect(TextDirectionParseUtils.tryParse('　rtl'), TextWritingDirection.rtl);
      });
    });

    group('null / empty / blank → null', () {
      test('should return null for null', () {
        expect(TextDirectionParseUtils.tryParse(null), isNull);
      });

      test('should return null for empty string', () {
        expect(TextDirectionParseUtils.tryParse(''), isNull);
      });

      test('should return null for whitespace-only', () {
        expect(TextDirectionParseUtils.tryParse('   '), isNull);
      });

      // Every whitespace variant the spec lists must trim to empty → null.
      test('should return null for single-whitespace-character strings', () {
        expect(TextDirectionParseUtils.tryParse('\t'), isNull);
        expect(TextDirectionParseUtils.tryParse('\n'), isNull);
        expect(TextDirectionParseUtils.tryParse('\r\n'), isNull);
        expect(TextDirectionParseUtils.tryParse(' '), isNull);
      });
    });

    group('unknown tokens → null', () {
      test('should reject CSS-ish direction words', () {
        expect(TextDirectionParseUtils.tryParse('auto'), isNull);
        expect(TextDirectionParseUtils.tryParse('left'), isNull);
        expect(TextDirectionParseUtils.tryParse('right'), isNull);
      });
    });

    group('inner whitespace is NOT trimmed → null', () {
      // Only leading/trailing trim happens; spaces between letters are not
      // collapsed, so a spaced-out token must be rejected.
      test('should reject tokens with inner spaces', () {
        expect(TextDirectionParseUtils.tryParse('l t r'), isNull);
        expect(TextDirectionParseUtils.tryParse('r t l'), isNull);
        expect(TextDirectionParseUtils.tryParse('rt l'), isNull);
        expect(TextDirectionParseUtils.tryParse('lt r'), isNull);
      });
    });

    group('embedded / partial tokens → null (no substring matching)', () {
      test('should reject tokens with extra characters', () {
        expect(TextDirectionParseUtils.tryParse('ltrx'), isNull);
        expect(TextDirectionParseUtils.tryParse('xltr'), isNull);
        expect(TextDirectionParseUtils.tryParse('ltr ltr'), isNull);
        expect(TextDirectionParseUtils.tryParse('rtlrtl'), isNull);
        expect(TextDirectionParseUtils.tryParse('ltr;'), isNull);
      });
    });

    group('zero-width / formatting chars are NOT whitespace → null', () {
      // String.trim() does not strip zero-width chars, so a token prefixed by
      // one is unrecognized; pin the distinction from real whitespace above.
      test('should reject leading zero-width space (U+200B)', () {
        expect(TextDirectionParseUtils.tryParse('​ltr'), isNull);
      });

      test('should reject leading BOM / zero-width no-break space (U+FEFF)', () {
        expect(TextDirectionParseUtils.tryParse('﻿ltr'), isNull);
      });
    });

    group('Unicode direction marks are not the tokens → null', () {
      // LRM/RLM are direction control chars, not the literal strings 'ltr'/'rtl';
      // a reader in this domain might expect them to parse — assert they do not.
      test('should reject the LRM mark (U+200E)', () {
        expect(TextDirectionParseUtils.tryParse('‎'), isNull);
      });

      test('should reject the RLM mark (U+200F)', () {
        expect(TextDirectionParseUtils.tryParse('‏'), isNull);
      });
    });

    group('Unicode / emoji input → null (no normalization or folding)', () {
      test('should reject an emoji', () {
        expect(TextDirectionParseUtils.tryParse('\u{1F600}'), isNull);
      });

      // Accented l (combining acute) is not ASCII 'l', so the token can't match.
      test('should reject accented letters', () {
        expect(TextDirectionParseUtils.tryParse('ĺtr'), isNull);
      });

      // Full-width forms are distinct code points from ASCII; no width folding.
      test('should reject full-width letters', () {
        expect(TextDirectionParseUtils.tryParse('ｌｔｒ'), isNull);
      });
    });

    group('numeric-string tokens → null', () {
      // Guards against any caller that historically stored direction as an int.
      test('should reject integer-as-string values', () {
        expect(TextDirectionParseUtils.tryParse('0'), isNull);
        expect(TextDirectionParseUtils.tryParse('1'), isNull);
        expect(TextDirectionParseUtils.tryParse('-1'), isNull);
      });
    });

    group('idempotence / round-trip', () {
      // Serialize via enum name, then parse back; both values must survive the
      // round-trip so a name-based serializer stays a faithful inverse.
      test('should round-trip enum name through tryParse', () {
        for (final TextWritingDirection dir in TextWritingDirection.values) {
          expect(TextDirectionParseUtils.tryParse(dir.name), dir);
        }
      });
    });

    group('total function guarantee — never throws', () {
      // Fuzz-style: a parser fed config/JSON must be total. Asserting it returns
      // (not throws) across junk, control chars, and huge strings locks that in.
      test('should never throw for arbitrary junk input', () {
        final List<String?> junk = <String?>[
          null,
          '',
          '   ',
          ' ', // control characters
          '!@#%^&*()',
          'ltr ', // embedded NUL
          'a' * 100000, // very long string
          '\u{1F4A9}' * 1000, // long emoji run
          '0123456789',
        ];
        for (final String? input in junk) {
          // Only 'ltr'/'rtl' resolve; everything here must be null, never a throw.
          expect(() => TextDirectionParseUtils.tryParse(input), returnsNormally);
          expect(TextDirectionParseUtils.tryParse(input), isNull);
        }
      });
    });
  });
}
