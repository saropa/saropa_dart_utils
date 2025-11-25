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
  Uri removeQuery({bool removeFragment = true}) => removeFragment ? replace(query: '', fragment: '') : replace(query: '');

  /// Returns true if this URI points to an image file.
  ///
  /// Checks if the file extension matches common image formats.
  bool get isImageUri {
    final String filePath = path.split('/').last;
    if (filePath.isEmpty) return false;
    final int dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return false;
    final String extension = filePath.substring(dotIndex).toLowerCase();
    return flutterImageExtensions.contains(extension);
  }

  /// Gets the file name from this URI path.
  String? get fileName {
    if (path.isEmpty) return null;
    final String lastSegment = path.split('/').last;
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
}

/// Extension methods for nullable URI.
extension UriNullableExtensions on Uri? {
  /// Returns true if this URI is null or has an empty path.
  bool get isUriNullOrEmpty => this == null || this!.path.isEmpty;

  /// Returns true if this URI is not null and has a non-empty path.
  bool get isNotUriNullOrEmpty => this != null && this!.path.isNotEmpty;
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
