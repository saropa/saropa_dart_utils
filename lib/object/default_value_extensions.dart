import 'package:meta/meta.dart';

/// Default map for null (map null to default value). Roadmap #210.
extension DefaultValueExtensions<T> on T? {
  /// Returns this value if non-null, otherwise [defaultValue].
  ///
  /// A typed shorthand for `value ?? defaultValue` that reads clearly in chains.
  ///
  /// Example:
  /// ```dart
  /// String? name;
  /// name.orDefault('Anonymous'); // 'Anonymous'
  /// ```
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  T orDefault(T defaultValue) => this ?? defaultValue;
}
