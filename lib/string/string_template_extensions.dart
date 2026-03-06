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
  @useResult
  String substituteTemplate(Map<String, String> variables) {
    if (isEmpty || variables.isEmpty) return this;
    String result = this;
    for (final MapEntry<String, String> e in variables.entries) {
      final String key = e.key;
      final String value = e.value;
      if (key.isNotEmpty) {
        final String placeholder = '{{$key}}';
        result = result.replaceAll(placeholder, value);
      }
    }
    return result;
  }
}
