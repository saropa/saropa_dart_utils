/// Structured diff of two texts by sentences and by words — roadmap #415.
///
/// Produces a UI-friendly edit script (a list of equal/insert/delete ops in
/// order) rather than a rendered string, so a caller can color, animate, or
/// summarize the changes. The generic [diffSequences] engine is reused for both
/// the word-level and sentence-level conveniences.
library;

import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/tokenize_sentences_utils.dart';

/// The kind of change an edit-script step represents.
enum SeqDiffKind {
  /// The value is present in both inputs (unchanged).
  equal,

  /// The value is present only in the new input (added).
  insert,

  /// The value is present only in the old input (removed).
  delete,
}

/// One step of an edit script: a [kind] and the [value] it applies to.
@immutable
class SeqDiffOp<T> {
  /// Creates an op of [kind] carrying [value].
  const SeqDiffOp(this.kind, this.value);

  /// Whether this value was kept, added, or removed.
  final SeqDiffKind kind;

  /// The unit (word, sentence, or generic element) this op describes.
  final T value;

  @override
  bool operator ==(Object other) =>
      other is SeqDiffOp<T> && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'SeqDiffOp(${kind.name}, $value)';
}

/// Computes the LCS-based edit script that turns [a] into [b]: a list of
/// `equal` / `delete` / `insert` ops in input order. `delete` items appear only
/// in [a], `insert` items only in [b], and the `equal` items are their longest
/// common subsequence. O(n·m) time and space.
List<SeqDiffOp<T>> diffSequences<T>(List<T> a, List<T> b) {
  final int n = a.length;
  final int m = b.length;
  // dp[i][j] = LCS length of a[i..] and b[j..]; computed back-to-front so the
  // forward backtrack below can greedily reconstruct the script.
  final List<List<int>> dp = List<List<int>>.generate(
    n + 1,
    (_) => List<int>.filled(m + 1, 0),
  );
  for (int i = n - 1; i >= 0; i--) {
    for (int j = m - 1; j >= 0; j--) {
      if (a[i] == b[j]) {
        dp[i][j] = dp[i + 1][j + 1] + 1;
      } else {
        final int down = dp[i + 1][j];
        final int right = dp[i][j + 1];
        dp[i][j] = down >= right ? down : right;
      }
    }
  }
  return _backtrack(a, b, dp);
}

List<SeqDiffOp<T>> _backtrack<T>(List<T> a, List<T> b, List<List<int>> dp) {
  // Walk the filled LCS table from the top-left to emit the edit script. On a
  // match, both cursors advance (equal). On a mismatch, follow the larger
  // neighbor: prefer delete when the down cell is at least the right cell,
  // otherwise insert — the tie-break that keeps this consistent with the table.
  final List<SeqDiffOp<T>> ops = <SeqDiffOp<T>>[];
  int i = 0;
  int j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      ops.add(SeqDiffOp<T>(SeqDiffKind.equal, a[i]));
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      ops.add(SeqDiffOp<T>(SeqDiffKind.delete, a[i]));
      i++;
    } else {
      ops.add(SeqDiffOp<T>(SeqDiffKind.insert, b[j]));
      j++;
    }
  }
  // Drain whichever side still has trailing items (pure deletes or inserts).
  for (; i < a.length; i++) {
    ops.add(SeqDiffOp<T>(SeqDiffKind.delete, a[i]));
  }
  for (; j < b.length; j++) {
    ops.add(SeqDiffOp<T>(SeqDiffKind.insert, b[j]));
  }
  return ops;
}

/// Word-level structured diff of [oldText] vs [newText], reusing
/// `tokenizeWords` to split into words (punctuation stripped).
List<SeqDiffOp<String>> diffWords(String oldText, String newText) =>
    diffSequences<String>(tokenizeWords(oldText), tokenizeWords(newText));

/// Sentence-level structured diff of [oldText] vs [newText], reusing
/// `tokenizeSentences` to split on sentence boundaries.
List<SeqDiffOp<String>> diffSentences(String oldText, String newText) =>
    diffSequences<String>(tokenizeSentences(oldText), tokenizeSentences(newText));
