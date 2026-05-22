import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/code_block_extract_utils.dart';

void main() {
  // cspell: disable
  group('extractFirstCodeBlock', () {
    test('should extract code from a fenced block with language', () {
      const String text = 'before\n```dart\nfinal x = 1;\n```\nafter';
      expect(extractFirstCodeBlock(text), 'final x = 1;');
    });

    test('should extract first block when multiple exist', () {
      const String text = '```\nfirst\n```\n```\nsecond\n```';
      expect(extractFirstCodeBlock(text), 'first');
    });

    test('should trim surrounding whitespace from the code', () {
      const String text = '```\n  spaced  \n```';
      expect(extractFirstCodeBlock(text), 'spaced');
    });

    test('should return null when no fenced block present', () {
      expect(extractFirstCodeBlock('no code here'), isNull);
    });

    test('should return null for empty input', () {
      expect(extractFirstCodeBlock(''), isNull);
    });
  });

  group('extractAllCodeBlocks', () {
    test('should return language and code for each block', () {
      const String text = '```dart\nfinal x = 1;\n```\ntext\n```js\nlet y = 2;\n```';
      expect(
        extractAllCodeBlocks(text),
        <(String, String)>[('dart', 'final x = 1;'), ('js', 'let y = 2;')],
      );
    });

    test('should return empty language string when none specified', () {
      const String text = '```\nplain\n```';
      expect(extractAllCodeBlocks(text), <(String, String)>[('', 'plain')]);
    });

    test('should return empty list when no blocks present', () {
      expect(extractAllCodeBlocks('nothing fenced'), <(String, String)>[]);
    });

    test('should return empty list for empty input', () {
      expect(extractAllCodeBlocks(''), <(String, String)>[]);
    });
  });
}
