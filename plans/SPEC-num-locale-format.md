# SPEC: NumberFormatExtensions.formatNumber — for inclusion

**Status:** Proposed (from Saropa Contacts)
**Proposed location:** lib/num/num_intl_format_extensions.dart
**Portability:** Pure Dart, but requires the external `intl` package (`package:intl/intl.dart`, `NumberFormat`). No Flutter dependency. The library does NOT currently depend on `intl` — adding this util introduces that dependency. See "Bulletproofing gaps / dependency note" below.

## Purpose — what it does + why it is general-purpose (not proprietary)

`formatNumber` is a `num` extension that renders any number using a locale-aware, ICU-pattern formatter. It delegates to `intl`'s `NumberFormat(format, locale).format(this)`, so it gets real CLDR locale data: the correct thousands group separator and decimal separator per locale (e.g. `1,234` in en_US, `1.234` in de_DE, `1 234` — digit + non-breaking space + digits — in fr_FR), plus arbitrary ICU number patterns via the `format` string (default `'#,##0'`; e.g. `'#,##0.00'` for two decimals).

This is general-purpose number formatting. Nothing about it is contact-domain, brand, or app-specific — it is the kind of "format an int with the right grouping for the user's locale" helper any app needs.

### Overlap with the installed library (IMPORTANT — partial overlap, not duplicate)

`saropa_dart_utils-1.4.1` already ships **`formatNumberLocale`** in `lib/num/num_locale_utils.dart`. That is a top-level function (not a `num` extension) with a **manual, separator-string implementation**: caller passes literal `groupSep` / `decimalSep` strings and the function inserts a separator every 3 digits. It has **no CLDR locale data** — its own docstring says "Simple implementation: no full locale data; configurable separators."

This proposed util is **net-new capability, not a duplicate**, because:

- It is driven by a **BCP-47 locale string** (`'de_DE'`, `'fr_FR'`), not by hand-supplied separators. The correct separators come from intl's CLDR tables, so the caller does not need to know that fr_FR groups with U+00A0 or that de_DE swaps `.`/`,`.
- It accepts an **arbitrary ICU `format` pattern** (`'#,##0.00'`, `'#,##0'`, etc.), covering decimal places, currency-style padding, and non-3-digit grouping (e.g. Indian `'##,##,##0'`) that the manual implementation cannot express.
- It is a **`num` extension** (`1234.formatNumber()`), a different ergonomic surface from the existing free function `formatNumberLocale(1234)`.

Recommendation: ADD as a separate extension (suggested name `NumIntlFormatExtensions.formatNumber`, distinct from the existing `NumFormatExtensions` in `num_format_extensions.dart`), and cross-reference `formatNumberLocale` in its doc as the dependency-free (but locale-data-free) alternative. Keep both; they trade off the `intl` dependency against CLDR accuracy.

### Excluded members + why

| Excluded | Why |
|---|---|
| `LocaleUtils.getLocaleStringFromContext()` fallback in the `locale ?? ...` default | App-specific: resolves the active **app** locale from Saropa's `BuildContext`/locale plumbing. Not portable. In the library, default `locale` to `null` and let intl fall back to its own default locale (or require the caller to pass one). |
| The `// alt = '#,##0.00'` and StackOverflow `// ref:` comments | App scratch notes; replace with proper dartdoc in the library. |

No debug()/DebugType logging exists in this source, so none was stripped.

## Source (from Saropa Contacts) — verbatim general-purpose member (app-locale fallback removed)

The Saropa source (`lib/utils/primitive/number/num_extensions_local.dart`) is one extension. Reproduced below with the app-specific `LocaleUtils.getLocaleStringFromContext()` default removed (the only non-portable element):

```dart
import 'package:intl/intl.dart';

extension NumberFormatExtensions on num {
  /// Locale-aware thousands grouping (e.g. "1,234" en_US, "1.234" de_DE,
  /// "1 234" fr_FR — fr_FR uses a non-breaking space U+00A0 as the group
  /// separator). [format] is an ICU number pattern (default '#,##0' = grouped
  /// integer, no decimals; e.g. '#,##0.00' for two decimal places).
  ///
  /// [locale] is a BCP-47 locale string ('en_US', 'de_DE', ...). When null,
  /// intl uses its default locale. The original Saropa version defaulted this
  /// to the active app locale; that app-specific resolution is intentionally
  /// dropped here so the util stays pure/general-purpose.
  String formatNumber({String format = '#,##0', String? locale}) =>
      NumberFormat(format, locale).format(this);
}
```

> Note for the library port: intl's `NumberFormat` does NOT auto-initialize non-default locale data the way `intl_standalone` / message lookup does, but number-symbol data for built-in locales is bundled, so `NumberFormat('#,##0', 'de_DE')` works without an explicit `initializeNumberFormatting` call. Verify this in the bulletproofing tests below (fr_FR U+00A0 separator is the canary).

## Test cases — existing tests (Saropa), verbatim

From `d:/src/contacts/test/lib/utils/primitive/number/num_extensions_local_test.dart`. These pin the locale-aware contract. Library port should drop the import path / app-fallback comments and adapt the default-locale test to the library's chosen default behavior (no app context).

```dart
group('NumberFormatExtensions.formatNumber', () {
  test('default locale falls back to en_US grouping (no context)', () {
    expect(1234.formatNumber(), equals('1,234'));
    expect(1234567.formatNumber(), equals('1,234,567'));
  });

  test('explicit en_US locale matches default in test env', () {
    expect(1234.formatNumber(locale: 'en_US'), equals('1,234'));
  });

  test('explicit de_DE locale uses dot grouping', () {
    // Pins that the locale parameter is actually honored. de_DE must produce
    // "1.234", not "1,234".
    expect(1234.formatNumber(locale: 'de_DE'), equals('1.234'));
  });

  test('zero and small numbers do not get separators', () {
    expect(0.formatNumber(), equals('0'));
    expect(42.formatNumber(), equals('42'));
    expect(999.formatNumber(), equals('999'));
  });

  test('explicit format pattern overrides default grouping pattern', () {
    // Default '#,##0' caps at zero decimals; '#,##0.00' adds two.
    expect(1234.5.formatNumber(format: '#,##0.00', locale: 'en_US'), equals('1,234.50'));
  });
});
```

> The existing default-locale test assumes the Saropa fallback chain reaches en_US. In the library (no app context), `formatNumber()` with `locale: null` uses intl's process default locale — assert against `'en_US'` only after pinning the default via `Intl.defaultLocale = 'en_US'` in `setUp`, OR change the assertion to always pass `locale: 'en_US'` explicitly.

## Bulletproofing gaps — concrete edge cases to add for massive coverage

**Dependency note (decide before merge):** adding `intl` to `saropa_dart_utils` is a new runtime dependency for ALL consumers. If that is unacceptable, do NOT port this; instead extend the existing dependency-free `formatNumberLocale` with a small locale→separator lookup. The whole value of THIS util is the CLDR data, which only `intl` provides.

Locale / separator:
- fr_FR group separator is **non-breaking space U+00A0**, not a regular space — assert exactly: `expect(1234.formatNumber(locale: 'fr_FR'), equals('1 234'))` (and 1234567 → `'1 234 567'`). A test that pastes a literal space will pass wrongly; use the ` ` escape.
- de_DE / es_ES dot grouping vs en_US comma grouping (`1.234.567` vs `1,234,567`).
- de_DE decimal separator is comma: `1234.5.formatNumber(format: '#,##0.00', locale: 'de_DE')` → `'1.234,50'`.
- Indian grouping pattern: `1234567.formatNumber(format: '##,##,##0', locale: 'en_IN')` → `'12,34,567'` (non-3-digit grouping the manual `formatNumberLocale` cannot do).
- Arabic locale (`ar`) — confirm whether intl emits Western digits or Eastern-Arabic-Indic digits (e.g. U+0660–U+0669); pin whichever it actually returns with explicit `String.fromCharCode` escapes, never raw glyphs.
- Unknown/garbage locale string (`'xx_YY'`, `''`) — document whether intl throws or falls back, and pin that behavior.

Numeric edge cases:
- Zero: `0` → `'0'`; `0.0` with `'#,##0.00'` → `'0.00'`.
- Negative: `-1234` → `'-1,234'`; sign placement under `'#,##0.00'` and under a parenthesized-negative pattern `'#,##0;(#,##0)'` → `'(1,234)'`.
- Negative zero: `(-0.0)` — pin whether output is `'0'` or `'-0'`.
- Boundary at first grouping: `999` → `'999'`, `1000` → `'1,000'`, `99999` → `'99,999'`.
- Rounding from the pattern: `1234.567.formatNumber(format: '#,##0.00')` → `'1,234.57'` (half-up); `1234.565` and `2.5` to confirm intl's rounding mode (banker's vs half-up).
- `int` vs `double` receiver: `1234` (int) and `1234.0` (double) both → `'1,234'` under default pattern.

Extremes:
- `double.maxFinite` and a very large int (e.g. `9223372036854775807`) — confirm no overflow/exponent leakage under a grouped pattern.
- Very small fraction `0.0001` with `'#,##0.0000'`.
- `double.infinity` / `double.negativeInfinity` — intl renders these as the locale's infinity symbol (en `'∞'` = U+221E). Pin with `expect(double.infinity.formatNumber(), equals(String.fromCharCode(0x221E)))` — never paste the raw glyph.
- `double.nan` — intl renders the locale NaN symbol (en `'NaN'`); pin exact string per locale.

Pattern robustness:
- Empty `format` string `''` — document/pin behavior (intl may format with default decimal pattern or throw).
- Pattern with explicit literal text or padding (`'00000'`, `'#,##0 kg'`).
- Percent/per-mille patterns (`'#,##0%'` → value × 100 + `%`) to document that the receiver is scaled.

Determinism:
- Reset `Intl.defaultLocale` in `setUp`/`tearDown` so a default-locale test does not leak state into a later test (intl's default locale is process-global).
```
