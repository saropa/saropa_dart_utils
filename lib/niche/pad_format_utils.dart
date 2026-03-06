/// Pad number with leading zeros. Format file size. Roadmap #220–221.
const String _kPadCharZero = '0';
const String _kSizeZeroB = '0 B';
const List<String> _kFileSizeUnits = <String>['B', 'KB', 'MB', 'GB', 'TB'];

String padWithZeros(int value, int length) {
  return value.toString().padLeft(length, _kPadCharZero);
}

String formatFileSize(int bytes, {int decimals = 1}) {
  if (bytes < 0) return '-${formatFileSize(-bytes, decimals: decimals)}';
  if (bytes == 0) return _kSizeZeroB;
  const List<String> units = _kFileSizeUnits;
  int i = 0;
  double v = bytes.toDouble();
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  final String fmt = v >= 10 || v == v.truncateToDouble()
      ? v.truncate().toString()
      : v.toStringAsFixed(decimals).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return '$fmt ${units[i]}';
}
