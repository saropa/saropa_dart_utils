import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/collections/prefix_frequency_utils.dart';

void main() {
  group('prefixFrequencyTable', () {
    test('should count strings sharing each prefix', () {
      // 'apple','app','apricot' -> a:3, ap:3, app:2, appl:1, apple:1,
      // apr:1, apri:1, apric:1, aprico:1, apricot:1.
      expect(prefixFrequencyTable(['apple', 'app', 'apricot']), {
        'a': 3,
        'ap': 3,
        'app': 2,
        'appl': 1,
        'apple': 1,
        'apr': 1,
        'apri': 1,
        'apric': 1,
        'aprico': 1,
        'apricot': 1,
      });
    });

    test('should return empty map for empty input', () {
      expect(prefixFrequencyTable(<String>[]), <String, int>{});
    });

    test('should count all prefixes of a single string', () {
      expect(prefixFrequencyTable(['cat']), {'c': 1, 'ca': 1, 'cat': 1});
    });

    test('should accumulate counts for identical strings', () {
      expect(prefixFrequencyTable(['ab', 'ab']), {'a': 2, 'ab': 2});
    });

    test('should ignore empty strings (no prefixes)', () {
      expect(prefixFrequencyTable(['', 'a']), {'a': 1});
    });

    test('should cap prefix length at maxPrefixLen', () {
      final Map<String, int> result = prefixFrequencyTable(['abcdef'], maxPrefixLen: 3);
      expect(result.keys.toSet(), {'a', 'ab', 'abc'});
      expect(result.containsKey('abcd'), isFalse);
    });

    test('should produce single-char keys when maxPrefixLen is 1', () {
      expect(prefixFrequencyTable(['hello'], maxPrefixLen: 1), {'h': 1});
    });
  });
}
