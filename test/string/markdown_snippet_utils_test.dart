import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/string/markdown_snippet_utils.dart';

void main() {
  // cspell: disable
  group('extractSectionByHeading', () {
    test('should return text under a matching heading', () {
      const String md = '# Intro\nhello\n# Install\nrun it\nnow';
      expect(
        extractSectionByHeading(md, RegExp(r'^#\s+Install')),
        'run it\nnow',
      );
    });

    test('should stop at the next heading', () {
      const String md = '# Install\nstep one\n# Usage\ndo stuff';
      expect(extractSectionByHeading(md, RegExp(r'^#\s+Install')), 'step one');
    });

    test('should return null when heading is not found', () {
      expect(
        extractSectionByHeading('# Other\ntext', RegExp(r'^#\s+Install')),
        isNull,
      );
    });

    test('should return null when section body is empty', () {
      const String md = '# Install\n# Usage';
      expect(extractSectionByHeading(md, RegExp(r'^#\s+Install')), isNull);
    });

    test('should return null for empty input', () {
      expect(extractSectionByHeading('', RegExp(r'^#\s+Install')), isNull);
    });
  });

  group('extractFirstCodeBlock', () {
    test('should extract first fenced block content', () {
      const String md = 'text\n```dart\nfinal x = 1;\n```';
      expect(extractFirstCodeBlock(md), 'final x = 1;');
    });

    test('should extract first when multiple blocks exist', () {
      const String md = '```\nfirst\n```\n```\nsecond\n```';
      expect(extractFirstCodeBlock(md), 'first');
    });

    test('should return null when no fenced block present', () {
      expect(extractFirstCodeBlock('no code'), isNull);
    });

    test('should return null for empty input', () {
      expect(extractFirstCodeBlock(''), isNull);
    });
  });
}
