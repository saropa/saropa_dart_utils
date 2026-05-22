import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/rolling_hash_utils.dart';

void main() {
  group('rollingHash', () {
    test('should compute a deterministic polynomial hash', () {
      // base=31: ((97*31+98)*31+99) % 1e9+7 = 96354 for 'abc'.
      expect(rollingHash('abc', 0, 3), 96354);
    });

    test('should return 0 for an empty range', () {
      expect(rollingHash('abc', 1, 1), 0);
    });

    test('should hash a single character to its code unit', () {
      expect(rollingHash('a', 0, 1), 97);
    });

    test('should hash only the requested sub-range', () {
      // Range [1,3) of 'abc' is 'bc' == hash of 'bc' from a fresh string.
      expect(rollingHash('abc', 1, 3), rollingHash('bc', 0, 2));
    });

    test('should clamp end to the string length', () {
      expect(rollingHash('ab', 0, 10), rollingHash('ab', 0, 2));
    });

    test('should give equal hashes for equal substrings', () {
      expect(rollingHash('xabcx', 1, 4), rollingHash('abc', 0, 3));
    });
  });

  group('rollingHashSearch', () {
    test('should find a pattern in the middle', () {
      expect(rollingHashSearch('hello world', 'world'), 6);
    });

    test('should find a pattern at the start', () {
      expect(rollingHashSearch('hello', 'hel'), 0);
    });

    test('should find the first occurrence', () {
      expect(rollingHashSearch('aaaa', 'aa'), 0);
    });

    test('should return -1 when not found', () {
      expect(rollingHashSearch('hello', 'xyz'), -1);
    });

    test('should return 0 for an empty pattern', () {
      expect(rollingHashSearch('hello', ''), 0);
    });

    test('should return -1 when pattern is longer than text', () {
      expect(rollingHashSearch('ab', 'abcd'), -1);
    });

    test('should match an exact full-length pattern', () {
      expect(rollingHashSearch('abc', 'abc'), 0);
    });

    test('should find a pattern at the end', () {
      expect(rollingHashSearch('abcdef', 'def'), 3);
    });
  });
}
