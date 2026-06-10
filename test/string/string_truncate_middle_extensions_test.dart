import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_truncate_middle_extensions.dart';

void main() {
  group('truncateMiddle', () {
    test('elides the middle and keeps both ends', () {
      const String path = '/Users/craig/projects/report.pdf';
      final String result = path.truncateMiddle(20);
      // keep = 20 - 1 (ellipsis) = 19 => front 10, back 9.
      expect(result, hasLength(20));
      expect(result.startsWith('/Users/cra'), isTrue);
      expect(result.endsWith('eport.pdf'), isTrue);
      expect(result.contains('…'), isTrue);
    });

    test('returns original when it already fits', () {
      expect('abcdef'.truncateMiddle(10), 'abcdef');
    });

    test('returns original when equal to maxLength', () {
      expect('abcdef'.truncateMiddle(6), 'abcdef');
    });

    test('returns original for null maxLength', () {
      expect('abcdef'.truncateMiddle(null), 'abcdef');
    });

    test('returns original for non-positive maxLength', () {
      expect('abcdef'.truncateMiddle(0), 'abcdef');
      expect('abcdef'.truncateMiddle(-3), 'abcdef');
    });

    test('biases the extra kept cluster to the front for odd budgets', () {
      // maxLength 6, ellipsis 1 => keep 5 => front 3, back 2.
      expect('abcdefgh'.truncateMiddle(6), 'abc…gh');
    });

    test('falls back to a leading cut when too small for a middle elision', () {
      // keep would be < 2, so degrade to leading clusters within maxLength.
      expect('abcdefgh'.truncateMiddle(2), 'ab');
    });

    test('supports a custom ellipsis', () {
      final String result = 'abcdefghij'.truncateMiddle(7, ellipsis: '...');
      expect(result, hasLength(7));
      expect(result.contains('...'), isTrue);
    });

    test('never splits a grapheme cluster (emoji stay whole)', () {
      // Family emoji is one cluster built from several code points.
      const String s = 'start👨‍👩‍👧‍👦end-of-the-string';
      final String result = s.truncateMiddle(12);
      // Either the whole family emoji is present or none of its pieces are.
      final bool whole = result.contains('👨‍👩‍👧‍👦');
      final bool absent = !result.contains('👨') && !result.contains('👧');
      expect(whole || absent, isTrue);
    });
  });
}
