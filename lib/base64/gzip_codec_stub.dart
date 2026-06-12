/// Stub gzip implementation for platforms without `dart:io` (e.g., web).
///
/// Returns `null` since gzip is unavailable on these platforms.

/// Gzip-encodes the given bytes. Returns `null` on unsupported platforms.
/// Audited: 2026-06-12 11:26 EDT
List<int>? gzipEncode(List<int> _) => null;

/// Gzip-decodes the given bytes. Returns `null` on unsupported platforms.
/// Audited: 2026-06-12 11:26 EDT
List<int>? gzipDecode(List<int> _) => null;
