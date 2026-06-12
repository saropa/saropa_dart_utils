/// Match all (return all matches with groups). Replace with callback. Named group map. Roadmap #190, #191, #193.
/// Audited: 2026-06-12 11:26 EDT
List<RegExpMatch> matchAll(RegExp re, String input) => re.allMatches(input).toList();

/// Replaces every match of [pattern] in [input] with the result of [replace].
///
/// [replace] is called once per match and receives the [Match], letting the
/// replacement depend on captured groups. Returns [input] unchanged when there
/// are no matches.
///
/// Example:
/// ```dart
/// replaceAllWithCallback('a1b2', RegExp(r'\d'), (m) => '[${m[0]}]'); // 'a[1]b[2]'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String replaceAllWithCallback(
  String input,
  RegExp pattern,
  String Function(Match match) replace,
) => input.replaceAllMapped(pattern, replace);

/// Returns the named capture groups of [match] as a map of name to value.
///
/// Only groups that actually captured (non-null) are included, so optional
/// groups that did not participate are omitted. Returns an empty map when the
/// pattern has no named groups.
///
/// Example:
/// ```dart
/// final m = RegExp(r'(?<y>\d{4})').firstMatch('2026')!;
/// namedGroupMap(m); // {'y': '2026'}
/// ```
/// Audited: 2026-06-12 11:26 EDT
Map<String, String> namedGroupMap(RegExpMatch match) {
  final Map<String, String> out = <String, String>{};
  for (final String name in match.groupNames) {
    final String? value = match.namedGroup(name);
    if (value != null) out[name] = value;
  }
  return out;
}
