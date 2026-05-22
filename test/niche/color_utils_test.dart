import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/niche/color_utils.dart';

void main() {
  group('hexToRgb', () {
    test('splits packed RGB into channels', () {
      expect(hexToRgb(0xFF1020), <int>[0xFF, 0x10, 0x20]);
    });

    test('black and white', () {
      expect(hexToRgb(0x000000), <int>[0, 0, 0]);
      expect(hexToRgb(0xFFFFFF), <int>[255, 255, 255]);
    });

    test('ignores bits above the blue/green/red bytes', () {
      // Only the low 24 bits matter for the channels.
      expect(hexToRgb(0xAB123456), <int>[0x12, 0x34, 0x56]);
    });
  });

  group('rgbToHex', () {
    test('packs to opaque ARGB', () {
      expect(rgbToHex(255, 0, 0), 0xFFFF0000);
      expect(rgbToHex(0, 255, 0), 0xFF00FF00);
      expect(rgbToHex(0, 0, 255), 0xFF0000FF);
    });

    test('clamps channels above 255', () {
      expect(rgbToHex(300, 300, 300), 0xFFFFFFFF);
    });

    test('clamps negative channels to 0', () {
      expect(rgbToHex(-5, -5, -5), 0xFF000000);
    });
  });

  group('luminance', () {
    test('white is 1.0', () {
      expect(luminance(255, 255, 255), closeTo(1.0, 1e-9));
    });

    test('black is 0.0', () {
      expect(luminance(0, 0, 0), closeTo(0.0, 1e-12));
    });

    test('pure green is brighter than pure red and blue (WCAG weights)', () {
      expect(luminance(0, 255, 0), greaterThan(luminance(255, 0, 0)));
      expect(luminance(255, 0, 0), greaterThan(luminance(0, 0, 255)));
    });
  });

  group('contrastRatio', () {
    test('black on white is 21.0', () {
      expect(contrastRatio(0, 0, 0, 255, 255, 255), closeTo(21.0, 1e-9));
    });

    test('identical colors give 1.0', () {
      expect(contrastRatio(120, 120, 120, 120, 120, 120), closeTo(1.0, 1e-12));
    });

    test('order of the two colors does not matter', () {
      final double a = contrastRatio(0, 0, 0, 255, 255, 255);
      final double b = contrastRatio(255, 255, 255, 0, 0, 0);
      expect(a, closeTo(b, 1e-12));
    });
  });
}
