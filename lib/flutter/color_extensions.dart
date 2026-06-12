import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/num/num_extensions.dart';
import 'package:saropa_dart_utils/num/num_range_extensions.dart';
import 'package:saropa_dart_utils/string/string_manipulation_extensions.dart';

/// Parses a hex color string into a Flutter [Color].
///
/// Lives on `String` so any hex token from a theme file, query parameter, or
/// user input can be turned into a [Color] without a separate parser object.
extension ColorStringExtensions on String {
  /// Parses this hex string into a [Color], or returns `null` when it is not a
  /// valid 6- or 8-digit hex color.
  ///
  /// Accepts an optional leading `#`, is case-insensitive, and trims
  /// surrounding whitespace. A 6-digit value is read as `RRGGBB` and forced to
  /// full opacity (`0xFF` alpha); an 8-digit value is read as `AARRGGBB`.
  ///
  /// Returns `null` for empty input, any length other than 6 or 8 (after the
  /// `#` is removed and the value trimmed), or non-hex characters — `null` is
  /// the signal "this was not a color", so callers can fall back instead of
  /// crashing on bad data.
  ///
  /// Edge cases that intentionally return `null`: a `0x` prefix already present
  /// (becomes 10 chars), a leading sign (`-196F3`), full-width or Arabic-Indic
  /// digits, and internal whitespace (`int.tryParse` rejects them). Embedded
  /// `#` characters are stripped wherever they appear, so `'##2196F3'` and
  /// `'2196#F3'` both parse — that surprising leniency is locked by tests.
  ///
  /// Example:
  /// ```dart
  /// '2196F3'.toColor();   // Color(0xFF2196F3)
  /// '#80FF0000'.toColor(); // Color(0x80FF0000)
  /// 'GGGGGG'.toColor();   // null
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Color? toColor() {
    // Empty input is never a color; guard first so the switch below only ever
    // sees a non-empty candidate.
    if (isEmpty) {
      return null;
    }

    // Strip EVERY '#' (not just a leading one) then trim, matching the
    // historical Saropa behavior; the resulting length selects the format.
    // ref: https://stackoverflow.com/questions/49835146
    final String hexColor = removeAll('#').trim();

    switch (hexColor.length) {
      // 6 digits carry no alpha channel: prepend 0xFF to force full opacity
      // rather than leaving alpha at 0x00 (which would render fully invisible).
      case 6:
        final int? rgbValue = int.tryParse('0xFF$hexColor');
        if (rgbValue == null) {
          return null;
        }
        return Color(rgbValue);

      // 8 digits already include alpha; parse the whole AARRGGBB word.
      case 8:
        final int? argbValue = int.tryParse('0x$hexColor');
        if (argbValue == null) {
          return null;
        }
        return Color(argbValue);
    }

    // Any other length (3-digit shorthand, 10-char 0x-prefixed, etc.) is not a
    // supported color: return null instead of guessing an expansion.
    return null;
  }
}

/// Formats a Flutter [Color] as an uppercase hex string.
extension ColorHexExtension on Color {
  /// Converts this [Color] to a hex string of the form `#AARRGGBB`, or
  /// `#RRGGBB` when [includeAlpha] is `false`.
  ///
  /// Output is always uppercase and zero-padded, so the result is exactly 9
  /// characters with alpha or 7 without it — a stable width that round-trips
  /// through [ColorStringExtensions.toColor].
  ///
  /// Each channel is read from the modern double-backed [Color] getters
  /// (`a`/`r`/`g`/`b`, range `0.0`–`1.0`) and clamped to `0.0`–`1.0` BEFORE
  /// scaling to a byte. The clamp prevents a wide-gamut color (e.g. a
  /// display-P3 channel above `1.0`) from producing a 3-hex-digit byte that
  /// would break the fixed `#AARRGGBB` width.
  ///
  /// Example:
  /// ```dart
  /// Colors.blue.toHex();                    // '#FF2196F3'
  /// Colors.blue.toHex(includeAlpha: false); // '#2196F3'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String toHex({bool includeAlpha = true}) {
    final String red = _channelHex(r);
    final String green = _channelHex(g);
    final String blue = _channelHex(b);

    // Alpha leads the string so the output matches Flutter's own 0xAARRGGBB
    // memory order and parses straight back via the 8-digit toColor() branch.
    if (includeAlpha) {
      return '#${_channelHex(a)}$red$green$blue';
    }

    return '#$red$green$blue';
  }

  /// Scales one `0.0`–`1.0` channel to a zero-padded, uppercase hex byte.
  ///
  /// Clamps first because a wide-gamut [Color] can report a channel above
  /// `1.0`; an unclamped `(1.2 * 255).round()` would exceed `0xFF` and yield a
  /// 3-character hex string, breaking the fixed output width.
  /// Audited: 2026-06-12 11:26 EDT
  static String _channelHex(double channel) =>
      (channel.clamp(0.0, 1.0) * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
}

/// HSL-lightness adjustment helpers that keep hue, saturation, and alpha.
extension ColorLightExtensions on Color {
  /// Returns a darker copy of this color by subtracting [amount] (`0`–`1`) from
  /// its HSL lightness, preserving hue, saturation, and alpha.
  ///
  /// Returns the color unchanged when [amount] is `0` or falls outside the
  /// inclusive `0`–`1` range (negative, greater than `1`, infinite, or `NaN`).
  /// This lenient contract — silently no-op instead of throwing — matches the
  /// clamp-everywhere style of this package and is locked by tests so it cannot
  /// regress. `NaN` in particular must short-circuit here: feeding it into the
  /// lightness math would produce a `NaN` color.
  ///
  /// HSL is used rather than direct RGB scaling because lightness maps to a
  /// single HSL axis, so adjusting it leaves the perceived hue intact.
  /// ref: https://stackoverflow.com/questions/58360989
  ///
  /// Example:
  /// ```dart
  /// const Color blue = Color(0xFF2196F3);
  /// blue.darken(0.3); // a darker blue, same hue
  /// blue.darken(-0.5); // unchanged (out of range)
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Color darken(double amount) {
    // No-op short-circuit: zero delta means the caller wants this color back.
    if (amount == 0) {
      return this;
    }

    // Out-of-range (including NaN and +/-infinity) returns unchanged so the
    // subtraction below can never push lightness to a NaN/invalid color.
    if (amount.isNotBetween(0, 1)) {
      return this;
    }

    final HSLColor hsl = HSLColor.fromColor(this);

    // Subtract for darken; clamp so amount == 1 lands exactly on lightness 0
    // rather than a negative value HSLColor would reject.
    // ignore: avoid_money_arithmetic_on_double -- HSL lightness math, not currency; false positive
    final HSLColor hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Returns a lighter copy of this color by adding [amount] (`0`–`1`) to its
  /// HSL lightness, preserving hue, saturation, and alpha.
  ///
  /// Returns the color unchanged when [amount] is zero-or-negative or falls
  /// outside the inclusive `0`–`1` range (greater than `1`, infinite, or
  /// `NaN`). Same lenient, no-throw contract as [darken].
  ///
  /// ref: https://stackoverflow.com/questions/58360989
  ///
  /// Example:
  /// ```dart
  /// const Color blue = Color(0xFF2196F3);
  /// blue.lighten(0.2); // a lighter blue, same hue
  /// blue.lighten(0);   // unchanged
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Color lighten(double amount) {
    // No-op for zero or negative: nothing to lighten by.
    if (amount.isZeroOrNegative) {
      return this;
    }

    // Out-of-range (including NaN and +infinity) returns unchanged so the
    // addition below can never produce a NaN/invalid color.
    if (amount.isNotBetween(0, 1)) {
      return this;
    }

    final HSLColor hsl = HSLColor.fromColor(this);

    // Add for lighten; clamp so amount == 1 lands exactly on lightness 1.
    // ignore: avoid_money_arithmetic_on_double -- HSL lightness math, not currency; false positive
    final HSLColor hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

/// WCAG-contrast convergence helper for legible foreground colors.
extension ColorContrastExtensions on Color {
  /// Returns a copy of this color adjusted so it reaches at least [minRatio]
  /// WCAG contrast against [background], keeping it legible as text or icons on
  /// a tinted surface.
  ///
  /// Darkens the foreground when [background] is light and lightens it when
  /// dark, so a single call works in both light and dark themes. [step] is the
  /// per-iteration HSL lightness delta; [maxSteps] caps the loop so a pair that
  /// can never reach the target (mid-gray on mid-gray, identical fg/bg) returns
  /// the best effort instead of spinning forever.
  ///
  /// Termination is guaranteed: the loop runs at most [maxSteps] times, and a
  /// non-positive [maxSteps] returns this color unchanged without entering the
  /// body. A zero, `NaN`, or negative [step] never converges but still
  /// terminates — each adjustment is a no-op (guarded by [darken]/[lighten]),
  /// so the best-effort result is simply this color.
  ///
  /// Contrast is computed from [Color.computeLuminance], which ignores alpha;
  /// the ratio is therefore evaluated as if both colors were opaque (the
  /// standard WCAG-on-opaque assumption). The returned color keeps this color's
  /// own alpha.
  ///
  /// Example:
  /// ```dart
  /// const Color gold = Color.fromRGBO(207, 181, 59, 1);
  /// const Color cream = Color.fromRGBO(245, 243, 235, 1);
  /// gold.readableOn(cream); // a darker gold that clears 4.5:1 on cream
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  Color readableOn(
    Color background, {
    double minRatio = 4.5,
    double step = 0.04,
    int maxSteps = 16,
  }) {
    // Split at 0.45 rather than the 0.5 luminance midpoint because a mid
    // background reads as "light" to the eye a touch before the math midpoint,
    // so push the foreground darker against it.
    final bool darkenToward = background.computeLuminance() > 0.45;

    Color result = this;
    // Bounded loop: a pathological pair that can never hit minRatio (or a
    // no-op step) exits after maxSteps with the best result so far.
    for (int i = 0; i < maxSteps; i++) {
      if (_wcagContrast(result, background) >= minRatio) {
        return result;
      }
      result = darkenToward ? result.darken(step) : result.lighten(step);
    }

    return result;
  }
}

/// WCAG 2.x contrast ratio between two colors: `(L1 + 0.05) / (L2 + 0.05)` with
/// `L1` the lighter luminance.
///
/// [Color.computeLuminance] already applies the sRGB gamma expansion, so it IS
/// the WCAG relative luminance — there is no need to reimplement the channel
/// math here. The int-channel version of this formula lives in
/// `lib/niche/color_utils.dart` as `contrastRatio`.
/// Audited: 2026-06-12 11:26 EDT
double _wcagContrast(Color a, Color b) {
  final double la = a.computeLuminance() + 0.05;
  final double lb = b.computeLuminance() + 0.05;
  return la > lb ? la / lb : lb / la;
}
