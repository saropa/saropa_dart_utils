// Copyright (c) 2025 Saropa. See LICENSE for details.
//
// Core logic for suggest_saropa_utils: line/offset math, snippet truncation,
// JSON escaping, and pattern scanning. No I/O. Used by the CLI script and
// by unit tests.

/// Result of a single pattern match: file path, 1-based line, snippet, message.
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

/// A regex pattern and the suggestion message when it matches.
class PatternDetector {
  const PatternDetector(this.pattern, this.message);
  final RegExp pattern;
  final String message;
}

/// Returns 1-based line number for [offset] in content represented by [lines]
/// (content split by '\n'). Offsets before 0 are treated as 0; offsets beyond
/// content length return the last line number. Empty [lines] returns 0.
int lineAtOffset(List<String> lines, int offset) {
  if (lines.isEmpty) return 0;
  final int safeOffset = offset < 0 ? 0 : offset;
  int pos = 0;
  for (int i = 0; i < lines.length; i++) {
    pos += lines[i].length + 1;
    if (safeOffset < pos) return i + 1;
  }
  return lines.length;
}

const int snippetMaxLength = 80;
const int snippetTruncateAt = 77;

/// Truncates [line] for report display: trim, then if longer than
/// [snippetMaxLength] characters, cut at [snippetTruncateAt] and append '...'.
String snippet(String line) {
  final String trimmed = line.trim();
  if (trimmed.length <= snippetMaxLength) return trimmed;
  return '${trimmed.replaceRange(snippetTruncateAt, trimmed.length, '')}...';
}

/// Escapes [raw] for use inside a JSON double-quoted string (backslash, quote,
/// control chars, non-ASCII as \\uXXXX).
String jsonString(String raw) {
  final StringBuffer sb = StringBuffer('"');
  for (int i = 0; i < raw.length; i++) {
    final int c = raw.codeUnitAt(i);
    if (c == 0x22)
      sb.write(r'\"');
    else if (c == 0x5c)
      sb.write(r'\\');
    else if (c == 0x0a)
      sb.write(r'\n');
    else if (c == 0x0d)
      sb.write(r'\r');
    else if (c >= 0x20 && c < 0x7f)
      sb.writeCharCode(c);
    else {
      sb.write(r'\u');
      sb.write(c.toRadixString(16).padLeft(4, '0'));
    }
  }
  sb.write('"');
  return sb.toString();
}

/// Scans [content] (full file text) and returns suggestions for [path].
/// [path] is used only in the returned [Suggestion] objects. Same line may
/// appear multiple times if several patterns match.
List<Suggestion> scanContent(String content, String path) {
  final List<Suggestion> out = <Suggestion>[];
  final List<String> lines = content.split('\n');
  for (final PatternDetector detector in detectors) {
    for (final RegExpMatch m in detector.pattern.allMatches(content)) {
      final int lineNum = lineAtOffset(lines, m.start);
      final String lineText = _lineAt(lines, lineNum);
      out.add(
        Suggestion(
          path: path,
          line: lineNum,
          snippet: snippet(lineText),
          message: detector.message,
        ),
      );
    }
  }
  return out;
}

/// Returns the line text for 1-based [lineNum], or empty string if out of range.
String _lineAt(List<String> lines, int lineNum) {
  if (lineNum < 1 || lineNum > lines.length) return '';
  return lines[lineNum - 1];
}

List<PatternDetector> get detectors => _detectors;

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
