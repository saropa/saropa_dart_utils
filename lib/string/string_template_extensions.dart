import 'package:meta/meta.dart';

/// Extensions for simple template substitution in strings (e.g. `Hello {{name}}`).
extension StringTemplateExtensions on String {
  /// Replaces placeholders of the form `{{key}}` with values from [variables].
  ///
  /// Keys are matched case-sensitively. If a key is missing in [variables],
  /// the placeholder is left unchanged. [variables] must not be null.
  /// Returns the string with all found placeholders replaced.
  ///
  /// Example:
  /// ```dart
  /// 'Hello {{name}}!'.substituteTemplate({'name': 'World'}); // 'Hello World!'
  /// '{{a}}-{{b}}'.substituteTemplate({'a': '1'});          // '1-{{b}}'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  String substituteTemplate(Map<String, String> variables) {
    if (isEmpty || variables.isEmpty) return this;
    // Single pass over the placeholders: each `{{key}}` is replaced once with
    // its value (or left as-is when the key is missing). Iterating the map with
    // chained replaceAll instead would RE-substitute a value that itself
    // contains another key's placeholder (e.g. value '{{b}}' getting expanded
    // on a later pass).
    return replaceAllMapped(RegExp(r'\{\{([^{}]+)\}\}'), (Match m) {
      final String key = m.group(1)!;
      return variables[key] ?? m.group(0)!;
    });
  }
}
