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

// Every detector below was audited against the real `lib/` public API
// (2026-06-13): the named util EXISTS, and recommending it does NOT degrade the
// code. Excluded on purpose: any `isNullOrX`-style boolean getter on a nullable
// receiver (`isNullOrEmpty`, `isNotNullOrEmpty`, `isNullOrZero`). They read
// tidily but hide the null test from Dart flow analysis, so the receiver is not
// promoted to non-null after the guard and callers are pushed toward `!`. The
// first detector flags their USE and steers back to the explicit form instead.
final List<PatternDetector> _detectors = <PatternDetector>[
  // --- Steer OFF the deprecated null-promotion-defeating getters ---
  PatternDetector(
    RegExp(r'\.(isNullOrEmpty|isNotNullOrEmpty|isNullOrZero)\b'),
    'Deprecated getter: prefer the explicit check (e.g. '
        'x == null || x.isEmpty) which preserves Dart null promotion in the '
        'guarded scope.',
  ),

  // --- String ---
  PatternDetector(
    RegExp(r'(\w+)\[0\]\.toUpperCase\(\)\s*\+\s*\1\.substring\(\s*1\s*\)'),
    'Consider: string.capitalize() from string_case_extensions '
        '(safe on empty strings; the manual form throws on "").',
  ),
  PatternDetector(
    RegExp(r'\.substring\s*\(\s*0\s*,[^)]+\)\s*\+\s*[\x27\x22]\.\.\.[\x27\x22]'),
    'Consider: string.truncateWithEllipsis(n) from string_extensions.',
  ),
  PatternDetector(
    RegExp(r'\.toLowerCase\(\)\.contains\s*\([^)]*\.toLowerCase\(\)'),
    'Consider: string.containsIgnoreCase(other) from string_analysis_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.startsWith\(\s*(\w+)\s*\)\s*\?\s*\1\s*:\s*\2\s*\+\s*\1'),
    'Consider: string.ensurePrefix(prefix) from string_lower_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.endsWith\(\s*(\w+)\s*\)\s*\?\s*\1\s*:\s*\1\s*\+\s*\2'),
    'Consider: string.ensureSuffix(suffix) from string_lower_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.substring\s*\(\s*0\s*,\s*\1\.indexOf\('),
    'Consider: string.getEverythingBefore(find) from '
        'string_manipulation_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.substring\s*\(\s*\1\.indexOf\([^)]*\)\s*\+'),
    'Consider: string.getEverythingAfter(find) from '
        'string_manipulation_extensions.',
  ),
  PatternDetector(
    RegExp(
      r'\.replaceAll\(\s*RegExp\(\s*r?[\x27\x22]\\s\+[\x27\x22]\s*\)\s*,\s*'
      r'[\x27\x22] [\x27\x22]',
    ),
    'Consider: string.compressSpaces() from string_text_extensions.',
  ),
  PatternDetector(
    RegExp(r'\.split\(\s*[\x27\x22] [\x27\x22]\s*\)\.first\b'),
    'Consider: string.firstWord() from string_text_extensions.',
  ),
  PatternDetector(
    RegExp(r'\.split\([^)]*\)\.length\s*-\s*1\b'),
    'Consider: string.countOccurrences(substring) from string_more_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\s*\?\?\s*[\x27\x22]{2}\s*[\);,]'),
    'Consider: string.orEmpty() from string_lower_extensions.',
  ),

  // --- List / Iterable ---
  PatternDetector(
    RegExp(r'\?\?\s*(?:<[^>]*>\s*)?[\[\{]\s*[\]\}]\s*[\);,]'),
    'Consider: list/map.orEmpty() from list_default_empty_extensions.',
  ),
  PatternDetector(
    RegExp(r'if\s*\(\s*(\w+)\s*!=\s*null\s*\)\s*\w+\.add\s*\(\s*\1\s*\)'),
    'Consider: list.addNotNull(value) from list_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.sublist\(\s*\1\.length\s*-'),
    'Consider: iterable.takeLast(n) from iterable_more_extensions '
        '(clamps; the manual sublist throws when n exceeds length).',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.sublist\(\s*0\s*,\s*\1\.length\s*-\s*1\s*\)'),
    'Consider: iterable.dropLast(n) from iterable_more_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.isNotEmpty\s*\?\s*\1\.last\s*:\s*null'),
    'Consider: list.lastOrNull from list_extensions.',
  ),
  PatternDetector(
    RegExp(r'\.where\s*\(\s*\(?(\w+)\)?\s*=>\s*\1\s*!=\s*null\s*\)'),
    'Consider: iterable.whereNotNull() from iterable_map_not_null_extensions.',
  ),
  PatternDetector(
    RegExp(r'\.where\s*\([^)]*\)\.length\b'),
    'Consider: iterable.countWhere(predicate) from iterable_extensions.',
  ),
  PatternDetector(
    RegExp(r'\.any\s*\(\s*\(?(\w+)\)?\s*=>\s*\w+\.contains\s*\(\s*\1\s*\)'),
    'Consider: list.containsAny(other) from list_extensions.',
  ),
  PatternDetector(
    RegExp(r'\.any\s*\(\s*\(?(\w+)\)?\s*=>\s*\w+\.endsWith\s*\(\s*\1\s*\)'),
    'Consider: string.endsWithAny(suffixes) from string_analysis_extensions.',
  ),
  PatternDetector(
    RegExp(r'(\w+)\.isEmpty\s*\?\s*null\s*:\s*\1\b'),
    'Consider: list.nullIfEmpty() from list_extensions.',
  ),

  // --- num / int ---
  PatternDetector(
    RegExp(r'(\w+)\s*<\s*0\s*\?\s*0\s*:\s*\1\b'),
    'Consider: num.clampNonNegative() from num_more_extensions.',
  ),
];
