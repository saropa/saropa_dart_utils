/// Locale-aware number formatting via `intl`'s CLDR data — an opt-in module
/// that pulls the `intl` dependency, mirroring `date_time_intl_display_extensions.dart`.
///
/// The rest of `lib/num/` formats numbers manually (see `num_locale_utils.dart`'s
/// `formatNumberLocale`, which inserts caller-supplied separator strings every
/// three digits with NO locale data). These extensions exist because a manual
/// separator-insertion cannot know that fr_FR groups with U+202F (a NARROW
/// no-break space), that de_DE swaps `.`/`,`, or that en_IN groups in a
/// `##,##,##0` (2-2-3) pattern. intl carries the CLDR tables that encode all of
/// that, and accepts arbitrary ICU number patterns the manual helper cannot
/// express. None of the logic is domain-specific; it operates on any `num`.
library;

import 'package:intl/intl.dart';

/// Locale-aware number formatting backed by `intl`'s CLDR number-symbol data.
///
/// This is the CLDR-accurate counterpart to the dependency-free
/// `formatNumberLocale` free function in `num_locale_utils.dart`. Use this when
/// the correct separators must come from real locale data (a BCP-47 locale
/// string) rather than hand-supplied separator characters; use
/// `formatNumberLocale` when avoiding the `intl` dependency matters more than
/// CLDR accuracy.
extension NumIntlFormatExtensions on num {
  /// Renders this number with locale-aware grouping/decimal separators.
  ///
  /// Delegates to `intl`'s `NumberFormat(format, locale).format(this)`, so the
  /// thousands group separator and decimal separator come from CLDR locale data
  /// (e.g. `1,234` en_US, `1.234` de_DE; fr_FR groups with U+202F, a NARROW
  /// no-break space — NOT the regular space or U+00A0).
  ///
  /// [format] is an ICU number pattern (default `'#,##0'` = grouped integer,
  /// no decimals). Examples: `'#,##0.00'` (two decimals), `'##,##,##0'` (Indian
  /// 2-2-3 grouping), `'#,##0;(#,##0)'` (parenthesized negatives), `'#,##0%'`
  /// (scales the receiver by 100 and appends the percent sign), `'00000'`
  /// (zero-padded). An empty `''` pattern formats with no grouping (e.g.
  /// `1234` → `'1234'`) and does NOT throw.
  ///
  /// [locale] is a BCP-47 locale string (`'en_US'`, `'de_DE'`, ...). When null,
  /// intl uses its process default locale (`Intl.defaultLocale`, itself `en_US`
  /// when unset). The original Saropa version defaulted this to the active app
  /// locale; that app-specific resolution is intentionally dropped so the util
  /// stays general-purpose.
  ///
  /// Edge cases (pinned by the test suite):
  /// - Rounding follows the pattern's decimal count, half-up: `1234.567` under
  ///   `'#,##0.00'` → `'1,234.57'`, and `2.5` under `'#,##0'` → `'3'`.
  /// - `double.infinity` → the locale infinity symbol (en `'∞'`, U+221E),
  ///   `double.negativeInfinity` → `'-∞'`, `double.nan` → the locale NaN symbol
  ///   (en `'NaN'`).
  /// - Negative zero is preserved: `-0.0` → `'-0'`.
  /// - An unknown/empty [locale] (`'xx_YY'`, `''`) throws [ArgumentError] from
  ///   intl rather than falling back.
  ///
  /// Example:
  /// ```dart
  /// 1234.formatNumber();                                  // '1,234'
  /// 1234.formatNumber(locale: 'de_DE');                   // '1.234'
  /// 1234.5.formatNumber(format: '#,##0.00');              // '1,234.50'
  /// 1234567.formatNumber(format: '##,##,##0', locale: 'en_IN'); // '12,34,567'
  /// ```
  String formatNumber({String format = '#,##0', String? locale}) =>
      NumberFormat(format, locale).format(this);
}
