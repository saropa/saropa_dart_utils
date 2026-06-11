import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/list/list_extensions.dart';
import 'package:saropa_dart_utils/list/unique_list_extensions.dart';

/// Extensions on List<String> for common prefix/suffix.
extension ListStringExtensions on List<String> {
  /// Joins these strings into a natural-language list with an Oxford comma:
  /// one item is itself, two become `'a and b'`, three or more become
  /// `'a, b, and c'`.
  ///
  /// Each entry is trimmed and blank/whitespace-only entries are dropped before
  /// counting, so `[' ', 'a', '']` collapses to a single item rather than
  /// emitting stray separators. When [isUnique] is `true` (default) duplicates
  /// are removed via [toUnique] (first-seen order preserved). Returns `null` —
  /// not `''` — when nothing remains after trimming, so a caller can tell
  /// "no items" apart from a real joined string.
  ///
  /// The joiners are caller-controlled for locale/style:
  /// - [joiner] separates the leading items in the 3+ case (default `', '`).
  /// - [doubleJoiner] joins exactly two items (default `' and '`).
  /// - [lastJoiner] precedes the final item in the 3+ case (default `', and '`,
  ///   the Oxford comma).
  ///
  /// Example:
  /// ```dart
  /// ['Alice', 'Bob', 'Carol'].joinDisplayList(); // 'Alice, Bob, and Carol'
  /// ['Alice', 'Bob'].joinDisplayList();          // 'Alice and Bob'
  /// ['Alice'].joinDisplayList();                 // 'Alice'
  /// <String>[].joinDisplayList();                // null
  /// ```
  @useResult
  String? joinDisplayList({
    String joiner = ', ',
    String doubleJoiner = ' and ',
    String lastJoiner = ', and ',
    bool isUnique = true,
  }) {
    // Trim and drop blanks before counting so the length-based branching below
    // sees the real item count, not entries that would render as empty.
    final List<String> trimmed = <String>[
      for (final String s in this)
        if (s.trim().isNotEmpty) s.trim(),
    ];

    final List<String> list = isUnique ? trimmed.toUnique() : trimmed;
    if (list.isEmpty) {
      return null;
    }

    // first/last are safe here: each branch runs only after its length is
    // proven, so the list is never empty at the access site.
    if (list.length == 1) {
      return list.first;
    }

    if (list.length == 2) {
      return '${list.first}$doubleJoiner${list.last}';
    }

    // 3+ items: lead items joined by [joiner], then the Oxford [lastJoiner].
    return list.takeSafe(list.length - 1).join(joiner) + lastJoiner + list.last;
  }

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
      while (j < maxLen && prefix[j] == s[j]) {
        j++;
      }
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
      while (j < maxLen && suffix[suffix.length - 1 - j] == s[s.length - 1 - j]) {
        j++;
      }
      suffix = suffix.replaceRange(0, suffix.length - j, '');
      if (suffix.isEmpty) return '';
    }
    return suffix;
  }
}
