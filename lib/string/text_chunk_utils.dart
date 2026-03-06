/// Text segmentation into chunks for indexing (size and sentence boundaries) — roadmap #430.
library;

import 'string_extensions.dart';

/// Splits [text] into chunks of at most [maxChars] characters, trying to break
/// at sentence boundaries (.). [overlap] optional characters to overlap between chunks.
List<String> chunkText(String text, {int maxChars = 500, int overlap = 0}) {
  if (text.isEmpty) return <String>[];
  if (maxChars < 1) return <String>[text];
  final int maxPossibleChunks = text.length + 1;
  final List<String> chunks = List<String>.filled(maxPossibleChunks, '');
  int chunkIndex = 0;
  int start = 0;
  while (start < text.length) {
    int end = (start + maxChars).clamp(0, text.length);
    if (end < text.length) {
      final int lastPeriod = text.lastIndexOf('.', end);
      if (lastPeriod > start) end = lastPeriod + 1;
    }
    final int safeStart = start.clamp(0, text.length);
    final int safeEnd = end.clamp(0, text.length);
    chunks[chunkIndex++] = text.substringSafe(safeStart, safeEnd).trim();
    start = end;
    if (overlap > 0 && start < text.length) start = (start - overlap).clamp(0, text.length);
  }
  return chunks.sublist(0, chunkIndex).where((String c) => c.isNotEmpty).toList();
}
