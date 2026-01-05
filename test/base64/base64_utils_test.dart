import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/base64/base64_utils.dart';

void main() {
  group('Base64Utils', () {
    group('compressText', () {
      test('compresses and returns Base64 string', () {
        final String? compressed = Base64Utils.compressText('Hello, World!');
        expect(compressed, isNotNull);
        expect(compressed, isNotEmpty);
        // Base64 strings only contain these characters
        expect(compressed, matches(RegExp(r'^[A-Za-z0-9+/=]+$')));
      });

      test('returns null for null input', () {
        expect(Base64Utils.compressText(null), isNull);
      });

      test('returns null for empty string', () {
        expect(Base64Utils.compressText(''), isNull);
      });

      test('compresses long text', () {
        final String longText = 'a' * 10000;
        final String? compressed = Base64Utils.compressText(longText);
        // Compressed should be smaller than original for repetitive content
        expect(compressed, isNotNull);
        expect(compressed, hasLength(lessThan(longText.length)));
      });

      test('compresses unicode text', () {
        final String? compressed = Base64Utils.compressText('Hello 世界 🌍');
        expect(compressed, isNotNull);
        expect(compressed, isNotEmpty);
      });

      test('compresses JSON text', () {
        const String jsonText = '{"name": "test", "value": 123}';
        final String? compressed = Base64Utils.compressText(jsonText);
        expect(compressed, isNotNull);
      });
    });

    group('decompressText', () {
      test('decompresses back to original text', () {
        const String original = 'Hello, World!';
        final String? compressed = Base64Utils.compressText(original);
        final String? decompressed = Base64Utils.decompressText(compressed);
        expect(decompressed, equals(original));
      });

      test('returns null for null input', () {
        expect(Base64Utils.decompressText(null), isNull);
      });

      test('returns null for empty string', () {
        expect(Base64Utils.decompressText(''), isNull);
      });

      test('returns null for invalid Base64', () {
        expect(Base64Utils.decompressText('not-valid-base64!!!'), isNull);
      });

      test('returns null for valid Base64 but not gzipped', () {
        // 'SGVsbG8=' is Base64 for 'Hello' but not gzipped
        expect(Base64Utils.decompressText('SGVsbG8='), isNull);
      });

      test('decompresses long text correctly', () {
        final String original = 'a' * 10000;
        final String? compressed = Base64Utils.compressText(original);
        final String? decompressed = Base64Utils.decompressText(compressed);
        expect(decompressed, equals(original));
      });

      test('decompresses unicode text correctly', () {
        const String original = 'Hello 世界 🌍 émojis';
        final String? compressed = Base64Utils.compressText(original);
        final String? decompressed = Base64Utils.decompressText(compressed);
        expect(decompressed, equals(original));
      });

      test('decompresses JSON correctly', () {
        const String original = '{"name": "test", "value": 123, "nested": {"a": 1}}';
        final String? compressed = Base64Utils.compressText(original);
        final String? decompressed = Base64Utils.decompressText(compressed);
        expect(decompressed, equals(original));
      });

      test('round-trip with special characters', () {
        const String original = r'Special chars: \n\t\r "quotes" <tags> & symbols';
        final String? compressed = Base64Utils.compressText(original);
        final String? decompressed = Base64Utils.decompressText(compressed);
        expect(decompressed, equals(original));
      });

      test('round-trip with newlines and whitespace', () {
        const String original = 'Line 1\nLine 2\n\tIndented\n';
        final String? compressed = Base64Utils.compressText(original);
        final String? decompressed = Base64Utils.decompressText(compressed);
        expect(decompressed, equals(original));
      });
    });
  });
}
