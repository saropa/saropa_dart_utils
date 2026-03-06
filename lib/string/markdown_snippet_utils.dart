/// Markdown snippet extractor (heading sections, first code block) — roadmap #419.
library;

/// Extracts text under first heading matching [headingPattern] (e.g. r'^#\s+Install').
String? extractSectionByHeading(String markdown, RegExp headingPattern) {
  final List<String> lines = markdown.split('\n');
  int start = -1;
  for (int i = 0; i < lines.length; i++) {
    if (headingPattern.hasMatch(lines[i])) {
      start = i + 1;
      break;
    }
  }
  if (start < 0) return null;
  final List<String> out = [];
  for (int i = start; i < lines.length; i++) {
    if (lines[i].trimLeft().startsWith('#')) break;
    out.add(lines[i]);
  }
  return out.join('\n').trim().isEmpty ? null : out.join('\n').trim();
}

/// Returns first fenced code block content or null.
String? extractFirstCodeBlock(String markdown) {
  final RegExp re = RegExp(r'```[\w]*\n([\s\S]*?)```');
  final Match? m = re.firstMatch(markdown);
  return m?.group(1)?.trim();
}
