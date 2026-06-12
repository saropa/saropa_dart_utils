import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Niche More: hex dump, parse hex to bytes, bytes to hex, mask card, strip control chars, etc. Roadmap #376-390.
const String _kHexDumpPlaceholder = '   ';

/// Renders [bytes] as a classic hex dump: offset, hex columns, and ASCII gutter.
///
/// Each line covers [bytesPerLine] bytes. Non-printable bytes (outside
/// `0x20`–`0x7E`) appear as `.` in the ASCII column.
///
/// Example:
/// ```dart
/// hexDump([72, 105]); // '00000000 48 69 ... Hi'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String hexDump(List<int> bytes, {int bytesPerLine = 16}) {
  final StringBuffer sb = StringBuffer();
  for (int i = 0; i < bytes.length; i += bytesPerLine) {
    sb.write(i.toRadixString(16).padLeft(8, '0'));
    for (int j = 0; j < bytesPerLine; j++) {
      if (i + j < bytes.length) {
        sb.write(' ${bytes[i + j].toRadixString(16).padLeft(2, '0')}');
      } else {
        sb.write(_kHexDumpPlaceholder);
      }
    }
    sb.write('  ');
    for (int j = 0; j < bytesPerLine && i + j < bytes.length; j++) {
      final int byteVal = bytes[i + j];
      sb.writeCharCode(byteVal >= 32 && byteVal < 127 ? byteVal : 0x2E);
    }
    sb.writeln();
  }
  return sb.toString();
}

/// Parses a [hex] string into its byte values.
///
/// Whitespace is ignored. Returns an empty list if the cleaned input has an
/// odd length or contains a non-hex pair.
///
/// Example:
/// ```dart
/// parseHexToBytes('48 69'); // [72, 105]
/// ```
/// Audited: 2026-06-12 11:26 EDT
List<int> parseHexToBytes(String hex) {
  final String h = hex.replaceAll(RegExp(r'\s'), '');
  if (h.length % 2 != 0) return <int>[];
  final List<int> out = <int>[];
  // ignore: saropa_lints/prefer_correct_for_loop_increment -- steps by 2 to consume each hex byte (two chars) per iteration
  for (int i = 0; i < h.length; i += 2) {
    final int? b = int.tryParse(h.substringSafe(i, i + 2), radix: 16);
    if (b == null) return <int>[];
    out.add(b);
  }
  return out;
}

/// Returns the lowercase, zero-padded hex string for [bytes], with no separators.
///
/// Example:
/// ```dart
/// bytesToHex([72, 105]); // '4869'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String bytesToHex(List<int> bytes) =>
    bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();

/// Masks all but the last [visibleLast] digits of [digits] with [maskChar].
///
/// Non-digit characters are stripped first. If the digit count is at most
/// [visibleLast], the digits are returned unmasked.
///
/// Example:
/// ```dart
/// maskCreditCard('4111 1111 1111 1234'); // '************1234'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String maskCreditCard(String digits, {int visibleLast = 4, String maskChar = '*'}) {
  final String s = digits.replaceAll(RegExp(r'\D'), '');
  if (s.length <= visibleLast) return s;
  return maskChar * (s.length - visibleLast) + s.substringSafe(s.length - visibleLast);
}

/// Removes ASCII control characters (`0x00`–`0x1F` and `0x7F`) from [s].
///
/// Printable characters and Unicode above the control range are preserved.
/// Audited: 2026-06-12 11:26 EDT
String stripControlChars(String s) => s.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

/// Returns `true` if every code unit in [s] is within the ASCII range (`< 128`).
///
/// An empty string returns `true`.
/// Audited: 2026-06-12 11:26 EDT
bool isAsciiOnly(String s) => s.codeUnits.every((int c) => c < 128);

/// Truncates [s] so its UTF-8 encoding does not exceed [maxBytes] bytes.
///
/// Cuts only at code-unit boundaries, so a multi-byte character that would
/// overflow [maxBytes] is dropped whole rather than split.
///
/// Example:
/// ```dart
/// truncateToByteLength('héllo', 3); // 'hé' (é is 2 bytes)
/// ```
/// Audited: 2026-06-12 11:26 EDT
String truncateToByteLength(String s, int maxBytes) {
  // Iterate RUNES (code points), not codeUnits: a non-BMP character (emoji) is
  // two UTF-16 surrogates, each of which the old code counted as 3 bytes (6
  // total) instead of its true 4, and `sublist` could split between the two
  // surrogates, yielding an invalid string. Runes give the real code point and
  // a safe cut boundary.
  final StringBuffer out = StringBuffer();
  int len = 0;
  for (final int rune in s.runes) {
    final int byteCount = _utf8ByteLength(rune);
    if (len + byteCount > maxBytes) break;
    out.writeCharCode(rune);
    len += byteCount;
  }
  return out.toString();
}

/// UTF-8 byte length of a single Unicode code point.
/// Audited: 2026-06-12 11:26 EDT
int _utf8ByteLength(int rune) {
  if (rune <= 0x7F) return 1;
  if (rune <= 0x7FF) return 2;
  if (rune <= 0xFFFF) return 3;
  return 4;
}
