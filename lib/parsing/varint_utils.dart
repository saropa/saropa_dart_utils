/// Varint encoding/decoding (Protobuf-style) — roadmap #635.
///
/// Platform note: values beyond 32 bits round-trip correctly only on the Dart
/// VM. On the web (dart2js/dartdevc) `int` is a 53-bit double and the shift
/// operators these functions use truncate operands to 32 bits, so encoding or
/// decoding a value above ~2^32 does not reproduce the original. See
/// https://dart.dev/resources/language/number-representation.
library;

/// Decodes one varint from [bytes] at [start]. Returns (value, nextIndex).
/// Audited: 2026-06-12 11:26 EDT
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
    // Bail out once the shift covers a full 64-bit value (10 groups of 7 bits).
    // A 64-bit varint is up to 10 bytes; the previous 35-bit (5-byte) cap
    // truncated any value above 2^35 and broke negative round-trips.
    if (shift >= 64) break;
  }
  return (value, i);
}

/// Encodes [value] as varint bytes.
/// Audited: 2026-06-12 11:26 EDT
List<int> encodeVarint(int value) {
  final List<int> out = <int>[];
  int v = value;
  // Use the mask test `(v & ~0x7f) != 0` and a LOGICAL right shift (`>>>`), not
  // `v > 0x7f` with arithmetic `>>`: a negative value is not `> 0x7f`, so the
  // old loop emitted a single wrong byte and never round-tripped. The unsigned
  // shift feeds zeros from the top, so a negative (two's-complement 64-bit)
  // value encodes to its full 10-byte form that decodeVarint reconstructs.
  while ((v & ~0x7f) != 0) {
    out.add((v & 0x7f) | 0x80);
    v >>>= 7;
  }
  out.add(v & 0x7f);
  return out;
}
