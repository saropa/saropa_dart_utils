// ignore_for_file: avoid_print, avoid_synchronous_file_io, avoid_blocking_main_thread, require_platform_check, avoid_print_in_release, avoid_string_substring
// Copyright (c) 2025 Saropa. See LICENSE for details.
//
// Scans Dart files for patterns that can be replaced with saropa_dart_utils.
// Run from project root: dart run tool/suggest_saropa_utils.dart [path]
// Example: dart run tool/suggest_saropa_utils.dart ../my_flutter_app
//
// This is a CLI-only tool; dart:io and sync I/O are intentional.
// Errors go to stderr so stdout is report-only for scripting. Very large
// files (>_maxFileBytes) are skipped to avoid loading generated code.

import 'dart:io';

/// Skip files larger than this to avoid loading huge generated files.
const int _maxFileBytes = 512 * 1024;

void main(List<String> args) {
  final String path = args.isNotEmpty ? args[0] : '.';
  final Directory dir = Directory(path);
  if (!dir.existsSync()) {
    stderr.writeln('Error: path does not exist: $path');
    exit(1);
  }
  final List<Suggestion> suggestions = <Suggestion>[];
  for (final File file in _dartFiles(dir)) {
    if (file.lengthSync() > _maxFileBytes) continue;
    suggestions.addAll(_scanFile(file));
  }
  _printReport(suggestions, path);
}

Iterable<File> _dartFiles(Directory dir) sync* {
  if (!dir.existsSync()) return;
  final List<String> skipDirs = <String>[
    'build',
    '.dart_tool',
    '.git',
    'coverage',
  ];
  for (final FileSystemEntity e in dir.listSync(followLinks: false)) {
    if (e is Directory) {
      if (!skipDirs.contains(e.path.split(Platform.pathSeparator).last)) {
        yield* _dartFiles(e);
      }
    } else if (e is File && e.path.endsWith('.dart')) {
      yield e;
    }
  }
}

List<Suggestion> _scanFile(File file) {
  final List<Suggestion> out = <Suggestion>[];
  final String path = file.path;
  final String content = file.readAsStringSync();
  final List<String> lines = content.split('\n');
  for (final PatternDetector detector in _detectors) {
    for (final RegExpMatch m in detector.pattern.allMatches(content)) {
      final int lineNum = _lineAtOffset(lines, m.start);
      final String line = lineNum <= lines.length ? lines[lineNum - 1] : '';
      out.add(Suggestion(
        path: path,
        line: lineNum,
        snippet: _snippet(line),
        message: detector.message,
      ));
    }
  }
  return out;
}

/// Returns 1-based line number for [offset] (content split by '\n').
int _lineAtOffset(List<String> lines, int offset) {
  int pos = 0;
  for (int i = 0; i < lines.length; i++) {
    pos += lines[i].length + 1;
    if (offset < pos) return i + 1;
  }
  return lines.length;
}

const int _snippetMaxLength = 80;
const int _snippetTruncateAt = 77;

/// Truncates long lines for report display.
String _snippet(String line) {
  final String trimmed = line.trim();
  if (trimmed.length <= _snippetMaxLength) return trimmed;
  return '${trimmed.replaceRange(_snippetTruncateAt, trimmed.length, '')}...';
}

void _printReport(List<Suggestion> suggestions, String path) {
  if (suggestions.isEmpty) {
    print('No suggestions for $path');
    return;
  }
  print('saropa_dart_utils suggestions for $path (${suggestions.length} found)\n');
  String? currentPath;
  for (final Suggestion s in suggestions) {
    if (s.path != currentPath) {
      currentPath = s.path;
      print('$currentPath');
    }
    print('  ${s.line}: ${s.snippet}');
    print('  → ${s.message}\n');
  }
}

final List<PatternDetector> _detectors = <PatternDetector>[
  PatternDetector(
    RegExp(r'(\w+)\s*==\s*null\s*\|\|\s*\1\.isEmpty\b'),
    'Consider: variable.isNullOrEmpty (String? / List? / Map?)',
  ),
  PatternDetector(
    RegExp(r'(\w+)\s*!=\s*null\s*&&\s*\1\.isNotEmpty\b'),
    'Consider: variable.notNullOrEmpty (String?)',
  ),
  PatternDetector(
    RegExp(r'(\w+)\?\.isEmpty\s*\?\?\s*true\b'),
    'Consider: variable.isNullOrEmpty (String?)',
  ),
  PatternDetector(
    RegExp(r'(\w+)\s*\?\?\s*[\x27\x22]{2}\s*[\);,]'),
    'Consider: variable.orEmpty() for String?',
  ),
  PatternDetector(
    RegExp(r'(\w+)\s*\?\?\s*\[\]\s*[\);,]'),
    'Consider: variable.orEmpty() for List? / Map?',
  ),
  PatternDetector(
    RegExp(r'(\w+)\s*\?\?\s*0\s*[\);,]'),
    'Consider: variable.orZero() for int?',
  ),
  PatternDetector(
    RegExp(r'\.toLowerCase\(\)\.contains\s*\([^)]*\.toLowerCase\(\)'),
    'Consider: containsIgnoreCase() from string_search_extensions',
  ),
  PatternDetector(
    RegExp(r'int\.tryParse\s*\([^)]+\)\s*\?\?'),
    'Consider: string.toIntOr(default) from int_string_extensions',
  ),
  PatternDetector(
    RegExp(r'\.substring\s*\(\s*0\s*,[^)]+\)\s*\+\s*[\x27\x22]\.\.\.[\x27\x22]'),
    'Consider: string.truncateWithEllipsis(n)',
  ),
  PatternDetector(
    RegExp(r'if\s*\(\s*\w+\s*!=\s*null\s*\)\s*[^;]*\.add\s*\('),
    'Consider: list.addNotNull(value)',
  ),
  PatternDetector(
    RegExp(r'(\w+)\s*==\s*null\s*\|\|\s*\1\s*==\s*0\b'),
    'Consider: variable.isNullOrZero() for int?',
  ),
  PatternDetector(
    RegExp(r'\?\?\s*DateTime\.now\(\)'),
    'Consider: dateTime.orNow() for DateTime? default to now',
  ),
];

class PatternDetector {
  const PatternDetector(this.pattern, this.message);
  final RegExp pattern;
  final String message;
}

class Suggestion {
  const Suggestion({
    required this.path,
    required this.line,
    required this.snippet,
    required this.message,
  });
  final String path;
  final int line;
  final String snippet;
  final String message;
}
