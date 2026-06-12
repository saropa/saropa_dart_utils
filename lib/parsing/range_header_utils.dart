/// Parse an HTTP `Range` request header (`bytes=` unit only). Roadmap #160.
///
/// Supports the forms a server needs for partial content: `bytes=0-499`
/// (explicit), `bytes=500-` (open-ended, to end of resource), `bytes=-500`
/// (suffix, last N bytes), and comma-separated multi-range. Only the `bytes`
/// unit is recognized; any other unit or a malformed spec yields `null` so the
/// caller can answer `416 Range Not Satisfiable` instead of guessing.
library;

/// One requested byte range. Exactly one of [start]/[end] may be null:
/// - `start..end`  → both set (e.g. `0-499`).
/// - `start..`     → [end] null, meaning "to the end of the resource".
/// - suffix length → [start] null, [end] holds the number of trailing bytes
///   requested (e.g. `-500` → last 500 bytes).
class ByteRange {
  /// Creates a byte range from [start] and [end]; see the class doc for how a
  /// null in either position encodes an open-ended or suffix range.
  /// Audited: 2026-06-12 11:26 EDT
  const ByteRange(this.start, this.end);

  /// First byte offset (inclusive), or null for a suffix-length range.
  final int? start;

  /// Last byte offset (inclusive), or null for an open-ended range; for a
  /// suffix range it is the count of trailing bytes.
  final int? end;

  @override
  bool operator ==(Object other) => other is ByteRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// Parses [header] (e.g. `bytes=0-499,1000-`) into byte ranges, or `null` if
/// the unit is not `bytes` or any range is malformed.
///
/// A range is malformed when it has no digits on either side, when both bounds
/// are present but `start > end`, or when a number fails to parse. An empty
/// range list (e.g. `bytes=`) is also `null`.
///
/// Example:
/// ```dart
/// parseRangeHeader('bytes=0-499');  // [ByteRange(0, 499)]
/// parseRangeHeader('bytes=-500');   // [ByteRange(null, 500)] (last 500 bytes)
/// parseRangeHeader('bytes=500-');   // [ByteRange(500, null)] (offset 500 to end)
/// parseRangeHeader('items=0-1');    // null (unsupported unit)
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<ByteRange>? parseRangeHeader(String header) {
  final int eq = header.indexOf('=');
  if (eq < 0) {
    return null;
  }
  // eq is an in-range index from indexOf, so both substrings below are bounded:
  // [0, eq) for the unit and [eq + 1, length) for the spec.
  // ignore: avoid_string_substring -- eq provably within length (indexOf + guard)
  final String unit = header.substring(0, eq).trim().toLowerCase();
  if (unit != 'bytes') {
    return null;
  }

  // ignore: avoid_string_substring -- eq + 1 <= length (eq is a valid index)
  final String spec = header.substring(eq + 1).trim();
  if (spec.isEmpty) {
    return null;
  }

  final List<ByteRange> ranges = <ByteRange>[];
  for (final String raw in spec.split(',')) {
    final ByteRange? range = _parseRange(raw.trim());
    if (range == null) {
      // One bad sub-range invalidates the whole header per RFC 7233.
      return null;
    }
    ranges.add(range);
  }
  return ranges.isEmpty ? null : ranges;
}

/// Parses one `a-b`, `a-`, or `-b` token into a [ByteRange], or `null`.
/// Audited: 2026-06-12 11:26 EDT
ByteRange? _parseRange(String token) {
  final int dash = token.indexOf('-');
  if (dash < 0) {
    return null;
  }

  final String startText = token.substring(0, dash).trim();
  final String endText = token.substring(dash + 1).trim();

  // Suffix range "-N": no start, end carries the trailing-byte count.
  if (startText.isEmpty) {
    final int? suffix = int.tryParse(endText);
    if (suffix == null || suffix < 0) {
      return null;
    }
    return ByteRange(null, suffix);
  }

  final int? start = int.tryParse(startText);
  if (start == null || start < 0) {
    return null;
  }

  // Open-ended range "N-": start set, no end.
  if (endText.isEmpty) {
    return ByteRange(start, null);
  }

  final int? end = int.tryParse(endText);
  if (end == null || end < start) {
    return null;
  }
  return ByteRange(start, end);
}
