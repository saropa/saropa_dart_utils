/// Human name parser (first/middle/last/suffix) — roadmap #409.
library;

/// Parsed name parts.
class HumanNameParserUtils {
  const HumanNameParserUtils({String? first, String? middle, String? last, String? suffix})
    : _first = first,
      _middle = middle,
      _last = last,
      _suffix = suffix;
  final String? _first;

  String? get first => _first;
  final String? _middle;

  String? get middle => _middle;
  final String? _last;

  String? get last => _last;
  final String? _suffix;

  String? get suffix => _suffix;

  @override
  String toString() =>
      'HumanNameParserUtils(first: ${_first ?? ""}, middle: ${_middle ?? ""}, last: ${_last ?? ""}, suffix: ${_suffix ?? ""})';
}

/// Simple split: "Last, First Middle" or "First Middle Last". Suffix: Jr., Sr., III, etc.
HumanNameParserUtils parseHumanName(String full) {
  final String s = full.trim();
  if (s.isEmpty) return const HumanNameParserUtils();
  final RegExp suffixRe = RegExp(r',?\s+(Jr\.?|Sr\.?|III?|IV|II|I)$', caseSensitive: false);
  final String? suffix = suffixRe.firstMatch(s)?.group(1);
  String rest = s.replaceAll(suffixRe, '').trim();
  if (rest.contains(',')) {
    final List<String> parts = rest.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 2) {
      return HumanNameParserUtils(
        last: parts[0],
        first: parts[1],
        middle: parts.length > 2 ? parts[2] : null,
        suffix: suffix,
      );
    }
  }
  final List<String> tokens = rest.split(RegExp(r'\s+'));
  if (tokens.isEmpty) return HumanNameParserUtils(suffix: suffix);
  if (tokens.length == 1) return HumanNameParserUtils(first: tokens[0], suffix: suffix);
  return HumanNameParserUtils(
    first: tokens[0],
    last: tokens[tokens.length - 1],
    middle: tokens.length > 2 ? tokens.sublist(1, tokens.length - 1).join(' ') : null,
    suffix: suffix,
  );
}
