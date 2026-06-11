import 'package:flutter_test/flutter_test.dart';

// The generator is a script, but its description helpers are public top-level
// functions, so they import cleanly here (main() does not run on import).
import '../../tool/gen_capabilities.dart';

void main() {
  group('firstSentence', () {
    // BUG-002: an inline period inside an abbreviation, backticks, or balanced
    // parentheses must not end the sentence and truncate the example away.
    test('keeps the example after an "e.g." abbreviation', () {
      expect(
        firstSentence('Target false positive rate (e.g. 0.01 for 1%).'),
        'Target false positive rate (e.g. 0.01 for 1%).',
      );
    });

    test('keeps periods inside balanced parentheses', () {
      expect(
        firstSentence('Splits [text] into sentences (split on . ! ?).'),
        'Splits [text] into sentences (split on . ! ?).',
      );
    });

    test('cuts at the first genuine sentence boundary', () {
      expect(
        firstSentence('Normalize path (resolve . and ..). Roadmap #162.'),
        'Normalize path (resolve . and ..).',
      );
    });

    // BUG-003: internal "roadmap #NNN" markers are stripped, whether the marker
    // sits in the first sentence or a trailing one, with no dangling period.
    test('strips a dash-form roadmap ref inside the first sentence', () {
      expect(
        firstSentence('Async barrier: wait for N events — roadmap #676.'),
        'Async barrier: wait for N events.',
      );
    });

    test('drops a trailing roadmap sentence without a dangling period', () {
      expect(
        firstSentence('Cache single async result. Roadmap #180.'),
        'Cache single async result.',
      );
    });

    test('clamps overly long sentences to 160 chars', () {
      final String long = 'A ${'x' * 200} end.';
      final String result = firstSentence(long);
      expect(result.length, lessThanOrEqualTo(160));
      expect(result, endsWith('...'));
    });

    test('returns empty for null doc', () {
      expect(firstSentence(null), '');
    });
  });

  group('sentenceEnd', () {
    test('ignores a dot inside backticks', () {
      expect(
        sentenceEnd('After `. ? !` boundaries it continues here.'),
        'After `. ? !` boundaries it continues here.'.length,
      );
    });

    test('treats a dot after ")" as a real boundary', () {
      expect(sentenceEnd('Ends here (foo). Next.'), 'Ends here (foo).'.length);
    });
  });

  group('stripInternalRefs', () {
    test('removes a bare roadmap ref', () {
      expect(stripInternalRefs('Do a thing roadmap #99'), 'Do a thing');
    });

    test('removes a dash-prefixed roadmap ref', () {
      expect(stripInternalRefs('Do a thing — roadmap #99'), 'Do a thing');
    });
  });
}
