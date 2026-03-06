/// Match all (return all matches with groups). Replace with callback. Named group map. Roadmap #190, #191, #193.
List<RegExpMatch> matchAll(RegExp re, String input) => re.allMatches(input).toList();

String replaceAllWithCallback(
  String input,
  RegExp pattern,
  String Function(Match match) replace,
) {
  return input.replaceAllMapped(pattern, replace);
}

Map<String, String> namedGroupMap(RegExpMatch match) {
  final Map<String, String> out = <String, String>{};
  for (final String name in match.groupNames) {
    final String? value = match.namedGroup(name);
    if (value != null) out[name] = value;
  }
  return out;
}
