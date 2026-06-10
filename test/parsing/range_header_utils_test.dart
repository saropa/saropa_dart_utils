import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/range_header_utils.dart';

void main() {
  group('parseRangeHeader', () {
    test('parses an explicit range', () {
      expect(parseRangeHeader('bytes=0-499'), <ByteRange>[const ByteRange(0, 499)]);
    });

    test('parses an open-ended range', () {
      expect(parseRangeHeader('bytes=500-'), <ByteRange>[const ByteRange(500, null)]);
    });

    test('parses a suffix range', () {
      // -500 means the last 500 bytes: no start, end holds the count.
      expect(parseRangeHeader('bytes=-500'), <ByteRange>[const ByteRange(null, 500)]);
    });

    test('parses multiple ranges', () {
      expect(
        parseRangeHeader('bytes=0-499,1000-1499'),
        <ByteRange>[const ByteRange(0, 499), const ByteRange(1000, 1499)],
      );
    });

    test('rejects an unsupported unit', () {
      expect(parseRangeHeader('items=0-1'), isNull);
    });

    test('rejects an empty spec', () {
      expect(parseRangeHeader('bytes='), isNull);
      expect(parseRangeHeader('bytes=,'), isNull);
    });

    test('rejects a non-numeric range', () {
      expect(parseRangeHeader('bytes=abc'), isNull);
    });

    test('rejects start greater than end', () {
      expect(parseRangeHeader('bytes=500-100'), isNull);
    });

    test('ignores surrounding whitespace', () {
      expect(parseRangeHeader('bytes = 0-499'), <ByteRange>[const ByteRange(0, 499)]);
    });
  });
}
