import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Parse simple key=value pairs from a string.
extension StringKeyValueExtensions on String {
  /// Parses simple key=value pairs separated by whitespace into a map.
  ///
  /// Keys and values are trimmed. Pairs without '=' are skipped or use empty value (configurable).
  /// Duplicate keys: later wins.
  ///
  /// Returns a map from key to value for each key=value pair.
  ///
  /// Example:
  /// ```dart
  /// 'a=1 b=2'.parseKeyValuePairs();  // {'a': '1', 'b': '2'}
  /// ```
  @useResult
  Map<String, String> parseKeyValuePairs() {
    if (isEmpty) return <String, String>{};
    final Map<String, String> out = <String, String>{};
    for (final String part in trim().split(RegExp(r'\s+'))) {
      if (!part.isEmpty) {
        final int eq = part.indexOf('=');
        if (eq >= 0) {
          final String key = part.substringSafe(0, eq).trim();
          final String value = part.substringSafe(eq + 1).trim();
          if (key.isNotEmpty) out[key] = value;
        }
      }
    }
    return out;
  }
}
