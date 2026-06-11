# SPEC: TextDirectionUtils.tryParse — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/string/text_direction_parse_utils.dart
**Portability:** NOT pure Dart. The return type `TextDirection` comes from
Flutter's `dart:ui` (re-exported by `package:flutter/material.dart`). The
saropa_dart_utils package is pure Dart (no Flutter dependency anywhere in
`lib/`), so including this AS-IS would pull Flutter into the dependency tree —
a portability regression for the whole package.

**Recommended resolution before inclusion:** do NOT add a Flutter-typed
helper. Either (a) ship a pure-Dart enum variant that returns a package-local
`enum TextWritingDirection { ltr, rtl }` (no Flutter import), leaving the
caller to map to Flutter's `TextDirection`; or (b) leave this util in the app
because it is a one-line trivial wrapper over a Flutter type and not worth a
Flutter-dependency in a pure-Dart utility package. This spec documents the
logic either way; the inclusion decision is (a) or (b), not "copy as-is".

## Purpose — what it does + why it is general-purpose (not proprietary)

`tryParse` maps a case-insensitive, whitespace-trimmed string token to a
text-direction value:

- `"ltr"` (any case, surrounding whitespace) → left-to-right
- `"rtl"` (any case, surrounding whitespace) → right-to-left
- anything else, including `null`, empty, and unknown tokens → `null`

It is a standard "parse a short enum token from config / JSON / locale data"
helper. There is nothing contact-domain, Saropa-format, or app-specific about
it — `"ltr"` / `"rtl"` are the universal CSS/HTML/Unicode direction tokens.
General-purpose: parsing a persisted or transmitted direction string back into
a typed value.

### Excluded members + why

The source file contains exactly one public member (`tryParse`) and no private
members; nothing was excluded as proprietary. The ONLY portability concern is
the Flutter `TextDirection` return type (see Portability above) — that is a
dependency concern, not an app-specific-logic exclusion. There is no debug /
DebugType / Crashlytics / l10n / Font Awesome / search-query code in this file
to strip.

## Source (from Saropa Contacts) — verbatim (debug logging stripped)

The original returns Flutter's `TextDirection`:

```dart
import 'package:flutter/material.dart'; // for TextDirection (dart:ui)

abstract final class TextDirectionUtils {
  /// Finds the TextDirection enum value from a string.
  ///
  /// Case-insensitive and whitespace-trimmed. Returns null for null,
  /// empty, or any unrecognized token.
  static TextDirection? tryParse(String? value) =>
      switch (value?.toLowerCase().trim()) {
        'rtl' => TextDirection.rtl,
        'ltr' => TextDirection.ltr,
        _ => null,
      };
}
```

### Pure-Dart variant (recommended shape for this package)

If included in saropa_dart_utils, ship the pure-Dart form (no Flutter import)
so the package stays Flutter-free:

```dart
/// Writing direction parsed from a short token, with no Flutter dependency.
///
/// Mirrors the CSS/HTML/Unicode `ltr` / `rtl` direction tokens. The caller
/// maps to Flutter's `TextDirection` at the UI boundary if needed.
enum TextWritingDirection { ltr, rtl }

abstract final class TextDirectionParseUtils {
  /// Parses `"ltr"` / `"rtl"` (case-insensitive, whitespace-trimmed) into a
  /// [TextWritingDirection].
  ///
  /// Returns null for null, empty, whitespace-only, or any unrecognized
  /// token — never throws.
  static TextWritingDirection? tryParse(String? value) =>
      switch (value?.toLowerCase().trim()) {
        'rtl' => TextWritingDirection.rtl,
        'ltr' => TextWritingDirection.ltr,
        _ => null,
      };
}
```

## Test cases

No existing test file was found in Saropa Contacts (no `test/**/*text_direction*`
and no `group('TextDirectionUtils')`). Proposed cases below for massive
coverage. Examples use the pure-Dart `TextWritingDirection` variant; substitute
`TextDirection.ltr/.rtl` if the Flutter-typed form is chosen.

```dart
import 'package:flutter_test/flutter_test.dart';
// import the util under test

void main() {
  group('TextDirectionParseUtils.tryParse', () {
    test('exact lowercase ltr', () {
      expect(TextDirectionParseUtils.tryParse('ltr'),
          TextWritingDirection.ltr);
    });

    test('exact lowercase rtl', () {
      expect(TextDirectionParseUtils.tryParse('rtl'),
          TextWritingDirection.rtl);
    });

    test('uppercase is accepted (case-insensitive)', () {
      expect(TextDirectionParseUtils.tryParse('LTR'),
          TextWritingDirection.ltr);
      expect(TextDirectionParseUtils.tryParse('RTL'),
          TextWritingDirection.rtl);
    });

    test('mixed case is accepted', () {
      expect(TextDirectionParseUtils.tryParse('Ltr'),
          TextWritingDirection.ltr);
      expect(TextDirectionParseUtils.tryParse('rTl'),
          TextWritingDirection.rtl);
    });

    test('surrounding whitespace is trimmed', () {
      expect(TextDirectionParseUtils.tryParse('  ltr  '),
          TextWritingDirection.ltr);
      expect(TextDirectionParseUtils.tryParse('\trtl\n'),
          TextWritingDirection.rtl);
    });

    test('null returns null', () {
      expect(TextDirectionParseUtils.tryParse(null), isNull);
    });

    test('empty string returns null', () {
      expect(TextDirectionParseUtils.tryParse(''), isNull);
    });

    test('whitespace-only returns null', () {
      expect(TextDirectionParseUtils.tryParse('   '), isNull);
    });

    test('unknown token returns null', () {
      expect(TextDirectionParseUtils.tryParse('auto'), isNull);
      expect(TextDirectionParseUtils.tryParse('left'), isNull);
      expect(TextDirectionParseUtils.tryParse('right'), isNull);
    });
  });
}
```

## Bulletproofing gaps — concrete edge cases to add for massive coverage

- **Null / empty / blank:** `null`, `''`, `'   '`, `'\t'`, `'\n'`, `'\r\n'` — all → null (covered above; keep all variants).
- **Case extremes:** `'LTR'`, `'lTr'`, `'RtL'`, plus full-uppercase/lowercase
  permutations of all 3 letters.
- **Inner whitespace is NOT trimmed:** `'l t r'`, `'r t l'`, `'rt l'` → null
  (only leading/trailing trim; verify the inner-space token is rejected).
- **Embedded / partial tokens:** `'ltrx'`, `'xltr'`, `'ltr ltr'`, `'rtlrtl'`,
  `'ltr;'` → null (no substring matching).
- **Non-breaking space as the only "whitespace":** `' ltr '` —
  document the behavior. Dart `String.trim()` DOES strip U+00A0 (and other
  Unicode whitespace), so this should → ltr. Add the test so the contract is
  pinned and a future `.trim()` change can't silently regress it.
  Also test other Unicode spaces: `' ltr '` (thin space),
  `'　rtl'` (ideographic space) — all trimmed by `String.trim()` → parsed.
- **Zero-width / formatting chars are NOT whitespace:** `'​ltr'`
  (zero-width space), `'﻿ltr'` (BOM / zero-width no-break space) → null,
  because `String.trim()` does not strip these. Pin this so the distinction is
  explicit.
- **Direction-mark confusion:** the Unicode LTR/RTL marks themselves —
  `'‎'` (LRM), `'‏'` (RLM) — are not the tokens `'ltr'`/`'rtl'`;
  passing them → null. Worth a test because the util's domain is text
  direction and a reader might expect the marks to parse.
- **Unicode / emoji input:** `'\u{1F600}'` (emoji), accented `'ĺtr'`
  (combining acute), full-width `'ｌｔｒ'` (fullwidth l-t-r) → null
  (no normalization/folding; only ASCII `ltr`/`rtl` match).
- **Numeric-string tokens:** `'0'`, `'1'`, `'-1'` → null (guards against any
  caller that historically stored direction as an int-as-string).
- **Locale-insensitive lowercasing:** confirm `toLowerCase()` has no
  locale-dependent pitfalls for these ASCII tokens — Turkish-I (`'LTR'` →
  `'ltr'`) is safe because the letters are l/t/r, but add a note/test asserting
  the result is independent of the active locale.
- **Idempotence / round-trip:** if a name-/value-based serializer is added,
  test that serialize-then-`tryParse` returns the original for both values.
- **Total function guarantee:** assert (by construction + a fuzz-style loop
  over a list of junk inputs) that `tryParse` NEVER throws for ANY string,
  including very long strings and strings full of control characters.
