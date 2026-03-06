import 'package:meta/meta.dart';

/// Extensions on List<String> for common prefix/suffix.
extension ListStringExtensions on List<String> {
  /// Returns the longest common prefix of all strings in this list.
  ///
  /// Returns empty string if list is empty or any element is empty.
  ///
  /// Example:
  /// ```dart
  /// ['flower', 'flow', 'flight'].commonPrefix();  // 'fl'
  /// ['a', 'b'].commonPrefix();  // ''
  /// ```
  @useResult
  String commonPrefix() {
    if (isEmpty) return '';
    String prefix = this[0];
    for (int i = 1; i < length; i++) {
      final String s = this[i];
      final int maxLen = prefix.length < s.length ? prefix.length : s.length;
      int j = 0;
      while (j < maxLen && prefix[j] == s[j]) j++;
      prefix = prefix.replaceRange(j, prefix.length, '');
      if (prefix.isEmpty) return '';
    }
    return prefix;
  }

  /// Returns the longest common suffix of all strings in this list.
  ///
  /// Returns empty string if list is empty or any element is empty.
  ///
  /// Example:
  /// ```dart
  /// ['ending', 'ding'].commonSuffix();  // 'ing'
  /// ```
  @useResult
  String commonSuffix() {
    if (isEmpty) return '';
    String suffix = this[0];
    for (int i = 1; i < length; i++) {
      final String s = this[i];
      final int maxLen = suffix.length < s.length ? suffix.length : s.length;
      int j = 0;
      while (j < maxLen && suffix[suffix.length - 1 - j] == s[s.length - 1 - j]) j++;
      suffix = suffix.replaceRange(0, suffix.length - j, '');
      if (suffix.isEmpty) return '';
    }
    return suffix;
  }
}
