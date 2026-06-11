// The enum values intentionally use PascalCase (`Red`, `DeepPurple`, `BlueGrey`)
// to mirror the names of Flutter's Material swatch classes (`Colors.red`,
// `Colors.deepPurple`, `Colors.blueGrey`) one-for-one, so callers reading both
// APIs side by side never have to mentally re-case. Lowercasing here would break
// that visual correspondence and any data previously persisted by `.name`.
// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

/// A named palette of the Material "700-ish" dark color swatches.
///
/// Each value names one swatch in the standard Material design palette; the
/// concrete `Color` for every value lives in [DarkColorsUtils.darkColorMap].
/// These are the dark end of each Material hue, useful anywhere a caller needs a
/// deterministic, named color: category tagging, avatar backgrounds, chart
/// series, label coloring. Most read legibly on a light background, but the
/// brightest Material 700 swatches (Yellow, Amber, Lime) measure below the WCAG
/// 3.0 UI-contrast bar against white — they are faithful to the named Material
/// palette, not guaranteed legible on white. The palette is brand-agnostic (no
/// Saropa branding) and carries no domain logic.
///
/// The enum order is part of the contract: values are persisted-by-index in some
/// callers, so [Red] MUST stay at index `0` and [Black] at index `19`. Reordering
/// would silently remap any data stored by `index`.
///
/// Example:
/// ```dart
/// final Color tag = DarkColorsUtils.darkColorMap[DarkColors.Teal]!; // 0xFF00796B
/// ```
enum DarkColors {
  /// Material Red 700 — `0xFFD32F2F`. First value; index `0` is contractual.
  Red,

  /// Material Pink 700 — `0xFFC2185B`.
  Pink,

  /// Material Purple 700 — `0xFF7B1FA2`.
  Purple,

  /// Material Deep Purple 700 — `0xFF512DA8`.
  DeepPurple,

  /// Material Indigo 700 — `0xFF303F9F`.
  Indigo,

  /// Material Blue 700 — `0xFF1976D2`.
  Blue,

  /// Material Light Blue 700 — `0xFF0288D1`.
  LightBlue,

  /// Material Cyan 700 — `0xFF0097A7`.
  Cyan,

  /// Material Teal 700 — `0xFF00796B`.
  Teal,

  /// Material Green 700 — `0xFF388E3C`.
  Green,

  /// Material Light Green 700 — `0xFF689F38`.
  LightGreen,

  /// Material Lime 700 — `0xFFAFB42B`. One of the brightest entries.
  Lime,

  /// Material Yellow 700 — `0xFFFBC02D`. The brightest entry — closest to the
  /// contrast floor against white.
  Yellow,

  /// Material Amber 700 — `0xFFFFA000`. Among the brightest entries.
  Amber,

  /// Material Orange 700 — `0xFFF57C00`.
  Orange,

  /// Material Deep Orange 700 — `0xFFE64A19`.
  DeepOrange,

  /// Material Brown 700 — `0xFF5D4037`.
  Brown,

  /// Material Grey 700 — `0xFF616161`.
  Grey,

  /// Material Blue Grey 700 — `0xFF455A64`.
  BlueGrey,

  /// Material "Black" anchor — `0xFF212121`. Last value; index `19` is
  /// contractual.
  Black,
}

/// Static lookup from [DarkColors] to its fixed Material 700 swatch `Color`.
///
/// This is a data table, not math — it complements the color math already in
/// `lib/niche/color_utils.dart` (`hexToRgb`, `contrastRatio`, …) by supplying a
/// ready-made set of legible-on-light constants rather than computing colors.
/// Kept in its own file because it pulls in `package:flutter/material.dart` for
/// `Color`, and the sibling `color_utils.dart` is pure Dart that must stay free
/// of any Flutter dependency.
abstract final class DarkColorsUtils {
  /// Maps every [DarkColors] value to its fully opaque Material 700 `Color`.
  ///
  /// The map is compile-time `const`: every entry is a `const Color`, every key
  /// is an enum value, so there is no runtime construction cost and the table can
  /// be inlined by the compiler. Every color has alpha `0xFF` (fully opaque), so
  /// callers can use any entry as a background without surprise transparency, and
  /// all 20 ARGB values are distinct.
  ///
  /// Lookups are total: there is exactly one entry for every [DarkColors] value
  /// and no stray keys, so `darkColorMap[c]` is non-null for any `c` in
  /// `DarkColors.values`. The bang in the example below is therefore safe.
  ///
  /// Example:
  /// ```dart
  /// final Color red = DarkColorsUtils.darkColorMap[DarkColors.Red]!; // 0xFFD32F2F
  /// ```
  static const Map<DarkColors, Color> darkColorMap = <DarkColors, Color>{
    DarkColors.Red: Color(0xFFD32F2F),
    DarkColors.Pink: Color(0xFFC2185B),
    DarkColors.Purple: Color(0xFF7B1FA2),
    DarkColors.DeepPurple: Color(0xFF512DA8),
    DarkColors.Indigo: Color(0xFF303F9F),
    DarkColors.Blue: Color(0xFF1976D2),
    DarkColors.LightBlue: Color(0xFF0288D1),
    DarkColors.Cyan: Color(0xFF0097A7),
    DarkColors.Teal: Color(0xFF00796B),
    DarkColors.Green: Color(0xFF388E3C),
    DarkColors.LightGreen: Color(0xFF689F38),
    DarkColors.Lime: Color(0xFFAFB42B),
    DarkColors.Yellow: Color(0xFFFBC02D),
    DarkColors.Amber: Color(0xFFFFA000),
    DarkColors.Orange: Color(0xFFF57C00),
    DarkColors.DeepOrange: Color(0xFFE64A19),
    DarkColors.Brown: Color(0xFF5D4037),
    DarkColors.Grey: Color(0xFF616161),
    DarkColors.BlueGrey: Color(0xFF455A64),
    DarkColors.Black: Color(0xFF212121),
  };
}
