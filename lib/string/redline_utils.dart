/// Line-based redline / track-changes diff generator — roadmap #433.
library;

/// The kind of change a [RedlineEntry] represents.
///
/// [changed] is a remove+add pair at the same position collapsed into one
/// entry, so reviewers see an edit instead of a delete followed by an insert.
enum RedlineOp {
  /// Line is identical in old and new text.
  unchanged,

  /// Line exists only in the new text.
  added,

  /// Line exists only in the old text.
  removed,

  /// Line was replaced: old text differs from new text at this position.
  changed,
}

/// A single line entry in a redline diff.
///
/// [oldLineNo]/[newLineNo] are 1-based and null when the line is absent on that
/// side (added has no old line; removed has no new line). [text] is the new line
/// for added/changed/unchanged, and the old line for removed — so a renderer
/// always has something to show.
///
/// Example:
/// ```dart
/// const RedlineEntry(RedlineOp.added, null, 3, 'inserted');
/// ```
class RedlineEntry {
  /// Creates an immutable redline entry.
  const RedlineEntry(this.op, this.oldLineNo, this.newLineNo, this.text);

  /// What happened to this line.
  final RedlineOp op;

  /// 1-based line number in the old text, or null if the line was added.
  final int? oldLineNo;

  /// 1-based line number in the new text, or null if the line was removed.
  final int? newLineNo;

  /// The line content shown to the reader (new side, or old side if removed).
  final String text;

  @override
  bool operator ==(Object other) =>
      other is RedlineEntry &&
      other.op == op &&
      other.oldLineNo == oldLineNo &&
      other.newLineNo == newLineNo &&
      other.text == text;

  @override
  int get hashCode => Object.hash(op, oldLineNo, newLineNo, text);

  @override
  String toString() {
    // A removed line has no new number and an added line has no old number;
    // render the absent side as '-' rather than the literal 'null'.
    final String oldNo = oldLineNo?.toString() ?? '-';
    final String newNo = newLineNo?.toString() ?? '-';
    return 'RedlineEntry($op, old=$oldNo, new=$newNo, $text)';
  }
}

/// Builds a line-based redline diff aligning unchanged lines via LCS.
///
/// Lines present in both texts (in order) are [RedlineOp.unchanged]; the rest
/// are [RedlineOp.removed]/[RedlineOp.added]. When [pairChanges] is true an
/// adjacent removed+added run is paired index-by-index into [RedlineOp.changed]
/// entries, so a one-line edit reads as a change rather than delete+insert.
///
/// Handles empty, identical, all-added and all-removed inputs.
///
/// Example:
/// ```dart
/// redlineDiff(['a', 'b'], ['a', 'c']); // unchanged a, changed b->c
/// ```
List<RedlineEntry> redlineDiff(
  List<String> oldLines,
  List<String> newLines, {
  bool pairChanges = true,
}) {
  // Walk the LCS table to emit removed/added/unchanged in source order, then
  // optionally collapse adjacent remove+add runs into change entries.
  final List<List<int>> lcs = _lcsTable(oldLines, newLines);
  final List<RedlineEntry> raw = _emitFromLcs(oldLines, newLines, lcs);
  return pairChanges ? _pairAdjacent(raw) : List.unmodifiable(raw);
}

/// Classic dynamic-programming LCS length table over the two line lists.
List<List<int>> _lcsTable(List<String> a, List<String> b) {
  // table[i][j] = LCS length of a[i..] and b[j..]; computed bottom-up so the
  // forward walk in _emitFromLcs can greedily follow the longest path.
  final List<List<int>> table = List.generate(
    a.length + 1,
    (_) => List<int>.filled(b.length + 1, 0),
    growable: false,
  );
  for (int i = a.length - 1; i >= 0; i--) {
    for (int j = b.length - 1; j >= 0; j--) {
      table[i][j] = a[i] == b[j]
          ? table[i + 1][j + 1] + 1
          : _maxInt(table[i + 1][j], table[i][j + 1]);
    }
  }
  return table;
}

int _maxInt(int x, int y) => x > y ? x : y;

/// Emits entries by walking the LCS table from the front.
List<RedlineEntry> _emitFromLcs(List<String> a, List<String> b, List<List<int>> lcs) {
  final List<RedlineEntry> out = <RedlineEntry>[];
  int i = 0;
  int j = 0;
  // At each cell, equal lines are unchanged; otherwise step toward the larger
  // LCS sub-result, emitting a removed (drop from old) or added (take from new).
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      out.add(RedlineEntry(RedlineOp.unchanged, i + 1, j + 1, b[j]));
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      out.add(RedlineEntry(RedlineOp.removed, i + 1, null, a[i]));
      i++;
    } else {
      out.add(RedlineEntry(RedlineOp.added, null, j + 1, b[j]));
      j++;
    }
  }
  // Drain whichever side has trailing lines left.
  while (i < a.length) {
    out.add(RedlineEntry(RedlineOp.removed, i + 1, null, a[i]));
    i++;
  }
  while (j < b.length) {
    out.add(RedlineEntry(RedlineOp.added, null, j + 1, b[j]));
    j++;
  }
  return out;
}

/// Collapses adjacent removed+added runs into [RedlineOp.changed] pairs.
List<RedlineEntry> _pairAdjacent(List<RedlineEntry> raw) {
  final List<RedlineEntry> out = <RedlineEntry>[];
  int i = 0;
  // The LCS walk emits all removeds of a block before its addeds, so a change
  // shows up as a removed run immediately followed by an added run; zip them.
  while (i < raw.length) {
    final RedlineEntry cur = raw[i];
    final RedlineEntry? next = i + 1 < raw.length ? raw[i + 1] : null;
    if (cur.op == RedlineOp.removed && next != null && next.op == RedlineOp.added) {
      out.add(RedlineEntry(RedlineOp.changed, cur.oldLineNo, next.newLineNo, next.text));
      i += 2;
    } else {
      out.add(cur);
      i++;
    }
  }
  return List.unmodifiable(out);
}
