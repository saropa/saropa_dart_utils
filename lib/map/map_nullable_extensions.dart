import 'package:meta/meta.dart';

/// Extension for nullable maps.
extension MapNullableExtensions on Map<dynamic, dynamic>? {
  /// Returns true if this map is null or empty.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isMapNullOrEmpty => this?.isEmpty ?? true;

  /// Returns true if this map is not null and not empty.
  /// Audited: 2026-06-12 11:26 EDT
  @useResult
  bool get isNotMapNullOrEmpty => this?.isNotEmpty ?? false;
}
