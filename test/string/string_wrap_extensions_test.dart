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
    test('multi-short-word title only fuses the final gap', () {
      // Every earlier gap ("Marked as", "as Out", "Out of") is left as an
      // ordinary breaking space; only "of Date" — the final gap — fuses,
      // because "of" is shorter than the default minimum.
      expect(
        'Marked as Out of Date'.preventOrphans(),
        'Marked as Out of${nbsp}Date',
      );
    });
    test('two-word title fuses its only gap', () {
      expect('Results (5)'.preventOrphans(), 'Results$nbsp(5)');
    });
    test('single word has no gap to fuse', () {
      expect('Singleword'.preventOrphans(), 'Singleword');
    });
    test('empty string is returned unchanged', () {
      expect(''.preventOrphans(), '');
    });
    test('single-character string is returned unchanged', () {
      expect('a'.preventOrphans(), 'a');
    });
    test('long tokens on both sides of the final gap keep a breakable space', () {
      expect(
        'Importing Demo Companions'.preventOrphans(),
        'Importing Demo Companions',
      );
    });
    test('is idempotent', () {
      const String input = 'Marked as Out of Date';
      final String once = input.preventOrphans();
      expect(once.preventOrphans(), once);
    });
    test('trailing space fuses against the empty final token', () {
      expect('a '.preventOrphans(), 'a$nbsp');
    });
    test('custom minimum tunes only the final gap', () {
      // Middle gap ("fit the") is never a candidate under the new rule, only
      // the final one ("the box").
      expect('fit the box'.preventOrphans(), 'fit the${nbsp}box');
      expect('fit the box'.preventOrphans(minWrapChars: 3), 'fit the box');
    });
    test('minWrapChars of 0 fuses nothing', () {
      expect('a b c'.preventOrphans(minWrapChars: 0), 'a b c');
    });
    test('negative minWrapChars fuses nothing', () {
      expect('a b c'.preventOrphans(minWrapChars: -1), 'a b c');
    });
  });
}
