import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// Lower priority string: truncate with ellipsis, pad, repeat, isWhitespaceOnly. Roadmap #231-234, 391-395.
extension StringLowerExtensions on String {
  // truncateWithEllipsis intentionally lives only on StringExtensions
  // (string_extensions.dart): that version counts grapheme clusters so emoji and
  // combining marks truncate correctly. A second, code-unit-based copy here
  // collided with it (ambiguous_extension_member_access for barrel consumers) and
  // silently produced different output for multi-byte strings. Removed under
  // BUG-002 — do not re-add a same-named String method here.

  /// Pads this string on the left to [length] with [pad].
  @useResult
  String padLeftTo(int length, [String pad = ' ']) => padLeft(length, pad);

  /// Pads this string on the right to [length] with [pad].
  @useResult
  String padRightTo(int length, [String pad = ' ']) => padRight(length, pad);

  /// Returns this string repeated [n] times, or empty if n <= 0.
  @useResult
  String repeatTimes(int n) => n <= 0 ? '' : List<String>.filled(n, this).join();

  /// True if this string is non-empty and contains only whitespace.
  @useResult
  bool get isWhitespaceOnly => trim().isEmpty && isNotEmpty;

  /// Returns this string with [prefix] prepended if not already present.
  @useResult
  String ensurePrefix(String prefix) => startsWith(prefix) ? this : prefix + this;

  /// Returns this string with [suffix] appended if not already present.
  @useResult
  String ensureSuffix(String suffix) => endsWith(suffix) ? this : this + suffix;

  /// Removes [prefix] from the start if present; otherwise returns this.
  @useResult
  String removePrefix(String prefix) => startsWith(prefix) ? substringSafe(prefix.length) : this;

  /// Removes [suffix] from the end if present; otherwise returns this.
  @useResult
  String removeSuffix(String suffix) =>
      endsWith(suffix) ? substringSafe(0, length - suffix.length) : this;
}

extension StringDefaultEmptyExtension on String? {
  /// Returns this string if non-null, otherwise the empty string.
  String orEmpty() => this ?? '';
}
