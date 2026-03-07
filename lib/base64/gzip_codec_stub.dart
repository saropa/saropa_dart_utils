/// Stub gzip implementation for platforms without `dart:io` (e.g., web).
///
/// Returns `null` since gzip is unavailable on these platforms.

/// Gzip-encodes [bytes]. Returns `null` on unsupported platforms.
List<int>? gzipEncode(List<int> bytes) => null;

/// Gzip-decodes [bytes]. Returns `null` on unsupported platforms.
List<int>? gzipDecode(List<int> bytes) => null;
