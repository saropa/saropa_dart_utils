/// Extension for nullable maps.
extension MapNullableExtensions on Map<dynamic, dynamic>? {
  /// Returns true if this map is null or empty.
  bool get isMapNullOrEmpty => this?.isEmpty ?? true;

  /// Returns true if this map is not null and not empty.
  bool get isNotMapNullOrEmpty => this?.isNotEmpty ?? false;
}
