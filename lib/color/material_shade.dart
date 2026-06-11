import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/iterable/iterable_extensions.dart';

/// An enumeration of the available `MaterialColor` shade intensities.
///
/// Material Design swatches ([MaterialColor]) expose ten fixed shade
/// intensities keyed by the integers `50, 100, 200, 300, 400, 500, 600, 700,
/// 800, 900`. Modeling them as an enum (rather than passing raw ints around)
/// gives compile-time exhaustiveness: a `switch` over [MaterialShade] is
/// checked by the analyzer, so adding or removing a rung forces every consumer
/// to be updated instead of silently mishandling an unknown integer.
///
/// The declaration order is the intensity order (lightest first), so the enum
/// `index` is a stable, persistable ordinal — see [MaterialShadeName.value] for
/// the mapping to the Material integer.
///
/// Example:
/// ```dart
/// final Color swatch = Colors.blue[MaterialShade.shade500.value]!; // blue[500]
/// ```
enum MaterialShade {
  /// The lightest shade (Material integer `50`).
  shade50,

  /// Material integer `100`.
  shade100,

  /// Material integer `200`.
  shade200,

  /// Material integer `300`.
  shade300,

  /// Material integer `400` — the last rung of the light band.
  shade400,

  /// Material integer `500` — the swatch's primary tone, first of the dark band.
  shade500,

  /// Material integer `600`.
  shade600,

  /// Material integer `700`.
  shade700,

  /// Material integer `800`.
  shade800,

  /// The darkest shade (Material integer `900`).
  shade900,
}

/// Canonical Material shade-intensity integer lists plus a seeded picker.
///
/// Centralizes the two halves of the shade ladder — the light band
/// ([lightShades], `50`–`400`) and the dark band ([darkShades], `500`–`900`) —
/// so callers index a [MaterialColor] from a single source of truth instead of
/// re-typing the magic integers. [shades] is the concatenation of the two, in
/// intensity order.
///
/// Declared `abstract final` so it can never be instantiated or subclassed: it
/// is a namespace for `static const` data and one `static` helper, not a value
/// type.
///
/// Example:
/// ```dart
/// for (final int level in MaterialShadeLevels.shades) {
///   print(Colors.blue[level]); // every rung of the blue swatch
/// }
/// ```
abstract final class MaterialShadeLevels {
  /// Returns a random Material shade integer, optionally constrained by band.
  ///
  /// Picks uniformly from a band and returns its Material integer (one of the
  /// values in [shades]). The band is selected by [isLightBackground]:
  ///
  /// - `null` — any shade ([shades]).
  /// - `true` — a DARK shade ([darkShades], `500`–`900`). Counter-intuitive on
  ///   purpose: a *light background* needs a *dark*, high-contrast foreground to
  ///   stay readable, so `isLightBackground: true` deliberately draws from the
  ///   dark band. Treating the flag as "give me a light shade" is the trap this
  ///   wiring guards against.
  /// - `false` — a LIGHT shade ([lightShades], `50`–`400`), readable on a dark
  ///   background.
  ///
  /// Pass [seed] to make the pick deterministic (the same [seed] returns the
  /// same shade every call) — required for reproducible demo data and stable
  /// widget tests; omit it for a fresh pick each run.
  ///
  /// Returns `int?` only because the underlying [Iterable.randomElement] yields
  /// `null` on an empty source. The three source lists here are non-empty
  /// compile-time constants, so in practice the result is never `null`; the
  /// nullable type is kept to mirror the underlying contract rather than hide it.
  ///
  /// Example:
  /// ```dart
  /// MaterialShadeLevels.randomShade(isLightBackground: true, seed: 7); // a 500..900 value
  /// ```
  @useResult
  static int? randomShade({bool? isLightBackground, int? seed}) {
    // No band requested: draw from the full ladder.
    if (isLightBackground == null) {
      return shades.randomElement(seed: seed);
    }

    // Light background -> dark, high-contrast shade (see member doc for the
    // deliberate inversion this branch encodes).
    if (isLightBackground) {
      return darkShades.randomElement(seed: seed);
    }

    // Dark background -> light shade.
    return lightShades.randomElement(seed: seed);
  }

  /// The full shade ladder in intensity order: [lightShades] then [darkShades].
  ///
  /// Built by spreading the two band lists so the ordering and contents can
  /// never drift from their single sources of truth — editing a band updates
  /// this automatically. Length is always `10` with no duplicates.
  static const List<int> shades = <int>[
    ...lightShades,
    ...darkShades,
  ];

  /// The light band: the five shades (`50`–`400`) that read as light tones and
  /// therefore pair with a black foreground (see [MaterialShadeName.onShade]).
  static const List<int> lightShades = <int>[50, 100, 200, 300, 400];

  /// The dark band: the five shades (`500`–`900`) that read as dark tones and
  /// therefore pair with a white foreground (see [MaterialShadeName.onShade]).
  static const List<int> darkShades = <int>[500, 600, 700, 800, 900];
}

/// Derived facts for a [MaterialShade]: its Material integer, contrast-correct
/// foreground color, and UI labels.
///
/// Keeps the shade ladder's "every consumer re-derives this by hand" knowledge
/// in one place — the index integer, the readable on-color, and the display
/// strings — so call sites never recompute luminance or hand-format labels.
extension MaterialShadeName on MaterialShade {
  /// The raw Material integer used to index a [MaterialColor].
  ///
  /// Maps each enum rung to its `50`–`900` key, e.g. `Colors.blue[shade.value]`.
  /// Written as an exhaustive `switch` (not `int.parse(name)`) so the mapping is
  /// explicit and analyzer-checked; a missing case is a compile error, never a
  /// runtime surprise.
  ///
  /// Example:
  /// ```dart
  /// MaterialShade.shade500.value; // 500
  /// ```
  int get value => switch (this) {
    MaterialShade.shade50 => 50,
    MaterialShade.shade100 => 100,
    MaterialShade.shade200 => 200,
    MaterialShade.shade300 => 300,
    MaterialShade.shade400 => 400,
    MaterialShade.shade500 => 500,
    MaterialShade.shade600 => 600,
    MaterialShade.shade700 => 700,
    MaterialShade.shade800 => 800,
    MaterialShade.shade900 => 900,
  };

  /// The readable foreground color to draw on top of this shade.
  ///
  /// Returns [Colors.black] for the light band (`shade50`–`shade400`) and
  /// [Colors.white] for the dark band (`shade500`–`shade900`), matching
  /// Material's accessibility-contrast convention. The boundary sits exactly
  /// between `shade400` and `shade500`; both returned colors are fully opaque.
  /// Encoding the rule here means callers never recompute luminance to decide a
  /// label color.
  ///
  /// Example:
  /// ```dart
  /// MaterialShade.shade100.onShade; // Colors.black
  /// MaterialShade.shade700.onShade; // Colors.white
  /// ```
  Color get onShade => switch (this) {
    MaterialShade.shade50 ||
    MaterialShade.shade100 ||
    MaterialShade.shade200 ||
    MaterialShade.shade300 ||
    MaterialShade.shade400 => Colors.black,
    MaterialShade.shade500 ||
    MaterialShade.shade600 ||
    MaterialShade.shade700 ||
    MaterialShade.shade800 ||
    MaterialShade.shade900 => Colors.white,
  };

  /// The plain UI label for this shade, e.g. `'Shade 500'`.
  ///
  /// Uses [value] as the single source of the integer so the label can never
  /// disagree with the index used to fetch the color. Built with a plain ASCII
  /// space and ordinary Arabic digits — no thin or non-breaking space — because
  /// this string is also compared and persisted, and a "prettier" separator
  /// would silently break equality.
  ///
  /// Example:
  /// ```dart
  /// MaterialShade.shade50.displayName; // 'Shade 50'
  /// ```
  String get displayName => 'Shade $value';

  /// The UI label annotated at the three band endpoints.
  ///
  /// Adds a parenthetical only to the meaningful extremes — `shade50`
  /// `(Lightest)`, `shade500` `(Middle)`, `shade900` `(Darkest)` — and returns
  /// the plain [displayName] for the other seven rungs. Exactly three members
  /// carry an annotation; the default branch reuses [displayName] so the
  /// un-annotated rungs can never drift from the plain label.
  ///
  /// Example:
  /// ```dart
  /// MaterialShade.shade500.displayNameAnnotated; // 'Shade 500 (Middle)'
  /// MaterialShade.shade300.displayNameAnnotated; // 'Shade 300'
  /// ```
  String get displayNameAnnotated => switch (this) {
    MaterialShade.shade50 => 'Shade 50 (Lightest)',
    MaterialShade.shade500 => 'Shade 500 (Middle)',
    MaterialShade.shade900 => 'Shade 900 (Darkest)',
    MaterialShade.shade100 ||
    MaterialShade.shade200 ||
    MaterialShade.shade300 ||
    MaterialShade.shade400 ||
    MaterialShade.shade600 ||
    MaterialShade.shade700 ||
    MaterialShade.shade800 => displayName,
  };
}
