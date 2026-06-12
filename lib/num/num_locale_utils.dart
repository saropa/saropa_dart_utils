import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Parse/format number with locale (thousands sep, decimals). Roadmap #138–139.
/// Simple implementation: no full locale data; configurable separators.

/// Parses a number string with optional thousands separator. [decimalSep] default '.', [groupSep] default ','.
/// Audited: 2026-06-12 11:26 EDT
double? parseNumberLocale(
  String input, {
  String decimalSep = '.',
  String groupSep = ',',
}) {
  final String s = input.trim().replaceAll(groupSep, '');
  if (decimalSep != '.') {
    return double.tryParse(s.replaceAll(decimalSep, '.'));
  }
  return double.tryParse(s);
}

/// Formats number with [decimalPlaces] and optional [groupSep] (e.g. ',').
/// Audited: 2026-06-12 11:26 EDT
String formatNumberLocale(
  num value, {
  int decimalPlaces = 0,
  String groupSep = ',',
}) {
  // Render the number first (rounded int, or fixed decimals), then insert group
  // separators into the integer part only.
  final String raw = decimalPlaces <= 0
      ? value.round().toString()
      : value.toStringAsFixed(decimalPlaces);
  if (groupSep.isEmpty) return raw;
  final List<String> parts = raw.split('.');
  final String intPart = parts[0];
  // Peel a leading sign off before grouping so it does not get a separator.
  final String sign = intPart.startsWith('-') ? '-' : '';
  final String digits = sign.isEmpty ? intPart : intPart.substringSafe(1);
  final StringBuffer sb = StringBuffer(sign);
  // Emit a separator every 3 digits counting from the RIGHT (the distance from
  // the end is a multiple of 3), so grouping aligns to thousands regardless of length.
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) sb.write(groupSep);
    sb.write(digits[i]);
  }
  if (parts.length > 1) {
    sb
      ..write('.')
      ..write(parts[1]);
  }
  return sb.toString();
}
