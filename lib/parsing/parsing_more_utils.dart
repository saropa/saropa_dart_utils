import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Parsing More: parse int with base, validate URL/IP, parse port, validate hex, etc. Roadmap #326-335.
int? parseIntBase(String s, int radix) {
  if (radix < 2 || radix > 36) return null;
  return int.tryParse(s, radix: radix);
}

bool isValidUrlLoose(String s) {
  return s.startsWith(RegExp(r'https?://', caseSensitive: false));
}

bool isValidIpv4(String s) {
  final List<String> parts = s.split('.');
  if (parts.length != 4) return false;
  for (final String p in parts) {
    final int? n = int.tryParse(p);
    if (n == null || n < 0 || n > 255) return false;
  }
  return true;
}

int? parsePortFromHostPort(String hostPort) {
  final int colon = hostPort.lastIndexOf(':');
  if (colon == -1) return null;
  return int.tryParse(hostPort.substringSafe(colon + 1));
}

Map<String, String> parseKeyValueLines(String input, {String separator = '='}) {
  final Map<String, String> out = <String, String>{};
  for (final String line in input.split('\n')) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final int i = trimmed.indexOf(separator);
    if (i == -1) continue;
    out[trimmed.substringSafe(0, i).trim()] = trimmed.substringSafe(i + separator.length).trim();
  }
  return out;
}

bool isValidHexString(String s, {int? length}) {
  if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(s)) return false;
  if (length != null && s.length != length) return false;
  return true;
}

List<int> parseDottedDecimal(String s) {
  return s.split('.').map((String x) => int.tryParse(x)).whereType<int>().toList();
}
