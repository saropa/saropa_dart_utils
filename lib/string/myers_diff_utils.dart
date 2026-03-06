/// Myers diff for strings: minimal edit script (roadmap #401).
///
/// Tree-shakeable: import only this file if you need diff ops.
library;

import 'string_extensions.dart';

/// Kind of diff operation in an edit script.
enum DiffOpKind {
  /// Line (or segment) is unchanged in both inputs.
  equal,

  /// Line exists only in the "new" (right) text — insert into old to get new.
  insert,

  /// Line exists only in the "old" (left) text — delete from old to get new.
  delete,
}

/// Myers-style minimal edit script between two strings (line-based).
///
/// Splits [oldText] and [newText] by newlines, computes a minimal edit script,
/// and returns a list of [DiffOp] (equal, insert, delete). Merges adjacent
/// ops of the same kind so each [DiffOp] can span multiple lines.
///
/// Example:
/// ```dart
/// final script = MyersDiffUtils.diffLines('a\nb\nc', 'a\nx\nc');
/// // [Equal('a\n'), Delete('b\n'), Insert('x\n'), Equal('c')] (conceptually)
/// ```
abstract final class MyersDiffUtils {
  static List<DiffOp> diffLines(String oldText, String newText) {
    final List<String> a = _splitLines(oldText);
    final List<String> b = _splitLines(newText);
    final List<_Edit> raw = _myers(a: a, b: b);
    return _mergeOps(edits: raw, a: a, b: b);
  }

  static List<String> _splitLines(String s) {
    if (s.isEmpty) return <String>[];
    final List<String> out = <String>[];
    int start = 0;
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '\n') {
        final int end = (i + 1).clamp(0, s.length);
        out.add(s.substringSafe(start, end));
        start = i + 1;
      }
    }
    if (start < s.length) out.add(s.substringSafe(start.clamp(0, s.length)));
    return out;
  }

  MyersDiffUtils._();
}

/// A single operation in a minimal edit script.
///
/// For line-based diff, [text] is one or more lines (may include newline).
/// Adjacent equal/insert/delete ops with the same kind are merged
/// so that [text] can represent a multi-line segment.
class DiffOp {
  const DiffOp(DiffOpKind kind, String text) : _kind = kind, _text = text;

  final DiffOpKind _kind;

  /// The kind of edit (equal, insert, or delete).
  DiffOpKind get kind => _kind;
  final String _text;

  /// The segment text for this operation.
  String get text => _text;

  @override
  String toString() => 'DiffOp($_kind, ${_text.length} chars)';
}

class _Edit {
  const _Edit(DiffOpKind kind, int indexA, int indexB)
    : _kind = kind,
      _indexA = indexA,
      _indexB = indexB;
  final DiffOpKind _kind;
  final int _indexA;
  final int _indexB;

  @override
  String toString() => '_Edit($_kind, indexA: $_indexA, indexB: $_indexB)';
}

List<_Edit> _myers({required List<String> a, required List<String> b}) {
  final int n = a.length;
  final int m = b.length;
  final List<List<int>> dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));
  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
      }
    }
  }
  int i = n;
  int j = m;
  final List<_Edit> edits = <_Edit>[];
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && a[i - 1] == b[j - 1]) {
      edits.add(_Edit(DiffOpKind.equal, i - 1, j - 1));
      i--;
      j--;
    } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
      edits.add(_Edit(DiffOpKind.insert, i, j - 1));
      j--;
    } else {
      edits.add(_Edit(DiffOpKind.delete, i - 1, j));
      i--;
    }
  }
  return List<_Edit>.of(edits.reversed);
}

List<DiffOp> _mergeOps({
  required List<_Edit> edits,
  required List<String> a,
  required List<String> b,
}) {
  final List<DiffOp> result = List.filled(edits.length, DiffOp(DiffOpKind.equal, ''));
  int resultIndex = 0;
  final StringBuffer buf = StringBuffer();
  int idx = 0;
  while (idx < edits.length) {
    final DiffOpKind k = edits[idx]._kind;
    buf.clear();
    int i = idx;
    while (i < edits.length && edits[i]._kind == k) {
      if (k == DiffOpKind.equal) {
        buf.write(a[edits[i]._indexA]);
      } else if (k == DiffOpKind.insert) {
        buf.write(b[edits[i]._indexB]);
      } else {
        buf.write(a[edits[i]._indexA]);
      }
      i++;
    }
    result[resultIndex++] = DiffOp(k, buf.toString());
    idx = i;
  }
  return result.sublist(0, resultIndex);
}
