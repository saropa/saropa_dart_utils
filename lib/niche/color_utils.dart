import 'dart:math' as math;

/// Color hex to RGB. RGB to hex. Contrast ratio (WCAG). Roadmap #211–213.
List<int> hexToRgb(int hexColor) {
  final int r = (hexColor >> 16) & 0xFF;
  final int g = (hexColor >> 8) & 0xFF;
  final int b = hexColor & 0xFF;
  return <int>[r, g, b];
}

/// Packs [r], [g], and [b] channels into a fully opaque `0xAARRGGBB` color int.
///
/// Each channel is clamped to `0`–`255` before packing, and the alpha byte is
/// forced to `0xFF`.
///
/// Example:
/// ```dart
/// rgbToHex(255, 0, 0); // 0xFFFF0000
/// ```
int rgbToHex(int r, int g, int b) {
  final int rClamped = r.clamp(0, 255);
  final int gClamped = g.clamp(0, 255);
  final int bClamped = b.clamp(0, 255);
  return 0xFF000000 | (rClamped << 16) | (gClamped << 8) | bClamped;
}

/// Returns the relative luminance of an sRGB color per the WCAG 2.x formula.
///
/// [r], [g], and [b] are channel values in `0`–`255`. The result is in
/// `0.0` (black) to `1.0` (white) and feeds [contrastRatio].
double luminance(int r, int g, int b) {
  final double rLinear = _srgb(r / 255);
  final double gLinear = _srgb(g / 255);
  final double bLinear = _srgb(b / 255);
  return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
}

double _srgb(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

/// Returns the WCAG contrast ratio between two sRGB colors.
///
/// The first color is `(r1, g1, b1)` and the second is `(r2, g2, b2)`, each
/// channel in `0`–`255`. The result ranges from `1.0` (identical) to `21.0`
/// (black on white); order of the two colors does not matter. WCAG AA
/// requires at least `4.5` for normal text.
///
/// Example:
/// ```dart
/// contrastRatio(0, 0, 0, 255, 255, 255); // 21.0
/// ```
double contrastRatio(int r1, int g1, int b1, int r2, int g2, int b2) {
  final double luminance1 = luminance(r1, g1, b1) + 0.05;
  final double luminance2 = luminance(r2, g2, b2) + 0.05;
  return luminance1 > luminance2 ? luminance1 / luminance2 : luminance2 / luminance1;
}
