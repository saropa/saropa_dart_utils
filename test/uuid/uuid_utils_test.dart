import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/uuid/uuid_utils.dart';

void main() {
  group('UuidUtils', () {
    group('isUUID', () {
      test('valid UUID v1 with hyphens', () {
        expect(UuidUtils.isUUID('123e4567-e89b-12d3-a456-426614174000'), isTrue);
      });

      test('valid UUID v4 with hyphens', () {
        expect(UuidUtils.isUUID('550e8400-e29b-41d4-a716-446655440000'), isTrue);
      });

      test('valid UUID v4 lowercase', () {
        expect(UuidUtils.isUUID('550e8400-e29b-41d4-a716-446655440000'), isTrue);
      });

      test('valid UUID v4 uppercase', () {
        expect(UuidUtils.isUUID('550E8400-E29B-41D4-A716-446655440000'), isTrue);
      });

      test('valid UUID v4 mixed case', () {
        expect(UuidUtils.isUUID('550e8400-E29B-41d4-A716-446655440000'), isTrue);
      });

      test('valid UUID without hyphens', () {
        expect(UuidUtils.isUUID('123e4567e89b12d3a456426614174000'), isTrue);
      });

      test('valid UUID v4 without hyphens', () {
        expect(UuidUtils.isUUID('550e8400e29b41d4a716446655440000'), isTrue);
      });

      test('returns false for null', () {
        expect(UuidUtils.isUUID(null), isFalse);
      });

      test('returns false for empty string', () {
        expect(UuidUtils.isUUID(''), isFalse);
      });

      test('returns false for invalid format', () {
        expect(UuidUtils.isUUID('not-a-uuid'), isFalse);
      });

      test('returns false for wrong length (too short)', () {
        expect(UuidUtils.isUUID('550e8400-e29b-41d4-a716'), isFalse);
      });

      test('returns false for wrong length (too long)', () {
        expect(UuidUtils.isUUID('550e8400-e29b-41d4-a716-446655440000-extra'), isFalse);
      });

      test('returns false for invalid version (0)', () {
        expect(UuidUtils.isUUID('550e8400-e29b-01d4-a716-446655440000'), isFalse);
      });

      test('returns false for invalid version (6)', () {
        expect(UuidUtils.isUUID('550e8400-e29b-61d4-a716-446655440000'), isFalse);
      });

      test('returns false for invalid variant bits', () {
        // Variant must be 8, 9, a, or b
        expect(UuidUtils.isUUID('550e8400-e29b-41d4-0716-446655440000'), isFalse);
        expect(UuidUtils.isUUID('550e8400-e29b-41d4-c716-446655440000'), isFalse);
      });

      test('returns false for non-hex characters', () {
        expect(UuidUtils.isUUID('550g8400-e29b-41d4-a716-446655440000'), isFalse);
      });

      test('valid UUID v2', () {
        expect(UuidUtils.isUUID('550e8400-e29b-21d4-a716-446655440000'), isTrue);
      });

      test('valid UUID v3', () {
        expect(UuidUtils.isUUID('550e8400-e29b-31d4-a716-446655440000'), isTrue);
      });

      test('valid UUID v5', () {
        expect(UuidUtils.isUUID('550e8400-e29b-51d4-a716-446655440000'), isTrue);
      });
    });

    group('addHyphens', () {
      test('adds hyphens to valid 32-char UUID', () {
        expect(
          UuidUtils.addHyphens('123e4567e89b12d3a456426614174000'),
          equals('123e4567-e89b-12d3-a456-426614174000'),
        );
      });

      test('returns original if already has hyphens', () {
        const String uuid = '123e4567-e89b-12d3-a456-426614174000';
        expect(UuidUtils.addHyphens(uuid), equals(uuid));
      });

      test('returns null for null input', () {
        expect(UuidUtils.addHyphens(null), isNull);
      });

      test('returns null for empty string', () {
        expect(UuidUtils.addHyphens(''), isNull);
      });

      test('returns null for wrong length', () {
        expect(UuidUtils.addHyphens('tooshort'), isNull);
        expect(UuidUtils.addHyphens('a' * 31), isNull);
        expect(UuidUtils.addHyphens('a' * 33), isNull);
      });
    });

    group('removeHyphens', () {
      test('removes hyphens from UUID', () {
        expect(
          UuidUtils.removeHyphens('123e4567-e89b-12d3-a456-426614174000'),
          equals('123e4567e89b12d3a456426614174000'),
        );
      });

      test('returns same string if no hyphens', () {
        const String uuid = '123e4567e89b12d3a456426614174000';
        expect(UuidUtils.removeHyphens(uuid), equals(uuid));
      });

      test('returns null for null input', () {
        expect(UuidUtils.removeHyphens(null), isNull);
      });

      test('returns null for empty string', () {
        expect(UuidUtils.removeHyphens(''), isNull);
      });
    });

    group('round-trip', () {
      test('addHyphens then removeHyphens returns original', () {
        const String original = '123e4567e89b12d3a456426614174000';
        final String? withHyphens = UuidUtils.addHyphens(original);
        final String? result = UuidUtils.removeHyphens(withHyphens);
        expect(result, equals(original));
      });

      test('removeHyphens then addHyphens returns original', () {
        const String original = '123e4567-e89b-12d3-a456-426614174000';
        final String? withoutHyphens = UuidUtils.removeHyphens(original);
        final String? result = UuidUtils.addHyphens(withoutHyphens);
        expect(result, equals(original));
      });
    });
  });
}
