/// Changelog/semantic version section parser — roadmap #431.
library;

import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Extracts sections like "## [1.0.0] - date" and content until next ##.
List<(String version, String content)> parseChangelogSections(String changelog) {
  final List<(String, String)> out = [];
  final RegExp header = RegExp(r'^##\s+\[([^\]]+)\].*$', multiLine: true);
  final List<RegExpMatch> matches = header.allMatches(changelog).toList();
  for (int i = 0; i < matches.length; i++) {
    final String ver = matches[i].group(1) ?? '';
    final int start = matches[i].end;
    final int end = i + 1 < matches.length ? matches[i + 1].start : changelog.length;
    out.add((ver, changelog.substringSafe(start, end).trim()));
  }
  return out;
}
