/// File extension / without extension / change extension. Roadmap #164–165.
String pathExtension(String path) {
  final int dotIndex = path.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == path.length - 1) return '';
  final String copy = path;
  return copy.replaceRange(0, dotIndex + 1, '');
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
String pathWithoutExtension(String path) {
  final int dotIndex = path.lastIndexOf('.');
  if (dotIndex <= 0) return path;
  final String copy = path;
  return copy.replaceRange(dotIndex, path.length, '');
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
String pathChangeExtension(String path, String newExt) {
  final String without = pathWithoutExtension(path);
  if (newExt.isEmpty) return without;
  return without + (newExt.startsWith('.') ? newExt : '.$newExt');
}
