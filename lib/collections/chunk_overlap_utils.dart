/// Chunk + overlap windows for streaming — roadmap #465.
library;

/// Splits [list] into chunks of [chunkSize] with [overlap] between consecutive chunks.
List<List<T>> chunksWithOverlap<T>(List<T> list, int chunkSize, int overlap) {
  if (chunkSize < 1 || overlap < 0 || overlap >= chunkSize) return list.isEmpty ? [] : [list];
  final List<List<T>> out = [];
  int start = 0;
  while (start < list.length) {
    final int end = (start + chunkSize).clamp(0, list.length);
    out.add(list.sublist(start, end));
    start += chunkSize - overlap;
    if (start >= list.length) break;
  }
  return out;
}
