// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/uuid/uuid_v4_utils.dart';

void main() {
  group('generateUuidV4', () {
    test('matches the canonical 8-4-4-4-12 hyphenated format', () {
      expect(
        generateUuidV4(),
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')),
      );
    });

    test('total string length is 36 characters', () {
      expect(generateUuidV4(), hasLength(36));
    });

    test('version nibble is 4 (RFC 4122 v4)', () {
      // The 15th character (start of the third group) encodes the version.
      expect(generateUuidV4()[14], '4');
    });

    test('variant nibble is one of 8, 9, a, b', () {
      // The 20th character (start of the fourth group) encodes the variant
      // (top two bits are 10xx).
      expect(generateUuidV4()[19], anyOf('8', '9', 'a', 'b'));
    });

    test('produces unique values across many calls', () {
      final Set<String> seen = <String>{};
      for (int i = 0; i < 1000; i++) {
        seen.add(generateUuidV4());
      }
      expect(seen, hasLength(1000));
    });
  });
}
