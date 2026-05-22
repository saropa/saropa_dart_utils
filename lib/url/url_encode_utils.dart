/// URL encode/decode (component vs full). Safe decode. Roadmap #166, #171.
import 'dart:developer' as dev;

const String _kLogSafeDecodeUriFailed = 'safeDecodeUri failed';

/// Percent-encodes [value] for use as a single URI component.
///
/// Encodes reserved characters (`&`, `=`, `?`, `/`, etc.) so the result is safe
/// inside a query value or path segment.
///
/// Example:
/// ```dart
/// urlEncodeComponent('a b&c'); // 'a%20b%26c'
/// ```
String urlEncodeComponent(String value) => Uri.encodeComponent(value);

/// Decodes a percent-encoded URI component [value] back to plain text.
///
/// Throws [ArgumentError] on malformed escapes; use [safeDecodeUri] to decode
/// without throwing.
///
/// Example:
/// ```dart
/// urlDecodeComponent('a%20b%26c'); // 'a b&c'
/// ```
String urlDecodeComponent(String value) => Uri.decodeComponent(value);

/// Decodes a percent-encoded URI component [value], returning null on failure.
///
/// Unlike [urlDecodeComponent] this never throws on malformed escapes; the
/// failure is logged and null is returned.
///
/// Example:
/// ```dart
/// safeDecodeUri('a%20b'); // 'a b'
/// safeDecodeUri('%'); // null
/// ```
String? safeDecodeUri(String value) {
  try {
    return Uri.decodeComponent(value);
  } on Object catch (e) {
    dev.log(_kLogSafeDecodeUriFailed, error: e);
    return null;
  }
}
