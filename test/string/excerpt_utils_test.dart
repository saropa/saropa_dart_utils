import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/excerpt_utils.dart';

void main() {
  // cspell: disable
  group('excerptAround', () {
    test('should window around the query with ellipses on both clipped edges', () {
      // 'The quick brown fox', query 'brown' at index 10, contextChars 3.
      expect(
        excerptAround('The quick brown fox', 'brown', contextChars: 3),
        '... ck brown fo ...',
      );
    });

    test('should match case-insensitively but preserve source casing', () {
      expect(
        excerptAround('The quick BROWN fox', 'brown', contextChars: 3),
        '... ck BROWN fo ...',
      );
    });

    test('should omit leading ellipsis when window reaches the start', () {
      // query 'The' at index 0; start clamps to 0 so no leading ellipsis.
      final String result = excerptAround('The quick brown fox', 'The', contextChars: 3);
      expect(result.startsWith('...'), isFalse);
      expect(result.startsWith('The'), isTrue);
    });

    test('should omit trailing ellipsis when window reaches the end', () {
      final String result = excerptAround('The quick brown fox', 'fox', contextChars: 3);
      expect(result.endsWith('...'), isFalse);
      expect(result.endsWith('fox'), isTrue);
    });

    test('should return empty string for empty text', () {
      expect(excerptAround('', 'x'), '');
    });

    test('should return full short text when query is empty', () {
      expect(excerptAround('short', ''), 'short');
    });

    test('should head/tail truncate short-context with empty query', () {
      // Long text, empty query, small context -> first+ellipsis+last.
      expect(
        excerptAround('abcdefghij', '', contextChars: 2),
        'ab...ij',
      );
    });

    test('should return full short text when query not found', () {
      expect(excerptAround('short', 'zzz'), 'short');
    });

    test('should head/tail truncate long text when query not found', () {
      expect(
        excerptAround('abcdefghij', 'zzz', contextChars: 2),
        'ab...ij',
      );
    });

    test('should use a custom ellipsis string', () {
      expect(
        excerptAround('abcdefghij', '', contextChars: 2, ellipsis: '~'),
        'ab~ij',
      );
    });
  });
}
