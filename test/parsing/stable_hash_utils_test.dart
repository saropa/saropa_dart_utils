import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/stable_hash_utils.dart';

void main() {
  group('canonicalString', () {
    test('should normalize null', () {
      expect(canonicalString(null), equals('null'));
    });

    test('should quote strings', () {
      expect(canonicalString('hi'), equals('"hi"'));
    });

    test('should render bool and num without quotes', () {
      expect(canonicalString(true), equals('true'));
      expect(canonicalString(42), equals('42'));
    });

    test('should preserve list order', () {
      expect(canonicalString(<Object?>[1, 2, 3]), equals('[1,2,3]'));
    });

    test('should sort map keys regardless of insertion order', () {
      final String fromB = canonicalString(<String, Object?>{'b': 1, 'a': 2});
      final String fromA = canonicalString(<String, Object?>{'a': 2, 'b': 1});

      expect(fromB, equals('{"a":2,"b":1}'));
      expect(fromB, equals(fromA));
    });

    test('should canonicalize nested structures recursively', () {
      final String text = canonicalString(<String, Object?>{
        'items': <Object?>[
          <String, Object?>{'z': 1, 'a': 2},
        ],
      });

      expect(text, equals('{"items":[{"a":2,"z":1}]}'));
    });
  });

  group('stableHash', () {
    test('should produce a 16-char lowercase hex string', () {
      final String hash = stableHash('anything');

      expect(hash.length, equals(16));
      expect(hash, equals(hash.toLowerCase()));
    });

    test('should be equal for equal inputs', () {
      expect(stableHash(<Object?>[1, 'two', true]), equals(stableHash(<Object?>[1, 'two', true])));
    });

    // Pinned digests guard the FNV-1a output value. They were verified against a
    // BigInt mod-2^64 ground truth and match the pre-rewrite native-int result,
    // so the 32-bit-limb implementation must reproduce them on EVERY platform
    // (VM and web). A change here means the algorithm or limb math drifted.
    test('should match pinned digests across platforms', () {
      expect(stableHash('a'), equals('d4272417d7c77eea'));
      expect(stableHash(<String, int>{'a': 1, 'b': 2}), equals('a0ebc03bdc71de7b'));
    });

    test('should be unaffected by map key insertion order', () {
      final String first = stableHash(<String, Object?>{'a': 1, 'b': 2});
      final String second = stableHash(<String, Object?>{'b': 2, 'a': 1});

      expect(first, equals(second));
    });

    test('should differ when list order differs', () {
      final String first = stableHash(<Object?>[1, 2, 3]);
      final String second = stableHash(<Object?>[3, 2, 1]);

      expect(first, isNot(equals(second)));
    });

    test('should distinguish null from the string "null"', () {
      expect(stableHash(null), isNot(equals(stableHash('null'))));
    });

    test('should hash deeply nested structures deterministically', () {
      final Map<String, Object?> nested = <String, Object?>{
        'a': <String, Object?>{
          'b': <Object?>[
            1,
            <String, Object?>{'c': 'x'},
          ],
        },
      };

      expect(stableHash(nested), equals(stableHash(nested)));
    });
  });
}
