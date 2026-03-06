/// Varint encoding/decoding (Protobuf-style) — roadmap #635.
library;

/// Decodes one varint from [bytes] at [start]. Returns (value, nextIndex).
(int value, int next) decodeVarint(List<int> bytes, int start) {
  int value = 0;
  int shift = 0;
  int i = start;
  while (i < bytes.length) {
    final int b = bytes[i++];
    value |= (b & 0x7f) << shift;
    if ((b & 0x80) == 0) return (value, i);
    shift += 7;
    if (shift > 35) break;
  }
  return (value, i);
}

/// Encodes [value] as varint bytes.
List<int> encodeVarint(int value) {
  final List<int> out = [];
  int v = value;
  while (v > 0x7f) {
    out.add((v & 0x7f) | 0x80);
    v >>= 7;
  }
  out.add(v & 0x7f);
  return out;
}
