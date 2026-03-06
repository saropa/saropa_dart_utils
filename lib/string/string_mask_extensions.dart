import 'package:meta/meta.dart';

const String _kErrMaskCharNonEmpty = 'maskChar must be non-empty';
const String _kParamMaskChar = 'maskChar';
const String _kErrLocalPartVisibleNonNegative = 'localPartVisible must be non-negative';
const String _kParamLocalPartVisible = 'localPartVisible';
const String _kErrVisibleCountNonNegative = 'visibleCount must be non-negative';
const String _kParamVisibleCount = 'visibleCount';

/// Extensions for masking and redacting sensitive string content.
extension StringMaskExtensions on String {
  /// Masks this string, showing only the last [visibleCount] characters; the rest become [maskChar].
  ///
  /// If [visibleCount] is 0 or negative, the entire string is masked.
  /// If [visibleCount] is greater than or equal to length, the string is returned unchanged.
  ///
  /// Throws [ArgumentError] if [maskChar] is empty.
  ///
  /// Example:
  /// ```dart
  /// '1234567890'.mask(visibleCount: 4);        // '******7890'
  /// 'card'.mask(visibleCount: 4, maskChar: 'x'); // 'card'
  /// 'ab'.mask(visibleCount: 5);                // 'ab'
  /// ```
  @useResult
  String mask({
    int visibleCount = 4,
    String maskChar = '*',
  }) {
    if (maskChar.isEmpty) {
      throw ArgumentError(_kErrMaskCharNonEmpty, _kParamMaskChar);
    }
    if (isEmpty) return this;
    if (visibleCount >= length) return this;
    if (visibleCount <= 0) return maskChar * length;
    final int hidden = length - visibleCount;
    return (maskChar * hidden) + replaceRange(0, hidden, '');
  }

  /// Redacts an email-like string to something like `j***@example.com`.
  ///
  /// If this string contains exactly one `@`, shows the first character of the local part,
  /// then [maskChar] repeated [localPartVisible] times (default 3), then `@` and the domain unchanged.
  /// Otherwise returns [maskChar] repeated by length (no structure assumed).
  ///
  /// Throws [ArgumentError] if [maskChar] is empty or [localPartVisible] is negative.
  ///
  /// Example:
  /// ```dart
  /// 'user@example.com'.redactEmail();     // 'u***@example.com'
  /// 'a@b.co'.redactEmail(maskChar: 'x');  // 'axxx@b.co'
  /// ```
  @useResult
  String redactEmail({
    int localPartVisible = 3,
    String maskChar = '*',
  }) {
    if (maskChar.isEmpty) {
      throw ArgumentError(_kErrMaskCharNonEmpty, _kParamMaskChar);
    }
    if (localPartVisible < 0) {
      throw ArgumentError(_kErrLocalPartVisibleNonNegative, _kParamLocalPartVisible);
    }
    if (isEmpty) return this;
    final int at = indexOf('@');
    if (at <= 0 || at != lastIndexOf('@')) {
      return maskChar * length;
    }
    final String local = substring(0, at);
    final String domain = substring(at);
    final String first = local.isEmpty ? '' : local[0];
    final String rest = maskChar * (localPartVisible > 0 ? localPartVisible : 0);
    return first + rest + domain;
  }

  /// Redacts a phone-like string: keeps last [visibleCount] digits, masks the rest with [maskChar].
  ///
  /// Only digit characters are considered for visibility; non-digits are preserved in place.
  /// If there are no digits, returns [maskChar] repeated for each character.
  ///
  /// Throws [ArgumentError] if [maskChar] is empty or [visibleCount] is negative.
  ///
  /// Example:
  /// ```dart
  /// '+1 (555) 123-4567'.redactPhone(visibleCount: 4); // '+* (**) ***-4567' (digits masked except last 4)
  /// ```
  @useResult
  String redactPhone({
    int visibleCount = 4,
    String maskChar = '*',
  }) {
    if (maskChar.isEmpty) {
      throw ArgumentError(_kErrMaskCharNonEmpty, _kParamMaskChar);
    }
    if (visibleCount < 0) {
      throw ArgumentError(_kErrVisibleCountNonNegative, _kParamVisibleCount);
    }
    if (isEmpty) return this;
    final List<int> digitIndices = <int>[];
    for (final MapEntry<int, String> entry in split('').asMap().entries) {
      if (RegExp(r'\d').hasMatch(entry.value)) digitIndices.add(entry.key);
    }
    if (digitIndices.length <= visibleCount) return this;
    final int maskFrom = digitIndices.length - visibleCount;
    final List<String> chars = split('');
    for (final int idx in digitIndices.take(maskFrom)) {
      chars[idx] = maskChar;
    }
    return chars.join();
  }
}
