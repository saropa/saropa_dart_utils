import 'dart:math' as math;

/// Color hex to RGB. RGB to hex. Contrast ratio (WCAG). Roadmap #211–213.
List<int> hexToRgb(int hexColor) {
  final int r = (hexColor >> 16) & 0xFF;
  final int g = (hexColor >> 8) & 0xFF;
  final int b = hexColor & 0xFF;
  return <int>[r, g, b];
}

int rgbToHex(int r, int g, int b) {
  final int rClamped = r.clamp(0, 255);
  final int gClamped = g.clamp(0, 255);
  final int bClamped = b.clamp(0, 255);
  return 0xFF000000 | (rClamped << 16) | (gClamped << 8) | bClamped;
}

double luminance(int r, int g, int b) {
  final double rLinear = _srgb(r / 255);
  final double gLinear = _srgb(g / 255);
  final double bLinear = _srgb(b / 255);
  return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
}

double _srgb(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double contrastRatio(int r1, int g1, int b1, int r2, int g2, int b2) {
  final double luminance1 = luminance(r1, g1, b1) + 0.05;
  final double luminance2 = luminance(r2, g2, b2) + 0.05;
  return luminance1 > luminance2 ? luminance1 / luminance2 : luminance2 / luminance1;
}
