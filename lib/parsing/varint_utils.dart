/// Varint encoding/decoding (Protobuf-style) — roadmap #635.
library;

/// Decodes one varint from [bytes] at [start]. Returns (value, nextIndex).
(int value, int next) decodeVarint(List<int> bytes, int start) {
  int value = 0;
  int shift = 0;
  int i = start;
  // LEB128 / protobuf varint: each byte carries 7 value bits (low) plus a
  // continuation flag in the high bit (0x80). Bytes are little-endian, so each
  // successive group is shifted 7 more bits and OR-ed in; a byte with the high
  // bit clear is the final byte and ends the number.
  while (i < bytes.length) {
    final int b = bytes[i++];
    value |= (b & 0x7f) << shift;
    if ((b & 0x80) == 0) return (value, i);
    shift += 7;
    // Bail out once the shift passes the width a well-formed value should need
    // (~5 bytes): without this, a stream of continuation bytes would shift
    // indefinitely and silently corrupt the result.
    if (shift > 35) break;
  }
  return (value, i);
}

/// Encodes [value] as varint bytes.
List<int> encodeVarint(int value) {
  final List<int> out = <int>[];
  int v = value;
  while (v > 0x7f) {
    out.add((v & 0x7f) | 0x80);
    v >>= 7;
  }
  out.add(v & 0x7f);
  return out;
}
