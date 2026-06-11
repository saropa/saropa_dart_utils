import 'dart:ui' show ColorSpace;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/flutter/color_extensions.dart';

void main() {
  group('ColorHexExtension.toHex', () {
    group('with alpha (default)', () {
      test('should return correct hex for opaque blue', () {
        expect(Colors.blue.toHex(), '#FF2196F3');
      });

      test('should return correct hex for opaque red', () {
        expect(Colors.red.toHex(), '#FFF44336');
      });

      test('should return correct hex for opaque green', () {
        expect(Colors.green.toHex(), '#FF4CAF50');
      });

      test('should return correct hex for opaque white', () {
        expect(Colors.white.toHex(), '#FFFFFFFF');
      });

      test('should return correct hex for opaque black', () {
        expect(Colors.black.toHex(), '#FF000000');
      });

      test('should return correct hex for semi-transparent color', () {
        const Color color = Color.fromARGB(128, 255, 0, 0);
        expect(color.toHex(), '#80FF0000');
      });

      test('should return correct hex for fully transparent color', () {
        const Color color = Color.fromARGB(0, 255, 128, 64);
        expect(color.toHex(), '#00FF8040');
      });

      test('should return correct hex for custom color', () {
        const Color color = Color.fromARGB(255, 18, 52, 86);
        expect(color.toHex(), '#FF123456');
      });
    });

    group('without alpha', () {
      test('should return correct hex for blue without alpha', () {
        expect(Colors.blue.toHex(includeAlpha: false), '#2196F3');
      });

      test('should return correct hex for red without alpha', () {
        expect(Colors.red.toHex(includeAlpha: false), '#F44336');
      });

      test('should return correct hex for green without alpha', () {
        expect(Colors.green.toHex(includeAlpha: false), '#4CAF50');
      });

      test('should return correct hex for white without alpha', () {
        expect(Colors.white.toHex(includeAlpha: false), '#FFFFFF');
      });

      test('should return correct hex for black without alpha', () {
        expect(Colors.black.toHex(includeAlpha: false), '#000000');
      });

      test('should return correct hex for custom color without alpha', () {
        const Color color = Color.fromARGB(255, 171, 205, 239);
        expect(color.toHex(includeAlpha: false), '#ABCDEF');
      });
    });

    group('edge cases', () {
      test('should pad low RGB values with zeros', () {
        const Color color = Color.fromARGB(255, 0, 1, 15);
        expect(color.toHex(), '#FF00010F');
        expect(color.toHex(includeAlpha: false), '#00010F');
      });

      test('should handle low alpha value correctly', () {
        const Color color = Color.fromARGB(1, 0, 0, 0);
        expect(color.toHex(), '#01000000');
      });

      // A double-backed channel exactly at 254.5/255 must round to 0xFF (255),
      // locking round-half-to-even / .round() direction at the boundary.
      test('should round a half-channel up at the 255 boundary', () {
        const Color color = Color.from(alpha: 1, red: 1, green: 1, blue: 1);
        expect(color.toHex(), '#FFFFFFFF');
      });

      // 0.5 channel scales to 127.5 -> rounds to 128 (0x80).
      test('should round a 0.5 channel to 0x80', () {
        const Color color = Color.from(alpha: 1, red: 0.5, green: 0.5, blue: 0.5);
        expect(color.toHex(), '#FF808080');
      });

      // Wide-gamut channels can exceed 1.0; the clamp must keep the byte at FF
      // so the fixed #AARRGGBB width is never broken by a 3-digit hex byte.
      test('should clamp an out-of-sRGB channel above 1.0 to FF', () {
        const Color color = Color.from(
          alpha: 1,
          red: 1.5,
          green: 0,
          blue: 0,
          colorSpace: ColorSpace.displayP3,
        );
        final String hex = color.toHex();
        expect(hex, hasLength(9));
        expect(hex.substring(3, 5), 'FF');
      });

      test('should always produce uppercase output', () {
        const Color color = Color.fromARGB(255, 171, 205, 239);
        expect(color.toHex(), equals(color.toHex().toUpperCase()));
      });

      test('should produce 9 chars with alpha and 7 without', () {
        const Color color = Color.fromARGB(128, 1, 2, 3);
        expect(color.toHex(), hasLength(9));
        expect(color.toHex(includeAlpha: false), hasLength(7));
      });
    });
  });

  group('roundtrip conversion', () {
    test('should preserve color with alpha through toHex then toColor', () {
      const Color original = Color.fromARGB(200, 100, 150, 200);
      final String hex = original.toHex();
      expect(hex.toColor(), equals(original));
    });

    test('should preserve opaque color through toHex then toColor', () {
      const Color original = Color(0xFF9C27B0);
      final String hex = original.toHex();
      expect(hex.toColor(), equals(original));
    });

    test('should add full opacity when roundtripping without alpha', () {
      const Color original = Color.fromARGB(128, 100, 150, 200);
      final String hex = original.toHex(includeAlpha: false);
      expect(hex.toColor(), equals(const Color.fromARGB(255, 100, 150, 200)));
    });
  });
}
