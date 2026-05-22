/// Parse hex color string (#RGB, #RRGGBB, #AARRGGBB). Roadmap #152.
/// Returns 0xAARRGGBB or null.
// cspell:ignore RRGGBB AARRGGBB
int? parseHexColor(String input) {
  final String trimmed = input.trim();
  if (!trimmed.startsWith('#')) return null;
  if (trimmed.length < 2) return null;
  final String hex = trimmed.replaceFirst('#', '').replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
  const int hexRadix = 16;
  const int shortHexLength = 3;
  if (hex.length == shortHexLength) {
    // #RGB shorthand expands each nibble by duplication: 'f' -> 'ff', so #f80
    // becomes #ff8800. Matches the CSS three-digit hex expansion rule.
    final int? red = int.tryParse('${hex[0]}${hex[0]}', radix: hexRadix);
    final int? green = int.tryParse('${hex[1]}${hex[1]}', radix: hexRadix);
    final int? blue = int.tryParse('${hex[2]}${hex[2]}', radix: hexRadix);
    if (red == null || green == null || blue == null) return null;
    const int redShift = 16;
    const int greenShift = 8;
    const int alphaMask = 0xFF000000;
    return alphaMask | (red << redShift) | (green << greenShift) | blue;
  }
  const int rgbHexLength = 6;
  if (hex.length == rgbHexLength) {
    // No alpha supplied: prepend opaque 'ff' to form a full AARRGGBB string,
    // then parse the 8-digit value in one pass rather than masking afterward.
    const int defaultAlpha = 0xFF;
    return int.tryParse('${defaultAlpha.toRadixString(hexRadix)}$hex', radix: hexRadix);
  }
  const int argbHexLength = 8;
  if (hex.length == argbHexLength) {
    return int.tryParse(hex, radix: hexRadix);
  }
  return null;
}
