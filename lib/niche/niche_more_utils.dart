import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Niche More: hex dump, parse hex to bytes, bytes to hex, mask card, strip control chars, etc. Roadmap #376-390.
const String _kHexDumpPlaceholder = '   ';

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

List<int> parseHexToBytes(String hex) {
  final String h = hex.replaceAll(RegExp(r'\s'), '');
  if (h.length % 2 != 0) return <int>[];
  final List<int> out = <int>[];
  for (int i = 0; i < h.length; i += 2) {
    final int? b = int.tryParse(h.substringSafe(i, i + 2), radix: 16);
    if (b == null) return <int>[];
    out.add(b);
  }
  return out;
}

String bytesToHex(List<int> bytes) =>
    bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();

String maskCreditCard(String digits, {int visibleLast = 4, String maskChar = '*'}) {
  final String s = digits.replaceAll(RegExp(r'\D'), '');
  if (s.length <= visibleLast) return s;
  return maskChar * (s.length - visibleLast) + s.substringSafe(s.length - visibleLast);
}

String stripControlChars(String s) => s.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

bool isAsciiOnly(String s) => s.codeUnits.every((int c) => c < 128);

String truncateToByteLength(String s, int maxBytes) {
  final List<int> units = s.codeUnits;
  int len = 0;
  for (int i = 0; i < units.length; i++) {
    final int u = units[i];
    int byteCount = 1;
    if (u > 127) {
      if (u > 2047)
        byteCount = 3;
      else
        byteCount = 2;
      if (u > 65535) byteCount = 4;
    }
    if (len + byteCount > maxBytes) return String.fromCharCodes(units.sublist(0, i));
    len += byteCount;
  }
  return s;
}
