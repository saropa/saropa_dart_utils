import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/text_fold_utils.dart';

void main() {
  // cspell: disable
  group('splitQuotePrefix', () {
    test('should return empty prefix for an unquoted line', () {
      expect(splitQuotePrefix('hello'), ('', 'hello'));
    });

    test('should split a single-level quote prefix', () {
      expect(splitQuotePrefix('> hello'), ('> ', 'hello'));
    });

    test('should split a nested multi-level quote prefix', () {
      expect(splitQuotePrefix('> > deep'), ('> > ', 'deep'));
    });

    test('should handle a quote marker with no trailing space', () {
      expect(splitQuotePrefix('>tight'), ('>', 'tight'));
    });

    test('should return empty body for a bare prefix line', () {
      expect(splitQuotePrefix('> '), ('> ', ''));
    });
  });

  group('foldText', () {
    test('should leave a short line unchanged', () {
      expect(foldText('hi there', const FoldOptions(width: 40)), 'hi there');
    });

    test('should hard-wrap a long unquoted line at word boundaries', () {
      expect(foldText('aaaa bbbb cccc', const FoldOptions(width: 9)), 'aaaa bbbb\ncccc');
    });

    test('should preserve the quote prefix on each wrapped line', () {
      expect(foldText('> hello world', const FoldOptions(width: 9)), '> hello\n> world');
    });

    test('should preserve a nested quote prefix on continuations', () {
      // avail = 7 - 4 = 3, so each short word lands on its own prefixed line.
      expect(foldText('> > aa bb', const FoldOptions(width: 7)), '> > aa\n> > bb');
    });

    test('should emit an over-wide word on its own line without splitting it', () {
      // The token is longer than the width; emitting it whole avoids an infinite loop.
      expect(foldText('supercalifragilistic', const FoldOptions(width: 5)), 'supercalifragilistic');
    });

    test('should not loop and should keep the long word with its prefix', () {
      expect(
        foldText('> supercalifragilistic', const FoldOptions(width: 5)),
        '> supercalifragilistic',
      );
    });

    test('should pass blank lines through as paragraph separators', () {
      expect(foldText('a b\n\nc d', const FoldOptions(width: 3)), 'a b\n\nc d');
    });

    test('should default to width 78 when no options are given', () {
      const String text = 'short line stays whole';
      expect(foldText(text), text);
    });

    test('should preserve a bare-prefix quote line unchanged', () {
      expect(foldText('> ', const FoldOptions(width: 5)), '> ');
    });
  });

  group('unfoldText', () {
    test('should join soft-wrapped unquoted continuations', () {
      expect(unfoldText('hello\nworld'), 'hello world');
    });

    test('should join continuations that share a quote prefix', () {
      expect(unfoldText('> hello\n> world'), '> hello world');
    });

    test('should keep distinct quote depths on separate lines', () {
      expect(unfoldText('> outer\n> > inner'), '> outer\n> > inner');
    });

    test('should treat blank lines as paragraph boundaries', () {
      expect(unfoldText('a\nb\n\nc\nd'), 'a b\n\nc d');
    });

    test('should round-trip with foldText for a quoted paragraph', () {
      const String original = '> the quick brown fox jumps';
      final String folded = foldText(original, const FoldOptions(width: 12));
      expect(unfoldText(folded), original);
    });

    test('should return a single line unchanged', () {
      expect(unfoldText('just one line'), 'just one line');
    });

    test('should preserve Unicode and emoji content across a join', () {
      expect(unfoldText('> 世界\n> 👋'), '> 世界 👋');
    });
  });
}
