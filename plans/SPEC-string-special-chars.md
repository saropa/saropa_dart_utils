# SPEC: SpecialChar constants — for inclusion

**Status:** Proposed (from Saropa Contacts) — **ALREADY IN LIBRARY (no action needed)**
**Proposed location:** `lib/string/string_extensions.dart` (already present as `StringExtensions` static consts)
**Portability:** pure Dart (no Flutter, no external packages).

## Purpose — what it does + why it is general-purpose (not proprietary)

`SpecialChar` in Saropa Contacts (`lib/utils/primitive/string/special_chars.dart`)
is a named registry of typographic / whitespace / punctuation Unicode constants —
smart quotes, non-breaking space and hyphen, soft hyphen, zero-width space,
ellipsis, bullet/dot, double chevron, line break. These are language-agnostic
text-presentation primitives with no contact-domain, no Saropa format, and no
app coupling.

**Key finding: the entire general-purpose surface is already in the installed
library.** The app's `SpecialChar` class is, as of the migration to
`saropa_dart_utils`, nothing but a thin re-export wrapper: every general member is
declared as `= StringExtensions.<member>`. The class delegates, it does not define.

## Overlap analysis (installed library 1.4.1)

Every general-purpose `SpecialChar` member maps 1:1 to an existing
`StringExtensions` static const in
`D:/tools/Pub/Cache/hosted/pub.dev/saropa_dart_utils-1.4.1/lib/string/string_extensions.dart`:

| `SpecialChar` member            | Library member                                  | Value (escaped)        |
|---------------------------------|-------------------------------------------------|------------------------|
| `AccentedQuoteOpening`          | `StringExtensions.accentedQuoteOpening`         | `‘`               |
| `AccentedQuoteClosing`          | `StringExtensions.accentedQuoteClosing`         | `’`               |
| `AccentedDoubleQuoteOpening`    | `StringExtensions.accentedDoubleQuoteOpening`   | `“`               |
| `AccentedDoubleQuoteClosing`    | `StringExtensions.accentedDoubleQuoteClosing`   | `”`               |
| `NonBreakingSpace`              | `StringExtensions.nonBreakingSpace`             | ` `               |
| `NonBreakingHyphen`             | `StringExtensions.nonBreakingHyphen`            | `‑`               |
| `Hyphen`                        | `StringExtensions.hyphen`                       | `‐`               |
| `SoftHyphen`                    | `StringExtensions.softHyphen`                   | `­`               |
| `NewLine`                       | `StringExtensions.newLine`                      | `\n`                   |
| `LineBreak`                     | `StringExtensions.lineBreak`                    | `\n` (alias)           |
| `Apostrophe`                    | `StringExtensions.apostrophe`                   | `’`               |
| `DoubleChevron`                 | `StringExtensions.doubleChevron`                | `»`               |
| `Blank`                         | `StringExtensions.blank`                        | `ㅤ` (Hangul filler) |
| `ZeroWidthSpace`                | `StringExtensions.zeroWidth`                    | `​`               |
| `Ellipsis`                      | `StringExtensions.ellipsis`                     | `…`               |
| `Bullet`                        | `StringExtensions.bullet`                       | `•`               |
| `Dot`                           | `StringExtensions.dot` (alias of `bullet`)      | `•`               |
| `DotJoiner`                     | `StringExtensions.dotJoiner`                    | `" • "`           |

Result: **already-in-library** for 18/20 members. No duplicate const should be
proposed.

### Excluded members (app/branding-specific — NOT proposed)

These two are the only members `SpecialChar` defines locally rather than
delegating; both are excluded because they are app/branding emoji, not
general-purpose typographic primitives:

| Excluded member    | Value                          | Why excluded |
|--------------------|--------------------------------|--------------|
| `MapMarker`        | `String.fromCharCode(0x1F4CC)` (PUSHPIN) | App UI glyph chosen for a specific surface (map markers); a library const for one of many interchangeable pin/flag emoji is editorial, not utility. |
| `AnalyticsSymbol`  | `String.fromCharCode(0x1F4E1)` (SATELLITE ANTENNA) | App-internal analytics/diagnostics branding glyph; no general-purpose meaning. |

## Source (from Saropa Contacts) — general-purpose members, verbatim

The app file delegates entirely; there is no original general-purpose source to
contribute — it is already the library's code re-exported. For reference, the
equivalent canonical definitions (the library's actual source, debug logging not
present — none in this file) are:

```dart
extension StringExtensions on String {
  static const String accentedQuoteOpening = '‘';
  static const String accentedQuoteClosing = '’';
  static const String accentedDoubleQuoteOpening = '“';
  static const String accentedDoubleQuoteClosing = '”';
  static const String ellipsis = '…';
  static const String doubleChevron = '»';
  static const String apostrophe = '’';
  static const String hyphen = '‐';
  static const String softHyphen = '­';
  static const String newLine = '\n';
  static const String lineBreak = newLine;
  static const String blank = 'ㅤ';
  static const String zeroWidth = '​';
  static const String nonBreakingSpace = ' ';
  static const String nonBreakingHyphen = '‑';
  static const String bullet = '•';
  static const String dot = bullet;
  static const String dotJoiner = ' $bullet ';
}
```

## Test cases — existing tests

No `*_test.dart` for `SpecialChar` exists under `d:/src/contacts/test`
(searched `*special_char*` and `SpecialChar` references — the only match is an
unrelated `user_models_test.dart`). The library already owns these constants, so
test ownership belongs to the library, not the app.

If the library wants to lock these values against accidental edits (they are
load-bearing for UI layout — a wrong code point silently changes wrapping
behavior), a value-assertion guard test is cheap insurance:

```dart
import 'package:saropa_dart_utils/string/string_extensions.dart';
import 'package:test/test.dart';

void main() {
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
}
```

## Bulletproofing gaps — concrete edge cases for massive coverage

These constants are single (or near-single) code points, so "bulletproofing" is
identity / encoding stability rather than algorithmic edge cases:

- **Single-rune guarantee:** assert each char (except `lineBreak`/`dotJoiner`)
  is exactly one rune — `value.runes.length == 1` — so a future edit can't
  accidentally introduce a two-character sequence (e.g. CRLF for `newLine`).
- **Exact code point per constant** (table above) — catches a silent glyph swap
  that looks identical in an editor (e.g. ASCII hyphen `-` U+002D vs Unicode
  hyphen U+2010 vs non-breaking hyphen U+2011 — all render nearly the same but
  break differently).
- **UTF-8 byte round-trip:** `utf8.decode(utf8.encode(value)) == value` for each,
  guarding against source-file re-encoding flattening a smart quote to ASCII
  (the exact corruption this spec warns about) or losing the zero-width space.
- **Distinctness:** `nonBreakingSpace` (U+00A0) ≠ regular space (U+0020);
  `zeroWidth` (U+200B) is not empty and `.isNotEmpty` is true; `blank` (U+3164)
  is not whitespace under `trim()` (assert `' ${StringExtensions.blank} '.trim()`
  retains the filler) — this is its whole purpose.
- **Alias integrity:** `dot == bullet`, `lineBreak == newLine`,
  `apostrophe == accentedQuoteClosing` (both U+2019) — assert the identities so a
  refactor can't desync an alias from its source.
- **`dotJoiner` shape:** exactly space + bullet + space; assert
  `dotJoiner.length == 3` and `dotJoiner.trim() == bullet`.
- **Const-evaluability:** these must remain `const` (used in `const` widget trees
  / `const` lists like `commonWordEndings`); a compile-time `const x = ...;`
  reference in the test fixture proves it.
- **Emoji exclusions** (if ever added): `MapMarker`/`AnalyticsSymbol` would be
  surrogate-pair (2-rune as UTF-16, 1-rune as runes) — `\u{1F4CC}` /
  `\u{1F4E1}`; assert `.runes.length == 1` but `.length == 2` to document the
  surrogate-pair behavior. Not proposed for inclusion.
