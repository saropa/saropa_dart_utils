/// File extension / without extension / change extension. Roadmap #164–165.
/// Audited: 2026-06-12 11:26 EDT
String pathExtension(String path) {
  // The extension dot must be in the FINAL path segment. Searching the whole
  // path made a dot in a directory name look like an extension (so the input
  // "/a.b/file" wrongly yielded "b/file"). Confine the dot to the basename
  // (after the last separator) and reject a leading-dot dotfile.
  final int slash = path.lastIndexOf('/');
  final int backslash = path.lastIndexOf(r'\');
  final int sep = slash > backslash ? slash : backslash;
  final int dotIndex = path.lastIndexOf('.');
  if (dotIndex <= sep + 1 || dotIndex == path.length - 1) return '';
  return path.substring(dotIndex + 1);
}

/// Returns [path] with its trailing file extension (and the dot) removed.
///
/// A leading dot (dotfile like `.gitignore`) is not treated as an extension,
/// so such paths are returned unchanged.
///
/// Example:
/// ```dart
/// pathWithoutExtension('archive.tar.gz'); // 'archive.tar'
/// pathWithoutExtension('.gitignore'); // '.gitignore'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String pathWithoutExtension(String path) {
  // Confine the extension dot to the final segment, like pathExtension: the old
  // whole-path search made pathWithoutExtension('/a.b/c') return '/a' by cutting
  // at the dot in the directory name 'a.b'.
  final int slash = path.lastIndexOf('/');
  final int backslash = path.lastIndexOf(r'\');
  final int sep = slash > backslash ? slash : backslash;
  final int dotIndex = path.lastIndexOf('.');
  if (dotIndex <= sep + 1) return path;
  return path.substring(0, dotIndex);
}

/// Returns [path] with its extension replaced by [newExt].
///
/// A leading dot in [newExt] is optional. An empty [newExt] strips the
/// extension entirely.
///
/// Example:
/// ```dart
/// pathChangeExtension('photo.png', 'jpg'); // 'photo.jpg'
/// pathChangeExtension('photo.png', '.webp'); // 'photo.webp'
/// pathChangeExtension('photo.png', ''); // 'photo'
/// ```
/// Audited: 2026-06-12 11:26 EDT
String pathChangeExtension(String path, String newExt) {
  final String without = pathWithoutExtension(path);
  if (newExt.isEmpty) return without;
  return without + (newExt.startsWith('.') ? newExt : '.$newExt');
}
