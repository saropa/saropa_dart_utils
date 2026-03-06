import 'package:meta/meta.dart';
import 'package:saropa_dart_utils/string/string_extensions.dart';

/// HTTPS URI scheme identifier.
const String _schemeHttps = 'https';

/// HTTP URI scheme identifier.
const String _schemeHttp = 'http';

/// Common image file extensions supported by Flutter.
const Set<String> flutterImageExtensions = <String>{
  '.png',
  '.jpg',
  '.jpeg',
  '.webp',
  '.gif',
  '.bmp',
  // cspell: ignore wbmp
  '.wbmp',
};

/// Extension methods for URI manipulation.
extension UriExtensions on Uri {
  /// Returns a new URI with query parameters removed.
  ///
  /// When [removeFragment] is `true` (default), the fragment is also removed.
  @useResult
  Uri removeQuery({bool removeFragment = true}) =>
      removeFragment ? replace(query: '', fragment: '') : replace(query: '');

  /// Returns true if this URI points to an image file.
  ///
  /// Checks if the file extension matches common image formats.
  @useResult
  bool get isImageUri {
    final String filePath = path.split('/').lastOrNull ?? '';
    if (filePath.isEmpty) {
      return false;
    }

    final int dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) {
      return false;
    }

    final String extension = filePath.substringSafe(dotIndex).toLowerCase();

    return flutterImageExtensions.contains(extension);
  }

  /// Returns the file name from this URI path, or `null` if the path is empty.
  @useResult
  String? get fileName {
    if (path.isEmpty) {
      return null;
    }

    final String lastSegment = path.split('/').lastOrNull ?? '';

    return lastSegment.isEmpty ? null : lastSegment;
  }

  /// Returns the file extension from this URI path, or `null` if none exists.
  @useResult
  String? get fileExtension {
    final String? name = fileName;
    if (name == null) {
      return null;
    }

    final int dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      return null;
    }

    return name.substringSafe(dotIndex + 1).toLowerCase();
  }

  /// Returns true if this URI uses HTTPS scheme.
  ///
  /// Example:
  /// ```dart
  /// Uri.parse('https://example.com').isSecure; // true
  /// Uri.parse('http://example.com').isSecure; // false
  /// ```
  @useResult
  bool get isSecure => scheme.toLowerCase() == _schemeHttps;

  /// Returns a new URI with the [key] query parameter set to [value].
  ///
  /// If [value] is `null` or empty, the parameter is removed instead.
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com').addQueryParameter('page', '1');
  /// // Returns: https://example.com?page=1
  /// Uri.parse('https://example.com?a=1').addQueryParameter('b', '2');
  /// // Returns: https://example.com?a=1&b=2
  /// ```
  @useResult
  Uri addQueryParameter(String key, String? value) {
    if (key.isEmpty) {
      return this;
    }

    final Map<String, dynamic> params = Map<String, dynamic>.from(queryParameters);
    if (value == null || value.isEmpty) {
      params.remove(key);
    } else {
      params[key] = value;
    }

    return replace(queryParameters: params);
  }

  /// Returns `true` if this URI has a query parameter named [key].
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com?page=1').hasQueryParameter('page'); // true
  /// Uri.parse('https://example.com?page=1').hasQueryParameter('limit'); // false
  /// ```
  @useResult
  bool hasQueryParameter(String key) => queryParameters.containsKey(key);

  /// Returns the value of the [key] query parameter, or `null` if not found.
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com?page=1').getQueryParameter('page'); // '1'
  /// Uri.parse('https://example.com').getQueryParameter('page'); // null
  /// ```
  @useResult
  String? getQueryParameter(String key) => queryParameters[key];

  /// Returns a new URI with the host replaced by [newHost], or this URI if
  /// [newHost] is empty.
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com/path').replaceHost('newdomain.com');
  /// // Returns: https://newdomain.com/path
  /// ```
  @useResult
  Uri replaceHost(String newHost) {
    if (newHost.isEmpty) {
      return this;
    }

    return replace(host: newHost);
  }
}

/// Extension methods for nullable URI.
extension UriNullableExtensions on Uri? {
  /// Returns true if this URI is null or has an empty path.
  @useResult
  bool get isUriNullOrEmpty => this?.path.isEmpty ?? true;

  /// Returns true if this URI is not null and has a non-empty path.
  @useResult
  bool get isNotUriNullOrEmpty => this?.path.isNotEmpty ?? false;
}

/// Utility class for URL operations.
abstract final class UrlExtensions {
  /// Returns [url] parsed as a URI, or `null` if parsing fails.
  @useResult
  static Uri? tryParse(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    return Uri.tryParse(url);
  }

  /// Returns `true` if [url] is a valid URL with a scheme and host.
  @useResult
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    final Uri? uri = Uri.tryParse(url);

    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  /// Returns `true` if [url] is a valid HTTP or HTTPS URL.
  @useResult
  static bool isValidHttpUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }

    return (uri.scheme == _schemeHttp || uri.scheme == _schemeHttps) && uri.host.isNotEmpty;
  }

  /// Returns the domain (host) extracted from [url], or `null` if invalid.
  @useResult
  static String? extractDomain(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return null;
    }

    return uri.host;
  }
}
