import 'package:meta/meta.dart';

/// Indent and dedent for multi-line strings.
extension StringIndentExtensions on String {
  /// Prepends [prefix] to every line (after splitting by newline).
  ///
  /// Line breaks are normalized to `\n` before splitting. [prefix] must not be null.
  /// Returns a new string with each line prefixed.
  ///
  /// Example:
  /// ```dart
  /// 'a\nb'.indentLines('  ');  // '  a\n  b'
  /// ```
  @useResult
  String indentLines(String prefix) {
    if (isEmpty) return this;
    final List<String> lines = split('\n');
    return lines.map((String line) => prefix + line).join('\n');
  }

  /// Removes the common leading whitespace from every line.
  ///
  /// The amount removed is the minimum of leading whitespace lengths (excluding fully blank lines).
  /// Line breaks are normalized to `\n`. Returns a new string with common indent removed.
  ///
  /// Example:
  /// ```dart
  /// '  a\n  b'.dedent();   // 'a\nb'
  /// '  a\n    b'.dedent(); // 'a\n  b'
  /// ```
  @useResult
  String dedent() {
    if (isEmpty) return this;
    final List<String> lines = split('\n');
    // Compute the smallest leading-whitespace width across non-blank lines.
    // Blank lines are skipped because their lead is 0 and would otherwise force
    // the common indent to 0, defeating the dedent.
    int? minLead;
    for (final String line in lines) {
      if (!line.trim().isEmpty) {
        final int lead = line.length - line.trimLeft().length;
        if (minLead == null || lead < minLead) minLead = lead;
      }
    }
    if (minLead == null || minLead == 0) {
      return this;
    }
    final lead = minLead;
    // Strip exactly `lead` chars from each line; shorter lines (blanks/whitespace
    // narrower than the common indent) are left as-is to avoid an index overrun.
    return lines
        .map((String line) => line.length >= lead ? line.replaceRange(0, lead, '') : line)
        .join('\n');
  }
}
