/// File extension / without extension / change extension. Roadmap #164–165.
String pathExtension(String path) {
  final int dotIndex = path.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == path.length - 1) return '';
  return path.replaceRange(0, dotIndex + 1, '');
}

String pathWithoutExtension(String path) {
  final int dotIndex = path.lastIndexOf('.');
  if (dotIndex <= 0) return path;
  return path.replaceRange(dotIndex, path.length, '');
}

String pathChangeExtension(String path, String newExt) {
  final String without = pathWithoutExtension(path);
  if (newExt.isEmpty) return without;
  return without + (newExt.startsWith('.') ? newExt : '.$newExt');
}
