# SPEC: findUnicodeClassType + UnicodeClassType (UnicodeClass) — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/string/unicode_class_utils.dart (enum + class can live in the same file, or split `UnicodeClassType` into lib/string/unicode_class_type.dart)
**Portability:** Pure Dart. One external dependency to remove: `package:quiver` (`quiver.isWhitespace`) — see Bulletproofing note. No Flutter, no intl. The two `0x....toSigned(32)` calls in the range table are vestigial (all values are well below 2^31) and should be dropped on import — the ranges are plain `int`.

## Purpose — what it does + why it is general-purpose

`findUnicodeClassType(String)` inspects the runes of a string and returns the **Unicode named block** (`UnicodeClassType`) the character falls into — `BasicLatin`, `Cyrillic`, `Arabic`, `CJKUnifiedIdeographs`, `Hiragana`, etc. The block table mirrors the .NET "Supported Named Blocks" list (the source cites the MS regex character-class docs), covering U+0000 through U+FFFF (the Basic Multilingual Plane).

This is general-purpose: it answers "what script/block is this text in?" with zero app-specific coupling — useful for language/script detection, input validation, sort-bucket selection, font fallback decisions, and choosing a transliteration path. There is nothing contact-domain, Saropa-format, or product-specific in the logic; the enum is a verbatim transcription of the public Unicode block boundaries.

Options:
- `ignoreBasicLatin` — skip the `BasicLatin` block so a Latin-prefixed string (e.g. `"ignore <arabic>"`) reports the non-Latin script instead of Latin.
- `firstCharOnly` (default `true`) — classify only the first qualifying rune; set `false` to scan until a non-ignored block matches.
- `ignoreWhitespace` (default `true`) — skip whitespace runes while scanning.

### Excluded members + why

| Member | Why excluded |
|---|---|
| `import 'package:saropa/utils/_dev/debug.dart'` + `DebugType.Primitive.isDebug` blocks + `debug(...)` / `debugException(...)` calls | App-specific logging/Crashlytics reporting. Stripped from the source below. The try/catch is retained but its `debugException` body becomes a bare `return null`. |
| `package:quiver` `isWhitespace` | External-package coupling. Replace with a pure-Dart whitespace predicate (see Bulletproofing). |
| `0x....toSigned(32)` on every range bound | Vestigial 32-bit-signed coercion; every value is ≤ 0xFFFF, so it is a no-op. Drop it for clarity. |

No proprietary / contact-domain / Font Awesome / l10n members exist in these files — the rest is fully general.

## Source (from Saropa Contacts) — general-purpose members, verbatim (debug logging + quiver stripped)

> The `UnicodeClassType` enum (130+ block names with `/// Hex range:` doc comments) moves verbatim from `lib/models/framework/unicode_class_enum.dart`. It is reproduced in abbreviated form here; import the full enum unchanged.

```dart
/// Unicode named blocks (Basic Multilingual Plane, U+0000–U+FFFF).
///
/// Mirrors the .NET "Supported Named Blocks" list.
/// REF: https://learn.microsoft.com/dotnet/standard/base-types/character-classes-in-regular-expressions#supported-named-blocks
enum UnicodeClassType {
  /// Hex range: 0000 - 007F
  BasicLatin,

  /// Hex range: 0080 - 00FF
  Latin1Supplement,

  // ... (full list of 130+ blocks, verbatim from unicode_class_enum.dart) ...

  /// Hex range: FFF0 - FFFF
  Specials,
}

/// A single Unicode named block and its inclusive code-point range.
class UnicodeClass {
  UnicodeClass(this.type, {required this.start, required this.end});

  final UnicodeClassType type;
  final int start;
  final int end;
}

/// Returns the Unicode named block ([UnicodeClassType]) that the string's
/// first qualifying rune belongs to, or null when the (trimmed) string is
/// empty or no block matches.
///
/// - [ignoreBasicLatin]: skip the BasicLatin block so a Latin-prefixed
///   string reports the non-Latin script that follows.
/// - [firstCharOnly]: classify only the first qualifying rune (default).
///   Set false to scan until a non-ignored block matches.
/// - [ignoreWhitespace]: skip whitespace runes while scanning (default true).
///
/// Calls [String.trim].
UnicodeClassType? findUnicodeClassType(
  String value, {
  bool ignoreBasicLatin = false,
  bool firstCharOnly = true,
  bool ignoreWhitespace = true,
}) {
  try {
    value = value.trim();

    if (value.isEmpty) {
      return null;
    }

    for (final int rune in value.runes) {
      // Pure-Dart whitespace check replaces quiver.isWhitespace on import.
      if (ignoreWhitespace && _isUnicodeWhitespace(rune)) {
        continue;
      }
      for (final UnicodeClass uni in _classRanges) {
        if (ignoreBasicLatin && uni.type == UnicodeClassType.BasicLatin) {
          continue;
        }
        if (uni.start <= rune && rune <= uni.end) {
          return uni.type;
        }
      }

      if (firstCharOnly) {
        break;
      }
    }

    return null;
  } on Object catch (_) {
    return null;
  }
}

final List<UnicodeClass> _classRanges = <UnicodeClass>[
  UnicodeClass(UnicodeClassType.BasicLatin, start: 0x0000, end: 0x007F),
  UnicodeClass(UnicodeClassType.Latin1Supplement, start: 0x0080, end: 0x00FF),
  UnicodeClass(UnicodeClassType.LatinExtendedA, start: 0x0100, end: 0x017F),
  // ... (full table, verbatim from unicode_class_utils.dart, with the
  //      `.toSigned(32)` coercion dropped from every bound) ...
  UnicodeClass(UnicodeClassType.Specials, start: 0xFFF0, end: 0xFFFF),
];
```

Note: the source's `_classRanges` is a `final` top-level list. It can be made a real `const`/`static const` registry on import for tree-shaking, but the value list itself is unchanged.

## Test cases — existing tests (from `test/lib/utils/primative/primative_utils_test.dart`, verbatim, with raw non-ASCII re-encoded as Dart escapes)

The original test file pastes raw CJK / Arabic literals. They are reproduced below with `String.fromCharCodes` so the spec round-trips losslessly. The original `// ingnore latin` typo in the comment is preserved.

```dart
group('String Unicode Utils', () {
  group('findUnicodeClassType', () {
    test('findUnicodeClassType - Empty', () {
      expect(findUnicodeClassType(''), isNull);
      expect(findUnicodeClassType(' '), isNull);
      expect(findUnicodeClassType('   '), isNull);
    });

    test('UnicodeClassType.BasicLatin', () {
      final UnicodeClassType? lookup1 = findUnicodeClassType('a');
      expect(lookup1, UnicodeClassType.BasicLatin);

      final UnicodeClassType? lookup2 = findUnicodeClassType('z');
      expect(lookup2, UnicodeClassType.BasicLatin);

      final UnicodeClassType? lookup3 = findUnicodeClassType('A');
      expect(lookup3, UnicodeClassType.BasicLatin);

      final UnicodeClassType? lookup4 = findUnicodeClassType('A');
      expect(lookup4, UnicodeClassType.BasicLatin);

      final UnicodeClassType? lookup5 = findUnicodeClassType('0');
      expect(lookup5, UnicodeClassType.BasicLatin);

      final UnicodeClassType? lookup6 = findUnicodeClassType('9');
      expect(lookup6, UnicodeClassType.BasicLatin);
    });

    test('UnicodeClassType.CJKUnifiedIdeographs', () {
      // '相浦由莉絵'
      const String cjk = String.fromCharCodes(<int>[
        0x76F8, 0x6D66, 0x7531, 0x83C9, 0x7D75,
      ]);
      expect(findUnicodeClassType(cjk), UnicodeClassType.CJKUnifiedIdeographs);
    });

    test('UnicodeClassType.Arabic', () {
      // 'سلامی جمہوریہ پاكِستان'
      const String arabic = String.fromCharCodes(<int>[
        0x0633, 0x0644, 0x0627, 0x0645, 0x06CC, 0x0020,
        0x062C, 0x0645, 0x06C1, 0x0648, 0x0631, 0x06CC, 0x06C1, 0x0020,
        0x067E, 0x0627, 0x0643, 0x0650, 0x0633, 0x062A, 0x0627, 0x0646,
      ]);
      expect(findUnicodeClassType(arabic), UnicodeClassType.Arabic);

      // ingnore latin
      // 'ignore اختبار'
      const String mixed = String.fromCharCodes(<int>[
        0x69, 0x67, 0x6E, 0x6F, 0x72, 0x65, 0x20,
        0x0627, 0x062E, 0x062A, 0x0628, 0x0627, 0x0631,
      ]);
      expect(
        findUnicodeClassType(mixed, ignoreBasicLatin: true, firstCharOnly: false),
        UnicodeClassType.Arabic,
      );
    });
  });
});
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**Whitespace predicate (must add before tests pass without quiver):**
- Replace `quiver.isWhitespace(rune)` with a pure-Dart `_isUnicodeWhitespace(int rune)` covering: `0x09` (tab), `0x0A` (LF), `0x0B` (VT), `0x0C` (FF), `0x0D` (CR), `0x20` (space), `0x85` (NEL), `0xA0` (no-break space ` `), `0x1680` (ogham space), `0x2000`–`0x200A` (en/em spaces), `0x2028` (line sep), `0x2029` (para sep), `0x202F` (narrow NBSP), `0x205F` (medium math space), `0x3000` (ideographic space). Add a test asserting each is skipped (`ignoreWhitespace: true`) AND classified to its block when `ignoreWhitespace: false` (e.g. ` ` → `Latin1Supplement`, ` ` → `GeneralPunctuation`, `　` → `CJKSymbolsAndPunctuation`).

**Empty / null / blank:**
- `findUnicodeClassType('')` → null (covered).
- Whitespace-only of every flavor: `'\t'`, `'\n'`, `' '`, `'　'` → null after trim/skip. Note `String.trim()` removes leading/trailing ASCII + some Unicode whitespace but NOT all (e.g. ` ` survives `trim()` in Dart) — assert the `ignoreWhitespace` path, not trim, handles those.
- Function takes a non-nullable `String`; no null input path, but add a `findUnicodeClassType(' \t \n ')` → null case.

**Boundary code points (every block's first + last rune):**
- For each block, assert `start` and `end` map to that block: e.g. ` ` and `` → `BasicLatin`; ``/`ÿ` → `Latin1Supplement`; `一`/`鿿` → `CJKUnifiedIdeographs`; `￰`/`￿` → `Specials`. A table-driven test over `_classRanges` (expose it test-only) catches any off-by-one.

**Gaps between blocks (unassigned ranges return null):**
- The table has holes — e.g. `ݐ`–`ݿ` (between Syriac end `0x074F` and Thaana start `0x0780`), `߀`–`ࣿ`, `Ⰰ`–`⹿`, `㇀`–`㇯`, `ꓐ`–`꯿`. Assert `findUnicodeClassType('ݠ')` → null (no matching block). This is the highest-value coverage gap: the function silently returns null in unassigned ranges and no existing test exercises it.

**Surrogates / astral plane (BMP-only limitation):**
- `value.runes` decodes a surrogate PAIR (e.g. emoji `\u{1F600}` = rune `0x1F600`) into ONE rune ABOVE `0xFFFF`. Since `_classRanges` tops out at `Specials` (`0xFFFF`), an emoji rune `0x1F600` matches NO block → null. Add `findUnicodeClassType('\u{1F600}')` → null and DOCUMENT this BMP-only limit (the `HighSurrogates`/`LowSurrogates`/`HighPrivateUseSurrogates` enum entries are decorative — `runes` never yields a lone surrogate from valid Dart strings, so those three blocks are effectively unreachable via this API; assert that too).

**firstCharOnly semantics:**
- `firstCharOnly: true` (default) with leading whitespace skipped, then first real rune wins: `'  一abc'` → `CJKUnifiedIdeographs`.
- `firstCharOnly: false` scanning a mixed string returns the FIRST rune that matches any non-ignored block — assert it does NOT keep scanning past the first match (e.g. `'a一'` with `firstCharOnly: false`, `ignoreBasicLatin: false` → `BasicLatin`, because `a` matches first).

**ignoreBasicLatin interactions:**
- `'abc'` with `ignoreBasicLatin: true`, `firstCharOnly: true` → null (only Latin present, first rune skipped, loop breaks). Confirm the break-on-firstChar still applies when the only block is the ignored one.
- `'aЀ'` with `ignoreBasicLatin: true`, `firstCharOnly: false` → `Cyrillic` (Latin skipped, scan continues).
- `'aЀ'` with `ignoreBasicLatin: true`, `firstCharOnly: true` → null (first rune `a` is BasicLatin → skipped in inner loop but `firstCharOnly` breaks the outer loop, so Cyrillic is never reached). Assert this subtle interaction explicitly — it is non-obvious and a likely behavior-change trap on refactor.

**Combining marks / diacritics:**
- A base letter + combining mark `'é'` (e + combining acute) → first rune `e` is `BasicLatin`; assert. With `ignoreBasicLatin: true, firstCharOnly: false` → `CombiningDiacriticalMarks` (`́` ∈ `0x0300`–`0x036F`).

**Specific scripts (extend the existing two):**
- Cyrillic `А` → `Cyrillic`; Hebrew `א` → `Hebrew`; Greek `Α` → `GreekOrGreekCoptic`; Hiragana `あ` → `Hiragana`; Katakana `ア` → `Katakana`; Hangul syllable `가` → `HangulSyllables`; Thai `ก` → `Thai`; Devanagari `अ` → `Devanagari`; currency `€` (euro) → `CurrencySymbols`; arrow `→` → `Arrows`.

**Determinism / table integrity (meta-tests):**
- Assert `_classRanges` is sorted ascending and non-overlapping (every `start[i] > end[i-1]`), and every `UnicodeClassType` enum value appears exactly once in the table (catch a future enum addition that forgets a range entry). These guard against the registry drifting from the enum.
