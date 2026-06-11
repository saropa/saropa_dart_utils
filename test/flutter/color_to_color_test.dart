import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/flutter/color_extensions.dart';

void main() {
  group('ColorStringExtensions.toColor', () {
    group('valid input', () {
      test('should return null for empty string', () {
        expect(''.toColor(), isNull);
      });

      test('should parse 6-digit hex without hash', () {
        expect('2196F3'.toColor(), equals(const Color(0xFF2196F3)));
      });

      test('should parse 6-digit hex with hash', () {
        expect('#2196F3'.toColor(), equals(const Color(0xFF2196F3)));
      });

      test('should parse 8-digit hex without hash', () {
        expect('FF2196F3'.toColor(), equals(const Color(0xFF2196F3)));
      });

      test('should parse 8-digit hex with hash', () {
        expect('#FF2196F3'.toColor(), equals(const Color(0xFF2196F3)));
      });

      test('should parse semi-transparent color', () {
        expect('#80FF0000'.toColor(), equals(const Color(0x80FF0000)));
      });

      test('should handle lowercase hex', () {
        expect('#abcdef'.toColor(), equals(const Color(0xFFABCDEF)));
      });

      test('should parse all-zero 6-digit as opaque black', () {
        expect('000000'.toColor(), equals(const Color(0xFF000000)));
      });

      test('should parse all-F 8-digit as opaque white', () {
        expect('FFFFFFFF'.toColor(), equals(const Color(0xFFFFFFFF)));
      });
    });

    group('whitespace handling', () {
      test('should handle whitespace with hash', () {
        expect(' #2196F3 '.toColor(), equals(const Color(0xFF2196F3)));
      });

      test('should handle whitespace without hash', () {
        expect('  2196F3  '.toColor(), equals(const Color(0xFF2196F3)));
      });

      test('should trim tab and newline whitespace', () {
        expect('\t2196F3\n'.toColor(), equals(const Color(0xFF2196F3)));
      });

      // Dart String.trim() removes Unicode whitespace, including the
      // non-breaking space (U+00A0); lock that the value still parses.
      test('should trim a non-breaking space wrapper', () {
        final String wrapped = '${String.fromCharCode(0x00A0)}2196F3${String.fromCharCode(0x00A0)}';
        expect(wrapped.toColor(), equals(const Color(0xFF2196F3)));
      });

      // Whitespace inside the digits is not stripped; int.tryParse rejects it.
      test('should return null for internal whitespace', () {
        expect('21 96 F3'.toColor(), isNull);
      });
    });

    group('multiple-hash leniency', () {
      // removeAll('#') strips every '#' wherever it appears, so these
      // surprising inputs still resolve to blue. Lock the behavior.
      test('should strip a doubled leading hash and parse', () {
        expect('##2196F3'.toColor(), equals(const Color(0xFF2196F3)));
      });

      test('should strip an embedded hash and parse', () {
        expect('2196#F3'.toColor(), equals(const Color(0xFF2196F3)));
      });
    });

    group('invalid input returns null', () {
      test('should return null for non-hex characters', () {
        expect('GGGGGG'.toColor(), isNull);
      });

      test('should return null for 5-character length', () {
        expect('12345'.toColor(), isNull);
      });

      test('should return null for 7-character length', () {
        expect('1234567'.toColor(), isNull);
      });

      test('should return null for 9-character length', () {
        expect('123456789'.toColor(), isNull);
      });

      test('should return null for a very long all-hex string', () {
        expect('1234567890ABCDEF'.toColor(), isNull);
      });

      test('should return null for 3-digit shorthand', () {
        expect('#ABC'.toColor(), isNull);
      });

      // After '#' removal the parser prepends its own 0x; an input that already
      // carries 0x becomes 10 chars and falls through to null.
      test('should return null when a 0x prefix is already present', () {
        expect('0xFF2196F3'.toColor(), isNull);
      });

      test('should return null for a leading minus sign', () {
        expect('-196F3'.toColor(), isNull);
      });

      test('should return null for a leading plus sign', () {
        expect('+196F3'.toColor(), isNull);
      });

      // Full-width '1' (U+FF11) is not an ASCII hex digit; int.tryParse rejects.
      test('should return null for full-width digits', () {
        final String fullWidth = '${String.fromCharCode(0xFF11)}96F3A';
        expect(fullWidth.toColor(), isNull);
      });

      // Arabic-Indic zero (U+0660) is likewise not ASCII hex.
      test('should return null for Arabic-Indic digits', () {
        final String arabicIndic = '${String.fromCharCode(0x0660)}96F3A';
        expect(arabicIndic.toColor(), isNull);
      });
    });

    // No Random, no clock: identical input must always yield identical output.
    group('determinism', () {
      test('should return the same color for repeated calls', () {
        expect('#2196F3'.toColor(), equals('#2196F3'.toColor()));
      });
    });

    // The extension is on non-null String; null-safe call sites use ?.toColor().
    group('null-safe call site', () {
      test('should short-circuit to null on a null receiver', () {
        const String? maybe = null;
        expect(maybe?.toColor(), isNull);
      });

      test('should parse through a non-null nullable receiver', () {
        // Non-const so flow analysis keeps the static type nullable and the
        // null-aware call stays meaningful rather than being narrowed away.
        final String? maybe = <String?>['#2196F3'].first;
        expect(maybe?.toColor(), equals(const Color(0xFF2196F3)));
      });
    });
  });
}
