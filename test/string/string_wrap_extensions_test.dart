import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/string_wrap_extensions.dart';

void main() {
  group('wordWrap', () {
    test('wraps at space', () {
      expect('hello world'.wordWrap(5), ['hello', 'world']);
    });
    test('under width', () {
      expect('hi'.wordWrap(10), ['hi']);
    });
    test('empty', () {
      expect(''.wordWrap(5), <String>[]);
    });
    test('columnWidth 0 throws', () {
      expect(() => 'a'.wordWrap(0), throwsArgumentError);
    });
  });
  group('truncateAtGrapheme', () {
    test('basic', () {
      expect('hello'.truncateAtGrapheme(3), 'hel');
    });
    test('emoji', () {
      expect('hello👋'.truncateAtGrapheme(5), 'hello');
    });
    test('maxGraphemes negative throws', () {
      expect(() => 'a'.truncateAtGrapheme(-1), throwsArgumentError);
    });
  });
  group('preventOrphans', () {
    // Non-breaking space as a Dart escape ON PURPOSE — a raw U+00A0 flattens to
    // ASCII in transit and silently breaks these expectations.
    const String nbsp = '\u{00A0}';
    test('ellipsis is glued to the preceding word', () {
      expect(
        'Importing Demo Companions …'.preventOrphans(),
        'Importing Demo Companions$nbsp…',
      );
    });
    test('any short token in the middle is also glued', () {
      expect(
        'Hello I am here'.preventOrphans(),
        'Hello${nbsp}I${nbsp}am${nbsp}here',
      );
    });
    test('long tokens on both sides keep a breakable space', () {
      expect(
        'Importing Demo Companions'.preventOrphans(),
        'Importing Demo Companions',
      );
    });
    test('single-letter sequence is fully fused', () {
      expect('A B C D'.preventOrphans(), 'A${nbsp}B${nbsp}C${nbsp}D');
    });
    test('trailing 1-char punctuation is always caught', () {
      expect(
        'End of sentence .'.preventOrphans(),
        'End${nbsp}of${nbsp}sentence$nbsp.',
      );
    });
    test('short parenthesized count fuses with preceding word', () {
      expect('Results (5)'.preventOrphans(), 'Results$nbsp(5)');
    });
    test('three-dot ellipsis is short enough to fuse', () {
      expect('Loading ...'.preventOrphans(), 'Loading$nbsp...');
    });
    test('string with no spaces is returned unchanged', () {
      expect('Singleword'.preventOrphans(), 'Singleword');
    });
    test('empty string is returned unchanged', () {
      expect(''.preventOrphans(), '');
    });
    test('single-character string is returned unchanged', () {
      expect('a'.preventOrphans(), 'a');
    });
    test('custom minimum tunes aggressiveness', () {
      expect('fit the box'.preventOrphans(), 'fit${nbsp}the${nbsp}box');
      expect('fit the box'.preventOrphans(minWrapChars: 3), 'fit the box');
      expect(
        'a of b content'.preventOrphans(minWrapChars: 2),
        'a${nbsp}of${nbsp}b${nbsp}content',
      );
    });
    test('consecutive spaces produce an empty token that fuses both sides', () {
      // split(' ') yields ['a', '', 'b']; the empty token (length 0) is below
      // any positive minimum, so both adjoining spaces fuse.
      expect('a  b'.preventOrphans(), 'a$nbsp${nbsp}b');
    });
    test('leading space fuses', () {
      expect(' a'.preventOrphans(), '${nbsp}a');
    });
    test('trailing space fuses', () {
      expect('a '.preventOrphans(), 'a$nbsp');
    });
    test('minWrapChars of 0 fuses nothing', () {
      expect('a b c'.preventOrphans(minWrapChars: 0), 'a b c');
    });
    test('negative minWrapChars fuses nothing', () {
      expect('a b c'.preventOrphans(minWrapChars: -1), 'a b c');
    });
    test('minWrapChars larger than any token fuses everything', () {
      expect(
        'Importing Demo Companions'.preventOrphans(minWrapChars: 100),
        'Importing${nbsp}Demo${nbsp}Companions',
      );
    });
    test('is idempotent', () {
      const String input = 'Hello I am here and Importing Demo Companions …';
      final String once = input.preventOrphans();
      expect(once.preventOrphans(), once);
    });
  });
}
