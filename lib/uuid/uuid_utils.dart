// UUID with hyphens: 36 characters (8-4-4-4-12)
// Validates UUID versions 1-5 with proper variant bits
final RegExp _uuidWithHyphensRegex = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

// UUID without hyphens: 32 characters
final RegExp _uuidWithoutHyphensRegex = RegExp(
  r'^[0-9a-f]{8}[0-9a-f]{4}[1-5][0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}$',
  caseSensitive: false,
);

/// Utility class for UUID validation and manipulation.
///
/// Provides methods to validate UUID strings in both standard (with hyphens)
/// and compact (without hyphens) formats.
///
/// Example usage:
/// ```dart
/// UuidUtils.isUUID('123e4567-e89b-12d3-a456-426614174000'); // true
/// UuidUtils.isUUID('123e4567e89b12d3a456426614174000'); // true
/// UuidUtils.isUUID('not-a-uuid'); // false
/// ```
class UuidUtils {
  const UuidUtils._(); // Private constructor to prevent instantiation

  /// Validates if the given string is a valid UUID.
  ///
  /// Supports both UUID formats:
  /// - With hyphens (36 chars): `123e4567-e89b-12d3-a456-426614174000`
  /// - Without hyphens (32 chars): `123e4567e89b12d3a456426614174000`
  ///
  /// The validation checks:
  /// - Correct length (32 or 36 characters)
  /// - Valid hexadecimal characters only
  /// - Valid UUID version (1-5) in the version nibble
  /// - Valid variant bits (8, 9, a, or b) in the variant nibble
  ///
  /// Returns `false` if:
  /// - The input is null or empty
  /// - The length is not 32 or 36 characters
  /// - The format doesn't match UUID specifications
  ///
  /// Example:
  /// ```dart
  /// UuidUtils.isUUID('123e4567-e89b-12d3-a456-426614174000'); // true (v1 UUID)
  /// UuidUtils.isUUID('550e8400-e29b-41d4-a716-446655440000'); // true (v4 UUID)
  /// UuidUtils.isUUID('123e4567e89b12d3a456426614174000'); // true (no hyphens)
  /// UuidUtils.isUUID(''); // false
  /// UuidUtils.isUUID('not-a-uuid'); // false
  /// UuidUtils.isUUID('123e4567-e89b-62d3-a456-426614174000'); // false (invalid version 6)
  /// ```
  static bool isUUID(String? uuid) {
    if (uuid == null || uuid.isEmpty) {
      return false;
    }

    // Check length: must be 32 (no hyphens) or 36 (with hyphens)
    if (uuid.length != 32 && uuid.length != 36) {
      return false;
    }

    // Use appropriate regex based on length
    if (uuid.length == 36) {
      return _uuidWithHyphensRegex.hasMatch(uuid);
    }

    return _uuidWithoutHyphensRegex.hasMatch(uuid);
  }

  /// Adds hyphens to a 32-character UUID string to create the standard format.
  ///
  /// Converts a compact UUID (32 chars) to standard format (36 chars):
  /// `123e4567e89b12d3a456426614174000` → `123e4567-e89b-12d3-a456-426614174000`
  ///
  /// Returns:
  /// - The UUID with hyphens if input is valid 32-char hex string
  /// - The original string if it already contains hyphens
  /// - `null` if input is null, empty, or not exactly 32 characters
  ///
  /// Example:
  /// ```dart
  /// UuidUtils.addHyphens('123e4567e89b12d3a456426614174000');
  /// // Returns '123e4567-e89b-12d3-a456-426614174000'
  ///
  /// UuidUtils.addHyphens('123e4567-e89b-12d3-a456-426614174000');
  /// // Returns '123e4567-e89b-12d3-a456-426614174000' (unchanged)
  ///
  /// UuidUtils.addHyphens('too-short'); // Returns null
  /// ```
  static String? addHyphens(String? uuid) {
    if (uuid == null || uuid.isEmpty) {
      return null;
    }

    // Already has hyphens
    if (uuid.contains('-')) {
      return uuid;
    }

    // Must be exactly 32 characters
    if (uuid.length != 32) {
      return null;
    }

    final StringBuffer sb = StringBuffer()
      ..write(uuid.substring(0, 8))
      ..write('-')
      ..write(uuid.substring(8, 12))
      ..write('-')
      ..write(uuid.substring(12, 16))
      ..write('-')
      ..write(uuid.substring(16, 20))
      ..write('-')
      ..write(uuid.substring(20));

    return sb.toString();
  }

  /// Removes hyphens from a UUID string to create the compact format.
  ///
  /// Converts a standard UUID (36 chars) to compact format (32 chars):
  /// `123e4567-e89b-12d3-a456-426614174000` → `123e4567e89b12d3a456426614174000`
  ///
  /// Returns:
  /// - The UUID without hyphens
  /// - `null` if input is null or empty
  ///
  /// Example:
  /// ```dart
  /// UuidUtils.removeHyphens('123e4567-e89b-12d3-a456-426614174000');
  /// // Returns '123e4567e89b12d3a456426614174000'
  /// ```
  static String? removeHyphens(String? uuid) {
    if (uuid == null || uuid.isEmpty) {
      return null;
    }

    return uuid.replaceAll('-', '');
  }
}
