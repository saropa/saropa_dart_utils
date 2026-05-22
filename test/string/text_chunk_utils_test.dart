import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/text_chunk_utils.dart';

void main() {
  // cspell: disable
  group('chunkText', () {
    test('should split into fixed-size chunks when no periods present', () {
      expect(chunkText('abcdefghij', maxChars: 4), <String>['abcd', 'efgh', 'ij']);
    });

    test('should prefer sentence boundaries within the window', () {
      expect(chunkText('One. Two. Three.', maxChars: 8), <String>['One. Two.', 'Three.']);
    });

    test('should return one chunk when text fits in maxChars', () {
      expect(chunkText('short', maxChars: 100), <String>['short']);
    });

    test('should overlap adjacent chunks by the overlap amount', () {
      expect(chunkText('abcdef', maxChars: 3, overlap: 1), <String>['abc', 'cde', 'ef']);
    });

    test('should return the whole text as one chunk when maxChars < 1', () {
      expect(chunkText('whatever', maxChars: 0), <String>['whatever']);
    });

    test('should return empty list for empty text', () {
      expect(chunkText(''), <String>[]);
    });

    test('should drop chunks that trim to empty', () {
      // Trailing spaces after a sentence break produce a chunk that trims away.
      final List<String> chunks = chunkText('Hi.   ', maxChars: 3);
      expect(chunks, <String>['Hi.']);
    });
  });
}
