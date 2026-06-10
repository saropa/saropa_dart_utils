/// Chunk + overlap windows for streaming — roadmap #465.
library;

/// Splits [list] into chunks of [chunkSize] with [overlap] between consecutive chunks.
List<List<T>> chunksWithOverlap<T>(List<T> list, int chunkSize, int overlap) {
  // Guard nonsensical parameters (overlap must be smaller than the chunk, or the
  // window could never advance): degrade to a single chunk of the whole list.
  if (chunkSize < 1 || overlap < 0 || overlap >= chunkSize) {
    return list.isEmpty ? <List<T>>[] : [list];
  }
  final List<List<T>> out = <List<T>>[];
  int start = 0;
  while (start < list.length) {
    final int end = (start + chunkSize).clamp(0, list.length);
    out.add(list.sublist(start, end));
    // Advance by stride = chunkSize - overlap so consecutive chunks share
    // `overlap` trailing/leading elements.
    start += chunkSize - overlap;
    if (start >= list.length) break;
  }
  return out;
}
