/// Input shaping: clamp/normalize numbers, trim/limit strings — roadmap #696.
library;

/// Clamps [value] to [min, max], then returns as int if [isInt] else double.
/// Audited: 2026-06-12 11:26 EDT
num clampNumber({
  required num value,
  required num min,
  required num max,
  bool isInt = false,
}) {
  final num c = value.clamp(min, max);
  return isInt ? c.round() : c.toDouble();
}

/// Trims [s] and truncates to at most [maxLength] characters with optional
/// [ellipsis]. The result never exceeds [maxLength].
/// Audited: 2026-06-12 11:26 EDT
String shapeString(String s, {int? maxLength, String ellipsis = '...'}) {
  String out = s.trim();
  if (maxLength != null && out.length > maxLength) {
    if (maxLength <= ellipsis.length) {
      // No room for the ellipsis within the budget; hard-truncate so the result
      // still fits maxLength (the old replaceRange could return '...' for
      // maxLength 2, exceeding the requested limit).
      out = out.substring(0, maxLength < 0 ? 0 : maxLength);
    } else {
      out = out.substring(0, maxLength - ellipsis.length) + ellipsis;
    }
  }
  return out;
}
