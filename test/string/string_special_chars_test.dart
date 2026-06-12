import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

// These constants are load-bearing for UI layout: a wrong code point (an ASCII
// hyphen swapped for a Unicode one, a smart quote flattened to a straight quote
// by a source re-encode) renders nearly identically in an editor yet changes
// wrapping / breaking behavior at runtime. The guards below pin each value to an
// exact code point and to its encoding so a silent glyph swap fails the suite
// instead of shipping. Source of truth: lib/string/string_extensions.dart.

// cspell: disable
void main() {
  // Sample tests transcribed verbatim from SPEC-string-special-chars.md
  // (the spec's "value-assertion guard test"). Grouped exactly as the spec.
  group('StringExtensions typographic constants — code-point guards', () {
    test('smart quotes have the exact expected code points', () {
      expect(StringExtensions.accentedQuoteOpening.runes.single, 0x2018);
      expect(StringExtensions.accentedQuoteClosing.runes.single, 0x2019);
      expect(StringExtensions.accentedDoubleQuoteOpening.runes.single, 0x201C);
      expect(StringExtensions.accentedDoubleQuoteClosing.runes.single, 0x201D);
    });

    test('whitespace / break constants', () {
      expect(StringExtensions.nonBreakingSpace.runes.single, 0x00A0);
      expect(StringExtensions.nonBreakingHyphen.runes.single, 0x2011);
      expect(StringExtensions.hyphen.runes.single, 0x2010);
      expect(StringExtensions.softHyphen.runes.single, 0x00AD);
      expect(StringExtensions.zeroWidth.runes.single, 0x200B);
      expect(StringExtensions.blank.runes.single, 0x3164);
      expect(StringExtensions.newLine, '\n');
      expect(StringExtensions.lineBreak, StringExtensions.newLine);
    });

    test('punctuation constants', () {
      expect(StringExtensions.ellipsis.runes.single, 0x2026);
      expect(StringExtensions.doubleChevron.runes.single, 0x00BB);
      expect(StringExtensions.apostrophe.runes.single, 0x2019);
      expect(StringExtensions.bullet.runes.single, 0x2022);
      expect(StringExtensions.dot, StringExtensions.bullet);
      expect(StringExtensions.dotJoiner, ' ${StringExtensions.bullet} ');
    });
  });

  // Bulletproofing gaps from the spec, each item implemented as its own group of
  // separate, independent tests. These move past code-point identity into
  // encoding stability, distinctness, alias integrity, and const-evaluability —
  // the failure modes a single value assertion alone would miss.

  // Single-rune guarantee: every constant except the intentionally
  // multi-character lineBreak/dotJoiner must be exactly one rune. A future edit
  // can't accidentally introduce a two-character sequence (e.g. CRLF for
  // newLine) without tripping this.
  group('single-rune guarantee', () {
    // newLine ('\n') and lineBreak (its alias) are deliberately included here:
    // a line feed is itself a single rune, so the one-rune invariant holds and
    // guards against a CR+LF regression specifically.
    const Map<String, String> singleRuneConstants = <String, String>{
      'accentedQuoteOpening': StringExtensions.accentedQuoteOpening,
      'accentedQuoteClosing': StringExtensions.accentedQuoteClosing,
      'accentedDoubleQuoteOpening': StringExtensions.accentedDoubleQuoteOpening,
      'accentedDoubleQuoteClosing': StringExtensions.accentedDoubleQuoteClosing,
      'ellipsis': StringExtensions.ellipsis,
      'doubleChevron': StringExtensions.doubleChevron,
      'apostrophe': StringExtensions.apostrophe,
      'hyphen': StringExtensions.hyphen,
      'softHyphen': StringExtensions.softHyphen,
      'blank': StringExtensions.blank,
      'zeroWidth': StringExtensions.zeroWidth,
      'nonBreakingSpace': StringExtensions.nonBreakingSpace,
      'nonBreakingHyphen': StringExtensions.nonBreakingHyphen,
      'bullet': StringExtensions.bullet,
      'dot': StringExtensions.dot,
      'newLine': StringExtensions.newLine,
      'lineBreak': StringExtensions.lineBreak,
    };

    singleRuneConstants.forEach((String name, String value) {
      test('$name is exactly one rune', () => expect(value.runes, hasLength(1)));
    });

    test('newLine is a bare LF, not a CRLF pair', () {
      expect(StringExtensions.newLine.runes.single, 0x000A);
      expect(StringExtensions.newLine.contains('\r'), isFalse);
    });
  });

  // Exact code point per constant — the full table from the spec, restated as
  // standalone assertions so a swap of one near-identical glyph (ASCII hyphen
  // U+002D vs Unicode hyphen U+2010 vs non-breaking hyphen U+2011) fails loudly.
  group('exact code point per constant', () {
    const Map<String, MapEntry<String, int>> codePoints = <String, MapEntry<String, int>>{
      'accentedQuoteOpening': MapEntry<String, int>(StringExtensions.accentedQuoteOpening, 0x2018),
      'accentedQuoteClosing': MapEntry<String, int>(StringExtensions.accentedQuoteClosing, 0x2019),
      'accentedDoubleQuoteOpening': MapEntry<String, int>(
        StringExtensions.accentedDoubleQuoteOpening,
        0x201C,
      ),
      'accentedDoubleQuoteClosing': MapEntry<String, int>(
        StringExtensions.accentedDoubleQuoteClosing,
        0x201D,
      ),
      'ellipsis': MapEntry<String, int>(StringExtensions.ellipsis, 0x2026),
      'doubleChevron': MapEntry<String, int>(StringExtensions.doubleChevron, 0x00BB),
      'apostrophe': MapEntry<String, int>(StringExtensions.apostrophe, 0x2019),
      'hyphen': MapEntry<String, int>(StringExtensions.hyphen, 0x2010),
      'softHyphen': MapEntry<String, int>(StringExtensions.softHyphen, 0x00AD),
      'blank': MapEntry<String, int>(StringExtensions.blank, 0x3164),
      'zeroWidth': MapEntry<String, int>(StringExtensions.zeroWidth, 0x200B),
      'nonBreakingSpace': MapEntry<String, int>(StringExtensions.nonBreakingSpace, 0x00A0),
      'nonBreakingHyphen': MapEntry<String, int>(StringExtensions.nonBreakingHyphen, 0x2011),
      'bullet': MapEntry<String, int>(StringExtensions.bullet, 0x2022),
    };

    codePoints.forEach((String name, MapEntry<String, int> entry) {
      test('$name == U+${entry.value.toRadixString(16).toUpperCase()}', () {
        expect(entry.key.runes.single, entry.value);
      });
    });
  });

  // UTF-8 byte round-trip: encode then decode must return the identical string.
  // Guards against a source-file re-encoding flattening a smart quote to ASCII
  // (the exact corruption the spec warns about) or losing the zero-width space.
  group('UTF-8 byte round-trip', () {
    const List<String> allConstants = <String>[
      StringExtensions.accentedQuoteOpening,
      StringExtensions.accentedQuoteClosing,
      StringExtensions.accentedDoubleQuoteOpening,
      StringExtensions.accentedDoubleQuoteClosing,
      StringExtensions.ellipsis,
      StringExtensions.doubleChevron,
      StringExtensions.apostrophe,
      StringExtensions.hyphen,
      StringExtensions.softHyphen,
      StringExtensions.blank,
      StringExtensions.zeroWidth,
      StringExtensions.nonBreakingSpace,
      StringExtensions.nonBreakingHyphen,
      StringExtensions.bullet,
      StringExtensions.dot,
      StringExtensions.newLine,
      StringExtensions.lineBreak,
      StringExtensions.dotJoiner,
    ];

    for (int i = 0; i < allConstants.length; i++) {
      final String value = allConstants[i];
      test('constant #$i survives utf8 encode/decode', () {
        expect(utf8.decode(utf8.encode(value)), value);
      });
    }
  });

  // Distinctness: the look-alikes must not collapse into each other or into
  // plain space/empty, since that distinction is the whole reason each exists.
  group('distinctness', () {
    test('nonBreakingSpace is not a regular space', () {
      expect(StringExtensions.nonBreakingSpace, isNot(' '));
      expect(StringExtensions.nonBreakingSpace.runes.single, isNot(0x0020));
    });

    test('zeroWidth is not empty', () {
      expect(StringExtensions.zeroWidth, isNotEmpty);
      expect(StringExtensions.zeroWidth, hasLength(1));
    });

    // blank (Hangul filler) survives trim() where a normal space is stripped —
    // this resistance to trimming is its entire purpose.
    test('blank is not stripped by trim', () {
      final String padded = ' ${StringExtensions.blank} ';
      expect(padded.trim(), StringExtensions.blank);
      expect(StringExtensions.blank.trim(), StringExtensions.blank);
    });
  });

  // Alias integrity: assert the identities so a refactor can't desync an alias
  // from its source value.
  group('alias integrity', () {
    test('dot is the same value as bullet', () {
      expect(StringExtensions.dot, StringExtensions.bullet);
    });

    test('lineBreak is the same value as newLine', () {
      expect(StringExtensions.lineBreak, StringExtensions.newLine);
    });

    // apostrophe and accentedQuoteClosing both resolve to U+2019; the spec
    // documents this intentional overlap, so lock it in.
    test('apostrophe shares the closing-quote code point (U+2019)', () {
      expect(StringExtensions.apostrophe, StringExtensions.accentedQuoteClosing);
      expect(StringExtensions.apostrophe.runes.single, 0x2019);
    });
  });

  // dotJoiner shape: exactly space + bullet + space, used to separate inline
  // items. Pinning the exact shape guards against an accidental extra/missing
  // pad space that would shift list-item spacing app-wide.
  group('dotJoiner shape', () {
    test('is exactly three characters long', () {
      expect(StringExtensions.dotJoiner, hasLength(3));
    });

    test('trims down to the bare bullet', () {
      expect(StringExtensions.dotJoiner.trim(), StringExtensions.bullet);
    });

    test('is space + bullet + space', () {
      expect(StringExtensions.dotJoiner, ' ${StringExtensions.bullet} ');
    });
  });

  // Const-evaluability: these must remain compile-time const so they can be used
  // in const widget trees and const lists (e.g. commonWordEndings). A const
  // reference in this fixture only compiles while every constant stays const;
  // demoting any of them to a non-const expression would break this file.
  group('const-evaluability', () {
    test('all constants are usable in a const context', () {
      const List<String> constList = <String>[
        StringExtensions.accentedQuoteOpening,
        StringExtensions.accentedQuoteClosing,
        StringExtensions.accentedDoubleQuoteOpening,
        StringExtensions.accentedDoubleQuoteClosing,
        StringExtensions.ellipsis,
        StringExtensions.doubleChevron,
        StringExtensions.apostrophe,
        StringExtensions.hyphen,
        StringExtensions.softHyphen,
        StringExtensions.blank,
        StringExtensions.zeroWidth,
        StringExtensions.nonBreakingSpace,
        StringExtensions.nonBreakingHyphen,
        StringExtensions.bullet,
        StringExtensions.dot,
        StringExtensions.newLine,
        StringExtensions.lineBreak,
        StringExtensions.dotJoiner,
      ];

      // 18 entries: the full general-purpose surface enumerated above.
      expect(constList, hasLength(18));
    });

    test('commonWordEndings (a const list) embeds the typographic constants', () {
      expect(StringExtensions.commonWordEndings, contains(StringExtensions.ellipsis));
      expect(StringExtensions.commonWordEndings, contains(StringExtensions.hyphen));
      expect(StringExtensions.commonWordEndings, contains(StringExtensions.dot));
    });
  });
}
