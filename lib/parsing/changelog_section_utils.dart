/// Changelog/semantic version section parser — roadmap #431.
library;

/// Extracts sections like "## [1.0.0] - date" and content until next ##.
/// Audited: 2026-06-12 11:26 EDT
List<(String version, String content)> parseChangelogSections(String changelog) {
  final List<(String, String)> out = <(String, String)>[];
  final RegExp header = RegExp(r'^##\s+\[([^\]]+)\].*$', multiLine: true);
  final List<RegExpMatch> matches = header.allMatches(changelog).toList();
  for (int i = 0; i < matches.length; i++) {
    final String ver = matches[i].group(1) ?? '';
    final int start = matches[i].end;
    final int end = i + 1 < matches.length ? matches[i + 1].start : changelog.length;
    // Plain substring, NOT substringSafe: the offsets come from RegExp matches
    // (UTF-16 code-unit positions), but substringSafe indexes by grapheme
    // cluster, so any emoji/non-BMP content earlier in the changelog would
    // misalign the slice and garble the section body. start..end are valid
    // code-unit bounds within `changelog`, so substring cannot throw here.
    // ignore: avoid_string_substring -- bounds are RegExp match offsets into the same string; in range by construction
    out.add((ver, changelog.substring(start, end).trim()));
  }
  return out;
}
