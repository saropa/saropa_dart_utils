import 'package:meta/meta.dart';

/// Unicode normalization. Uses NFD/NFC if available via intl; otherwise no-op.
extension StringUnicodeExtensions on String {
  /// Normalizes to NFC (canonical composition) for comparison and storage.
  ///
  /// This package does not depend on `intl`; this method returns the string unchanged.
  /// For full NFC/NFD normalization, use `package:intl` or `package:unorm_dart` in your app.
  ///
  /// Example:
  /// ```dart
  /// 'café'.normalizeUnicodeNfc();  // returns 'café' (no-op without intl)
  /// ```
  @useResult
  String normalizeUnicodeNfc() => this;

  /// Normalizes to NFD (canonical decomposition).
  ///
  /// No-op without an external normalization package; returns this string unchanged.
  @useResult
  String normalizeUnicodeNfd() => this;
}
