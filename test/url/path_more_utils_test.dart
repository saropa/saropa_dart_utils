// ignore_for_file: saropa_lints/prefer_setup_teardown -- per-test arrange kept explicit for readability; a shared setUp would hide each test's inputs
import 'package:flutter_test/flutter_test.dart';
import 'package:saropa_dart_utils/url/path_more_utils.dart';

void main() {
  group('pathDirectory', () {
    test('returns the directory portion of a unix path', () {
      expect(pathDirectory('/usr/local/bin/dart'), '/usr/local/bin');
    });

    test('normalizes backslashes to forward slashes', () {
      expect(pathDirectory(r'C:\temp\file.txt'), 'C:/temp');
    });

    test('returns / for a root-level file', () {
      expect(pathDirectory('/file.txt'), '/');
    });

    test('returns empty for a bare filename with no separator', () {
      expect(pathDirectory('file.txt'), '');
    });
  });

  group('pathBaseName', () {
    test('returns the final segment of a unix path', () {
      expect(pathBaseName('/usr/local/bin/dart'), 'dart');
    });

    test('returns the final segment of a windows path', () {
      expect(pathBaseName(r'C:\temp\file.txt'), 'file.txt');
    });

    test('returns the input unchanged when there is no separator', () {
      expect(pathBaseName('file.txt'), 'file.txt');
    });

    test('returns empty string for a trailing separator', () {
      expect(pathBaseName('/usr/local/'), '');
    });
  });

  group('pathSeparator', () {
    test('is the forward slash', () {
      expect(pathSeparator, '/');
    });
  });

  group('isPathAbsolute', () {
    test('true for a leading-slash path', () {
      expect(isPathAbsolute('/etc/hosts'), isTrue);
    });

    test('true for a windows drive path', () {
      expect(isPathAbsolute(r'C:\Windows'), isTrue);
    });

    test('false for a relative path', () {
      expect(isPathAbsolute('docs/readme.md'), isFalse);
    });

    test('false for an empty string', () {
      expect(isPathAbsolute(''), isFalse);
    });
  });

  group('pathCollapseSeparators', () {
    test('collapses mixed runs of separators to single forward slash', () {
      expect(pathCollapseSeparators(r'a//b\\c'), 'a/b/c');
    });

    test('leaves a single-separator path unchanged', () {
      expect(pathCollapseSeparators('a/b/c'), 'a/b/c');
    });

    test('collapses a long run', () {
      expect(pathCollapseSeparators('a////b'), 'a/b');
    });
  });

  group('pathAppend', () {
    test('joins with a single separator', () {
      expect(pathAppend('docs', 'guide.md'), 'docs/guide.md');
    });

    test('avoids duplicate separator when path ends with slash', () {
      expect(pathAppend('docs/', 'guide.md'), 'docs/guide.md');
    });

    test('keeps a leading separator on the segment when path lacks a trailing one', () {
      expect(pathAppend('docs', '/guide.md'), 'docs/guide.md');
    });

    test('empty segment leaves path unchanged', () {
      expect(pathAppend('docs', ''), 'docs');
    });

    test('normalizes backslashes in both inputs', () {
      expect(pathAppend(r'docs\sub', r'a\b'), 'docs/sub/a/b');
    });
  });

  group('parseBearerToken', () {
    test('extracts the token after the Bearer prefix', () {
      expect(parseBearerToken('Bearer abc123'), 'abc123');
    });

    test('matches the prefix case-insensitively', () {
      expect(parseBearerToken('bearer abc123'), 'abc123');
    });

    test('trims surrounding whitespace', () {
      expect(parseBearerToken('  Bearer   abc123  '), 'abc123');
    });

    test('returns null for a non-bearer scheme', () {
      expect(parseBearerToken('Basic abc123'), isNull);
    });

    test('returns null for an empty header', () {
      expect(parseBearerToken(''), isNull);
    });
  });
}
