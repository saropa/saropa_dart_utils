import 'package:meta/meta.dart';

/// A set of utility methods for working with strings.
extension StringNullableExtensions on String? {
  /// Extension method to check if a [String] is null or empty.
  ///
  /// Returns `true` if the string is either `null` or an empty string (`""`).
  /// Otherwise, returns `false`.
  ///
  /// **Deprecated — convenient shorthand, but it defeats Dart's null
  /// promotion.** Dart's flow analysis cannot see that this opaque getter
  /// implies `this != null`, so after `if (text.isNullOrEmpty) return;` the
  /// variable stays nullable (`String?`) and callers are pushed toward `!`.
  /// The long form the Flutter/Dart analyzer DOES understand promotes the
  /// variable to non-null in the guarded scope:
  ///
  /// ```dart
  /// // Preferred — `text` is promoted to non-null `String` after this guard:
  /// if (text == null || text.isEmpty) return;
  /// text.length; // no `!` needed
  /// ```
  ///
  /// Kept for source compatibility; prefer the long form in new code.
  ///
  /// Example:
  /// ```dart
  /// String? text;
  /// print(text.isNullOrEmpty); // Output: true
  ///
  /// text = "";
  /// print(text.isNullOrEmpty); // Output: true
  ///
  /// text = "Hello";
  /// print(text.isNullOrEmpty); // Output: false
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @Deprecated(
    'Cool shorthand, but it hides the null check from Dart flow analysis: '
    'code after `if (x.isNullOrEmpty)` does not promote `x` to non-null, '
    'pushing callers toward `!`. Prefer the long form `x == null || x.isEmpty`, '
    'which the analyzer understands and which promotes `x` afterward.',
  )
  @useResult
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  /// IMPORTANT: do not call ?.isNotNullOrEmpty as it will chain to null not a bool
  /// Return true if the string is not null and not empty
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isNotNullOrEmpty => this?.isNotEmpty ?? false;
}
