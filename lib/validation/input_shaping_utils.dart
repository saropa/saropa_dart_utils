/// Input shaping: clamp/normalize numbers, trim/limit strings — roadmap #696.
library;

/// Clamps [value] to [min, max], then returns as int if [isInt] else double.
num clampNumber({
  required num value,
  required num min,
  required num max,
  bool isInt = false,
}) {
  final num c = value.clamp(min, max);
  return isInt ? c.round() : c.toDouble();
}

/// Trims [s] and truncates to [maxLength] with optional [ellipsis].
String shapeString(String s, {int? maxLength, String ellipsis = '...'}) {
  String out = s.trim();
  if (maxLength != null && out.length > maxLength) {
    final int trimEnd = (maxLength - ellipsis.length).clamp(0, out.length);
    out = out.replaceRange(trimEnd, out.length, ellipsis);
  }
  return out;
}
