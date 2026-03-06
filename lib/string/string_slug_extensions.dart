import 'package:meta/meta.dart';

/// Extensions for generating URL-safe slugs and sanitizing filenames.
extension StringSlugExtensions on String {
  /// Converts this string to a URL-safe slug (lowercase, spaces/special → hyphen).
  ///
  /// Replaces whitespace and non-alphanumeric characters with a single hyphen,
  /// trims leading/trailing hyphens, and returns lowercase. Empty or
  /// whitespace-only strings return empty.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World!'.toSlug();           // 'hello-world'
  /// '  déjà  vu  '.toSlug();           // 'd-j-vu' (diacritics not normalized)
  /// 'one___two'.toSlug();               // 'one-two'
  /// ```
  @useResult
  String toSlug() {
    if (isEmpty) return this;
    final String trimmed = trim();
    if (trimmed.isEmpty) return '';
    final String collapsed = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9\-]'), '-')
        .replaceAll(RegExp(r'-+'), '-');
    return collapsed.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Returns a slug with at most [maxLength] characters, truncating at word boundaries when possible.
  ///
  /// If [maxLength] is less than 1, returns the same as [toSlug()] with no length limit.
  /// Truncation happens at the last hyphen before [maxLength]; if none, truncates at [maxLength].
  /// Returns the truncated slug string.
  ///
  /// Example:
  /// ```dart
  /// 'Hello World Again'.toSlugWithMaxLength(10); // 'hello-worl'
  /// 'a-b-c'.toSlugWithMaxLength(3);             // 'a-b'
  /// ```
  @useResult
  String toSlugWithMaxLength(int maxLength) {
    if (maxLength < 1) return toSlug();
    final String slug = toSlug();
    if (slug.length <= maxLength) return slug;
    final int lastHyphen = slug.lastIndexOf('-', maxLength);
    if (lastHyphen <= 0) return slug.replaceRange(maxLength, slug.length, '');
    return slug.replaceRange(lastHyphen, slug.length, '');
  }

  /// Sanitizes this string for use as a filename: removes invalid characters and optional length cap.
  ///
  /// Removes or replaces characters that are typically invalid in filenames:
  /// ` \ / : * ? " < > |` and control characters. Replaces with [replacement] (default `_`).
  /// If [maxLength] is greater than 0, truncates to that length (after sanitization).
  ///
  /// Example:
  /// ```dart
  /// 'file:name?.txt'.sanitizeFilename();           // 'file_name_.txt'
  /// 'a/b/c'.sanitizeFilename(replacement: '-');    // 'a-b-c'
  /// 'long name'.sanitizeFilename(maxLength: 4);   // 'long'
  /// ```
  @useResult
  String sanitizeFilename({
    String replacement = '_',
    int maxLength = 0,
  }) {
    if (isEmpty) return this;
    // Common invalid filename chars on Windows and Unix
    final String sanitized = replaceAll(RegExp(r'[\s\\/:*?"<>|\x00-\x1f]'), replacement)
        .replaceAll(RegExp(r'\.{2,}'), replacement) // no ..
        .replaceAll(RegExp(r'^\.+'), replacement); // no leading .
    final String one = RegExp.escape(replacement);
    final String trimmed = sanitized.replaceAll(RegExp('$one+'), replacement).trim();
    if (trimmed.isEmpty) return '';
    if (maxLength > 0 && trimmed.length > maxLength) {
      return trimmed.replaceRange(maxLength, trimmed.length, '');
    }
    return trimmed;
  }
}
