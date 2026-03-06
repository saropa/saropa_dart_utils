/// Diff → colored/HTML/ANSI unified diff renderer (roadmap #402).
library;

import 'myers_diff_utils.dart';

const String _kDiffPrefixSpace = ' ';
const String _kDiffPrefixMinus = '-';
const String _kDiffPrefixPlus = '+';
const String _kColorRed = 'red';
const String _kColorGreen = 'green';
const String _kCssDiffRemove = 'diff-remove';
const String _kCssDiffAdd = 'diff-add';
const String _kCssDiffContext = 'diff-context';
const String _kAmp = '&';
const String _kAmpEsc = '&amp;';
const String _kLt = '<';
const String _kLtEsc = '&lt;';
const String _kGt = '>';
const String _kGtEsc = '&gt;';
const String _kQuot = '"';
const String _kQuotEsc = '&quot;';

/// Format for unified diff output.
enum DiffOutputFormat {
  /// Plain text with +/- prefix (no color).
  plain,

  /// ANSI escape codes for terminal (green add, red remove).
  ansi,

  /// HTML spans with classes (add/remove for styling).
  html,
}

/// Renders a list of [DiffOp] to a unified-diff-style string.
///
/// [ops] is typically from [MyersDiffUtils.diffLines]. [contextLines] is
/// unused for now; reserved for context hunk size.
String renderUnifiedDiff(
  List<DiffOp> ops, {
  DiffOutputFormat format = DiffOutputFormat.plain,
  int contextLines = 3,
}) {
  final StringBuffer out = StringBuffer();
  for (final DiffOp op in ops) {
    final String raw = op.text;
    if (raw.isEmpty) continue;
    final List<String> lines = raw.endsWith('\n')
        ? raw
              .replaceRange(raw.length - 1, raw.length, '')
              .split('\n')
              .map((String l) => '$l\n')
              .toList()
        : raw.split('\n').map((String l) => '$l\n').toList();
    if (!raw.endsWith('\n') && lines.isNotEmpty) {
      lines[lines.length - 1] = lines.last.replaceFirst(RegExp(r'\n$'), '');
    }
    for (final String line in lines) {
      switch (op.kind) {
        case DiffOpKind.equal:
          out.write(_prefix(format, _kDiffPrefixSpace, line, null));
          break;
        case DiffOpKind.delete:
          out.write(_prefix(format, _kDiffPrefixMinus, line, _kColorRed));
          break;
        case DiffOpKind.insert:
          out.write(_prefix(format, _kDiffPrefixPlus, line, _kColorGreen));
          break;
      }
    }
  }
  return out.toString();
}

String _prefix(DiffOutputFormat format, String prefix, String line, String? color) {
  switch (format) {
    case DiffOutputFormat.plain:
      return '$prefix $line';
    case DiffOutputFormat.ansi:
      if (color == _kColorRed) {
        return '\u001b[31m$prefix $line\u001b[0m';
      }
      if (color == _kColorGreen) {
        return '\u001b[32m$prefix $line\u001b[0m';
      }
      return '$prefix $line';
    case DiffOutputFormat.html:
      if (color == _kColorRed) {
        return '<span class="$_kCssDiffRemove">$prefix ${_escapeHtml(line)}</span>';
      }
      if (color == _kColorGreen) {
        return '<span class="$_kCssDiffAdd">$prefix ${_escapeHtml(line)}</span>';
      }
      return '<span class="$_kCssDiffContext">$prefix ${_escapeHtml(line)}</span>';
  }
}

String _escapeHtml(String s) {
  return s
      .replaceAll(_kAmp, _kAmpEsc)
      .replaceAll(_kLt, _kLtEsc)
      .replaceAll(_kGt, _kGtEsc)
      .replaceAll(_kQuot, _kQuotEsc);
}
