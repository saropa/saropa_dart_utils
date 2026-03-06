import 'dart:math';
import 'dart:typed_data';

// UUID v4 layout: 16 bytes; version nibble in byte 6, variant in byte 8; hex is 32 chars.
const int _uuidByteCount = 16;
const int _byteMaxExclusive = 256;
const int _versionNibbleMask = 0x0F;
const int _versionNibbleValue = 0x40;
const int _variantMask = 0x3F;
const int _variantValue = 0x80;
const int _hexDigitsPerByte = 2;
const String _hexPadChar = '0';
const int _hexSegment1End = 8;
const int _hexTotalLength = 32;
const int _hexSegment2Start = 0;
const int _hexSegment2End = 8;
const int _hexSegment2PartLen = 4;
const int _hexSegment2DropEnd = 24;
const int _hexSegment3Start = 0;
const int _hexSegment3End = 12;
const int _hexSegment3PartLen = 4;
const int _hexSegment3DropEnd = 20;
const int _hexSegment4Start = 0;
const int _hexSegment4End = 16;
const int _hexSegment4PartLen = 4;
const int _hexSegment4DropEnd = 16;
const int _hexSegment5Start = 0;
const int _hexSegment5End = 20;

/// Generate random UUID v4. Roadmap #228.
String generateUuidV4() {
  final Random random = Random.secure();
  final Uint8List bytes = Uint8List(_uuidByteCount);
  for (int i = 0; i < _uuidByteCount; i++) {
    bytes[i] = random.nextInt(_byteMaxExclusive);
  }
  bytes[6] = (bytes[6] & _versionNibbleMask) | _versionNibbleValue;
  bytes[8] = (bytes[8] & _variantMask) | _variantValue;
  final String hex = bytes
      .map((int b) => b.toRadixString(16).padLeft(_hexDigitsPerByte, _hexPadChar))
      .join();
  final segment1 = hex.replaceRange(_hexSegment1End, _hexTotalLength, '');
  final segment2 = hex
      .replaceRange(_hexSegment2Start, _hexSegment2End, '')
      .replaceRange(_hexSegment2PartLen, _hexSegment2DropEnd, '');
  final segment3 = hex
      .replaceRange(_hexSegment3Start, _hexSegment3End, '')
      .replaceRange(_hexSegment3PartLen, _hexSegment3DropEnd, '');
  final segment4 = hex
      .replaceRange(_hexSegment4Start, _hexSegment4End, '')
      .replaceRange(_hexSegment4PartLen, _hexSegment4DropEnd, '');
  final segment5 = hex.replaceRange(_hexSegment5Start, _hexSegment5End, '');
  return '$segment1-$segment2-$segment3-$segment4-$segment5';
}
