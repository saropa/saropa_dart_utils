import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/parsing/changelog_section_utils.dart';

void main() {
  group('parseChangelogSections', () {
    test('single section extracts version and content', () {
      final List<(String, String)> result = parseChangelogSections(
        '## [1.0.0] - 2024-01-01\nAdded feature X.',
      );
      expect(result, hasLength(1));
      expect(result.first.$1, '1.0.0');
      expect(result.first.$2, 'Added feature X.');
    });

    test('multiple sections split at next header', () {
      final List<(String, String)> result = parseChangelogSections(
        '## [2.0.0] - 2024-02-01\nSecond.\n## [1.0.0] - 2024-01-01\nFirst.',
      );
      expect(result, hasLength(2));
      expect(result[0].$1, '2.0.0');
      expect(result[0].$2, 'Second.');
      expect(result[1].$1, '1.0.0');
      expect(result[1].$2, 'First.');
    });

    test('empty string yields empty list', () => expect(parseChangelogSections(''), isEmpty));

    test('no headers yields empty list', () {
      expect(parseChangelogSections('just some text\nwith no headers'), isEmpty);
    });

    test('content trimmed of surrounding whitespace', () {
      final List<(String, String)> result = parseChangelogSections(
        '## [1.0.0]\n\n  body  \n\n',
      );
      expect(result.first.$2, 'body');
    });

    test('header with no content yields empty content', () {
      final List<(String, String)> result = parseChangelogSections('## [1.0.0] - date');
      expect(result, hasLength(1));
      expect(result.first.$1, '1.0.0');
      expect(result.first.$2, '');
    });

    test('ignores headings without bracketed version', () {
      final List<(String, String)> result = parseChangelogSections(
        '## Unreleased\nstuff\n## [1.0.0]\nreal',
      );
      expect(result, hasLength(1));
      expect(result.first.$1, '1.0.0');
    });
  });
}
