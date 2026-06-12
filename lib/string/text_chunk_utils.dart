/// Text segmentation into chunks for indexing (size and sentence boundaries) — roadmap #430.
library;

import 'string_extensions.dart';

/// Splits [text] into chunks of at most [maxChars] characters, trying to break
/// at sentence boundaries (.). [overlap] optional characters to overlap between chunks.
/// Audited: 2026-06-12 11:26 EDT
List<String> chunkText(String text, {int maxChars = 500, int overlap = 0}) {
  if (text.isEmpty) return <String>[];
  if (maxChars < 1) return <String>[text];
  final int maxPossibleChunks = text.length + 1;
  final List<String> chunks = List<String>.filled(maxPossibleChunks, '');
  int chunkIndex = 0;
  int start = 0;
  while (start < text.length) {
    int end = (start + maxChars).clamp(0, text.length);
    // Prefer a sentence boundary: pull `end` back to the last period within the
    // window so chunks split between sentences rather than mid-sentence. Require
    // lastPeriod > start so we never produce an empty/backward chunk when the
    // only period sits at or before the chunk start.
    if (end < text.length) {
      final int lastPeriod = text.lastIndexOf('.', end);
      if (lastPeriod > start) end = lastPeriod + 1;
    }
    final int chunkStart = start;
    final int safeStart = start.clamp(0, text.length);
    final int safeEnd = end.clamp(0, text.length);
    chunks[chunkIndex++] = text.substringSafe(safeStart, safeEnd).trim();
    // Advance to `end`, then (only when more text remains) rewind by `overlap`
    // so adjacent chunks share trailing context for search/embedding. Force at
    // least one char of forward progress past THIS chunk's start: with
    // `overlap >= maxChars` the rewind would otherwise land at or before
    // `chunkStart`, looping forever and overflowing the pre-sized `chunks` list.
    start = end;
    if (overlap > 0 && start < text.length) {
      final int rewound = end - overlap;
      start = rewound <= chunkStart ? chunkStart + 1 : rewound.clamp(0, text.length);
    }
  }
  return chunks.sublist(0, chunkIndex).where((String c) => c.isNotEmpty).toList();
}
