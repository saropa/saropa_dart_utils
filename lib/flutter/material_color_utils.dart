import 'package:flutter/material.dart';

// MaterialShade lives in lib/color/material_shade.dart (shared shade-ladder
// model); reuse it rather than redefining the enum here.
import 'package:saropa_dart_utils/color/material_shade.dart';

/// General-purpose Material Design palette helpers with no app-domain knowledge.
///
/// Bundles three independent pieces of swatch plumbing:
///
/// - [materialColors] — the canonical ordered list of the 19 primary Flutter
///   `MaterialColor`s, for indexing a fixed palette (charts, avatars, tag colors,
///   deterministic per-index color assignment).
/// - [getWhiteContrastColor] — a deterministic `int → Color` generator whose
///   results are biased to contrast against white.
/// - [getColor] — a typed swatch accessor that replaces `color[500]!` with an
///   exhaustive [MaterialShade] switch.
///
/// Example:
/// ```dart
/// ColorUtils.materialColors[3];                       // Colors.deepPurple
/// ColorUtils.getColor(MaterialShade.shade700, Colors.blue);
/// ColorUtils.getWhiteContrastColor(42);
/// ```
abstract final class ColorUtils {
  /// The 19 primary Flutter `MaterialColor` swatches in their canonical order.
  ///
  /// A `List` (not a `Set`) is intentional: callers index into it by position to
  /// assign a stable color per integer, so order and indexability matter. The
  /// list runs `Colors.red` … `Colors.blueGrey` and contains no duplicates. As a
  /// `const` list it is unmodifiable — a `.add`/`.clear` throws
  /// `UnsupportedError`, which protects the shared palette from accidental
  /// mutation by callers.
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.materialColors.length;  // 19
  /// ColorUtils.materialColors.first;   // Colors.red
  /// ```
  static const List<MaterialColor> materialColors = <MaterialColor>[
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  /// The fixed 10-color palette blended by [getWhiteContrastColor].
  ///
  /// Hoisted to a `static const` so the two index reads in
  /// [getWhiteContrastColor] share one source of truth — a palette reorder
  /// changes exactly one place, and the indices `0`–`9` are validated against
  /// this single length.
  static const List<Color> _contrastPalette = <Color>[
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
    Colors.cyan,
    Colors.lime,
  ];

  /// Maps any [number] deterministically to one of 100 fully-opaque colors that
  /// are biased to contrast against white.
  ///
  /// Accepts ANY `int` — including negatives and values past 99. The input is
  /// normalized into `0`–`99` first, then split into a primary index
  /// (`tens digit`) and secondary index (`ones digit`) into a fixed 10-color
  /// palette; the two are alpha-blended (secondary at 50% over the opaque
  /// primary), which keeps the result fully opaque (`alpha == 1.0`).
  ///
  /// Edge cases:
  /// - Negatives: `getWhiteContrastColor(-1)` equals `getWhiteContrastColor(99)`.
  /// - Wrap: `getWhiteContrastColor(142)` equals `getWhiteContrastColor(42)`.
  /// - `0` → red blended onto red.
  /// - `int` extremes never throw: normalization keeps both indices in `0`–`9`.
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.getWhiteContrastColor(42);  // stable for the same input
  /// ```
  static Color getWhiteContrastColor(int number) {
    // ((n % 100) + 100) % 100 forces a non-negative 0..99 result on every
    // platform. A bare `n % 100` is already non-negative on the Dart VM, but on
    // web (int is a JS double) huge values can land negative; this form makes the
    // 0..9 index invariant explicit and platform-independent, ruling out RangeError.
    final int index = ((number % 100) + 100) % 100;

    // Tens digit selects the base color, ones digit the overlay; both are 0..9,
    // guaranteed in range against the 10-entry palette by the normalization above.
    final int primaryIndex = index ~/ 10;
    final int secondaryIndex = index % 10;

    final Color primaryColor = _contrastPalette[primaryIndex];
    final Color secondaryColor = _contrastPalette[secondaryIndex];

    // alphaBlend over a fully opaque base yields a fully opaque result, so the
    // generated color is always alpha 1.0 (asserted by tests).
    return Color.alphaBlend(
      secondaryColor.withValues(alpha: 0.5),
      primaryColor,
    );
  }

  /// Returns the swatch tone for [shade] from the `MaterialColor` [color].
  ///
  /// A typed replacement for the stringly/int-indexed `color[500]!`: the
  /// exhaustive [MaterialShade] switch guarantees every level is handled at
  /// compile time. The `!` is safe for the standard Material swatches in
  /// [materialColors], which define all ten levels; a custom `MaterialColor`
  /// missing a level would throw, so do not pass partial swatches here.
  ///
  /// Example:
  /// ```dart
  /// ColorUtils.getColor(MaterialShade.shade500, Colors.red); // == Colors.red
  /// ```
  // Exhaustive switch over the sealed enum: a future added shade is a compile
  // error, not a silent fall-through to a wrong tone.
  static Color getColor(MaterialShade shade, final MaterialColor color) =>
      switch (shade) {
        MaterialShade.shade50 => color[50]!,
        MaterialShade.shade100 => color[100]!,
        MaterialShade.shade200 => color[200]!,
        MaterialShade.shade300 => color[300]!,
        MaterialShade.shade400 => color[400]!,
        MaterialShade.shade500 => color[500]!,
        MaterialShade.shade600 => color[600]!,
        MaterialShade.shade700 => color[700]!,
        MaterialShade.shade800 => color[800]!,
        MaterialShade.shade900 => color[900]!,
      };
}
