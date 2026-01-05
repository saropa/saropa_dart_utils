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
  /// Removes query parameters and optionally the fragment from this URI.
  Uri removeQuery({bool removeFragment = true}) =>
      removeFragment ? replace(query: '', fragment: '') : replace(query: '');

  /// Returns true if this URI points to an image file.
  ///
  /// Checks if the file extension matches common image formats.
  bool get isImageUri {
    final String filePath = path.split('/').lastOrNull ?? '';
    if (filePath.isEmpty) return false;
    final int dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return false;
    final String extension = filePath.substring(dotIndex).toLowerCase();
    return flutterImageExtensions.contains(extension);
  }

  /// Gets the file name from this URI path.
  String? get fileName {
    if (path.isEmpty) return null;
    final String lastSegment = path.split('/').lastOrNull ?? '';
    return lastSegment.isEmpty ? null : lastSegment;
  }

  /// Gets the file extension from this URI path.
  String? get fileExtension {
    final String? name = fileName;
    if (name == null) return null;
    final int dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) return null;
    return name.substring(dotIndex + 1).toLowerCase();
  }

  /// Returns true if this URI uses HTTPS scheme.
  ///
  /// Example:
  /// ```dart
  /// Uri.parse('https://example.com').isSecure; // true
  /// Uri.parse('http://example.com').isSecure; // false
  /// ```
  bool get isSecure => scheme.toLowerCase() == 'https';

  /// Adds or updates a query parameter in this URI.
  ///
  /// If [value] is null or empty, the parameter is removed instead.
  ///
  /// **Args:**
  /// - [key]: The query parameter key.
  /// - [value]: The query parameter value. If null/empty, removes the parameter.
  ///
  /// **Returns:**
  /// A new URI with the updated query parameters.
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com').addQueryParameter('page', '1');
  /// // Returns: https://example.com?page=1
  /// Uri.parse('https://example.com?a=1').addQueryParameter('b', '2');
  /// // Returns: https://example.com?a=1&b=2
  /// ```
  Uri addQueryParameter(String key, String? value) {
    if (key.isEmpty) return this;
    final Map<String, dynamic> params = Map<String, dynamic>.from(queryParameters);
    if (value == null || value.isEmpty) {
      params.remove(key);
    } else {
      params[key] = value;
    }
    return replace(queryParameters: params);
  }

  /// Returns true if this URI has a specific query parameter.
  ///
  /// **Args:**
  /// - [key]: The query parameter key to check.
  ///
  /// **Returns:**
  /// True if the parameter exists, false otherwise.
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com?page=1').hasQueryParameter('page'); // true
  /// Uri.parse('https://example.com?page=1').hasQueryParameter('limit'); // false
  /// ```
  bool hasQueryParameter(String key) => queryParameters.containsKey(key);

  /// Gets the value of a specific query parameter.
  ///
  /// **Args:**
  /// - [key]: The query parameter key.
  ///
  /// **Returns:**
  /// The parameter value, or null if not found.
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com?page=1').getQueryParameter('page'); // '1'
  /// Uri.parse('https://example.com').getQueryParameter('page'); // null
  /// ```
  String? getQueryParameter(String key) => queryParameters[key];

  /// Returns a new URI with the host replaced.
  ///
  /// **Args:**
  /// - [newHost]: The new host to use.
  ///
  /// **Returns:**
  /// A new URI with the replaced host, or this URI if newHost is empty.
  ///
  /// **Example:**
  /// ```dart
  /// Uri.parse('https://example.com/path').replaceHost('newdomain.com');
  /// // Returns: https://newdomain.com/path
  /// ```
  Uri replaceHost(String newHost) {
    if (newHost.isEmpty) return this;
    return replace(host: newHost);
  }
}

/// Extension methods for nullable URI.
extension UriNullableExtensions on Uri? {
  /// Returns true if this URI is null or has an empty path.
  bool get isUriNullOrEmpty => this?.path.isEmpty ?? true;

  /// Returns true if this URI is not null and has a non-empty path.
  bool get isNotUriNullOrEmpty => this?.path.isNotEmpty ?? false;
}

/// Utility class for URL operations.
class UrlUtils {
  const UrlUtils._();

  /// Tries to parse a string as a URI.
  static Uri? tryParse(String? url) {
    if (url == null || url.isEmpty) return null;
    return Uri.tryParse(url);
  }

  /// Checks if a string is a valid URL.
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  /// Checks if a string is a valid HTTP/HTTPS URL.
  static bool isValidHttpUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  /// Extracts the domain from a URL string.
  static String? extractDomain(String? url) {
    if (url == null || url.isEmpty) return null;
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;
    return uri.host;
  }
}
